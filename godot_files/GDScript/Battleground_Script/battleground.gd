extends Node2D

########## NODE REFERENCES ##########
@onready var towers := $Towers
@onready var builder := $Builder 
@onready var round_label := $"Menu/CanvasLayer/RoundLabel"
@onready var base_hp_label := $"Menu/CanvasLayer/BaseHPLabel"
@onready var horde_label := $Menu/CanvasLayer/HordeLabel
@onready var round_counter_label := $"Menu/CanvasLayer/RoundCounterLabel"
@onready var reward_label := $"Menu/CanvasLayer/RewardLabel"
@onready var speed_button := $"Menu/CanvasLayer/SpeedButton"


# MENU (UPDATED PATH)
@onready var menu_panel := $Menu/CanvasLayer/Panel

@onready var enemy_scene = preload("res://enemy_backup.tscn")
@onready var tower_scene = preload("res://Turrets/turret.tscn")
@onready var tilemap := $Battleground

########## VARIABLES ##########
var menu_open := false
var mode := "build"
var base_enemy_count := 3
var enemies_alive := 0
var round_time := 0.0
var round_running := false
var game_speed := 1
var ending_round := false

var goal_positions: Array = []

var spawn_tiles = [
	Vector2i(-2,25), Vector2i(0,24), Vector2i(1,23),
	Vector2i(3,20), Vector2i(6,12), Vector2i(8,5),
	Vector2i(10,3), Vector2i(11,1)
]

var goal_tiles = [
	Vector2i(-8,-21), Vector2i(-14,-9),
	Vector2i(-11,-14), Vector2i(-10,-17),
	Vector2i(-7,-23), Vector2i(-6,-24)
]

########## READY ##########
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	restore_towers()
	GameState.base_health_changed.connect(update_base_hp)
	update_base_hp()

	menu_panel.visible = false
	round_label.visible = false 
	round_counter_label.visible = true

	# Precompute goal positions
	for tile in goal_tiles:
		goal_positions.append(tilemap.to_global(tilemap.map_to_local(tile)))

	if mode == "build":
		enter_build_mode()
	else:
		enter_round_mode()
	print(base_hp_label)



########## INPUT (FIXED) ##########
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if mode == "round":
			return
		
		toggle_menu()

########## MENU ##########
func toggle_menu():
	menu_open = !menu_open

	builder.set_process_input(not menu_open)

	menu_panel.visible = menu_open
	base_hp_label.visible = not menu_open
	round_label.visible = not menu_open

	get_tree().paused = menu_open

########## MODES ##########
func enter_build_mode():
	mode = "build"
	builder.visible = true
	builder.set_process(true)
	builder.set_process_input(true)

func enter_round_mode():
	mode = "round"
	builder.visible = false
	builder.set_process(false)
	builder.set_process_input(false)
	start_round()
	
func is_round_mode():
	return mode == "round"

########## ROUND ##########
func start_round():
	get_tree().paused = false 
	base_hp_label.visible = true 
	GameState.round_counter += 1
	update_round_counter()
	round_time = 0.0
	round_running = true
	round_label.visible = true
	update_round_label()
	
	# HORDE mode
	if GameState.round_counter % 5 == 0:
		print("HORDE MODE ACTIVATED")
		await show_horde_label()
		await run_horde_mode()
		return
		
	var enemy_count = base_enemy_count + GameState.round_counter * 2

	for i in range(enemy_count):
		spawn_enemy()
		await get_tree().create_timer(0.5).timeout

func _process(delta):
	if base_hp_label:
		base_hp_label.visible = true

	if not round_running:
		return

	round_time += delta
	update_round_label()

func update_round_label():
	round_label.text = "Time: " + str(round(round_time))

func update_round_counter():
	if GameState.round_counter %  5 == 0:
		round_counter_label.text = "HORDE ROUND"
		round_counter_label.modulate = Color.RED
	else:
		round_counter_label.text = "Round: " + str(GameState.round_counter)
		round_counter_label.modulate = Color.WHITE

########## ENEMIES ##########
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var tile = spawn_tiles.pick_random()

	var world_pos = tilemap.to_global(tilemap.map_to_local(tile))
	world_pos += Vector2(0, -20)

	enemy.global_position = world_pos
	enemy.apply_scaling(GameState.round_counter)
	enemies_alive += 1
	enemy.connect("tree_exited", Callable(self, "_on_enemy_died"))

	add_child(enemy)

func _on_enemy_died():
	if GameState.is_game_over:
		return

	enemies_alive -= 1

	#  Don't auto-end during horde
	if enemies_alive <= 0 and GameState.round_counter != 5:
		end_round()
		
func run_horde_mode():
	var round_scale = int(GameState.round_counter / 5)

	var wave1 = 5 + round_scale * 2
	var wave2 = 8 + round_scale * 3
	var wave3 = 12 + round_scale * 4

	print("Wave 1")
	await spawn_wave(wave1)
	await wait_for_wave_clear()

	await safe_wait(1.5)

	if not is_valid_tree():
		return

	print("Wave 2")
	await spawn_wave(wave2)
	await wait_for_wave_clear()

	await safe_wait(1.5)

	if not is_valid_tree():
		return

	print("FINAL WAVE")
	await spawn_wave(wave3)
	await wait_for_wave_clear()

	if not is_valid_tree():
		return

	print("HORDE COMPLETE")
	end_round()
	
func spawn_wave(count: int):
	for i in range(count):
		spawn_enemy()
		await get_tree().create_timer(0.3).timeout
		
func wait_for_wave_clear():
	while enemies_alive > 0:
		if not is_valid_tree():
			return
		await get_tree().process_frame

########## END ROUND ##########
func end_round():

	if ending_round:
		return

	ending_round = true

	if GameState.is_game_over:
		return

	var reward = 50 + GameState.round_counter * 50
	GameState.currency += reward
	GameState.save_game()

	await show_reward(reward)

	save_towers()

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file("res://game.tscn")

########## HELPERS ##########
func restore_towers():
	var saved = GameState.get_saved_towers()

	print(saved)

	for t_data in saved:
		print("Tower Data:", t_data)

		var raw_pos = t_data.get("pos")
		var pos: Vector2

		# Handle old string saves AND new Vector2 saves
		if typeof(raw_pos) == TYPE_STRING:
			pos = str_to_var("Vector2" + raw_pos)
		else:
			pos = raw_pos

		var id = t_data.get("id")

		if pos == null:
			print("Missing position!")
			continue

		var scene = get_scene_from_id(id)

		if scene == null:
			print("Invalid tower id:", id)
			continue

		var tower = scene.instantiate()

		tower.global_position = pos

		tower.set_meta("id", id)

		assign_group(tower, id)

		towers.add_child(tower)

		print("Restored:", id)

func save_towers():
	var data = []

	for t in towers.get_children():
		data.append({
			"pos": t.global_position,
			"id": t.get_meta("id")  
		})

	GameState.save_towers(data)
	GameState.save_game()

func update_base_hp():
	if not base_hp_label:
		print("BaseHPLabel missing!")
		return

	base_hp_label.visible = true
	base_hp_label.text = "Base: " + str(GameState.base_health)

	# Color feedback
	if GameState.base_health > 200:
		base_hp_label.modulate = Color(0, 1, 0)
	elif GameState.base_health > 100:
		base_hp_label.modulate = Color(1, 1, 0)
	else:
		base_hp_label.modulate = Color(1, 0, 0)

func get_goal_positions():
	return goal_positions


func _on_button_pressed() -> void:
	print("Menu button pressed")

	# Unpause before changing scene
	get_tree().paused = false

	# Save towers before leaving
	save_towers()
	GameState.save_game()
	Engine.time_scale = 1.0
	# Go back to main menu / hub
	get_tree().change_scene_to_file("res://game.tscn")

func show_horde_label():
	horde_label.visible = true
	horde_label.modulate.a = 1.0
	horde_label.scale = Vector2(2.5, 2.5)

	# Animate (grow slightly)
	var tween = create_tween()
	tween.tween_property(horde_label, "scale", Vector2(3, 3), 0.4)

	# Wait a bit
	await get_tree().create_timer(1.2).timeout

	# Fade out
	var fade = create_tween()
	fade.tween_property(horde_label, "modulate:a", 0.0, 0.6)

	await fade.finished
	horde_label.visible = false
	
func is_valid_tree() -> bool:
	return is_inside_tree() and get_tree() != null
	
func safe_wait(seconds: float):
	if not is_valid_tree():
		return
	await get_tree().create_timer(seconds).timeout

func get_scene_from_id(id: String):
	if TowerDatabase.troops.has(id):
		return TowerDatabase.troops[id]["scene"]
	elif TowerDatabase.turrets.has(id):
		return TowerDatabase.turrets[id]["scene"]
	return null
	
func assign_group(node: Node, id: String):
	if TowerDatabase.troops.has(id):
		node.add_to_group("tower")   # blockers
	elif TowerDatabase.turrets.has(id):
		node.add_to_group("turret")  # shooters

func show_reward(amount: int):
	reward_label.visible = true
	reward_label.text = "+$" + str(amount)

	reward_label.modulate.a = 1.0
	reward_label.scale = Vector2(1.5, 1.5)

	# Pop animation
	var tween = create_tween()
	tween.tween_property(reward_label, "scale", Vector2(2, 2), 0.3)

	await get_tree().create_timer(1.0).timeout

	# Fade out
	var fade = create_tween()
	fade.tween_property(reward_label, "modulate:a", 0.0, 0.5)

	await fade.finished
	reward_label.visible = false


func _on_speed_button_pressed():

	if game_speed == 1:
		game_speed = 2
		Engine.time_scale = 2.0
		speed_button.text = "2x"

	else:
		game_speed = 1
		Engine.time_scale = 1.0
		speed_button.text = "1x"
