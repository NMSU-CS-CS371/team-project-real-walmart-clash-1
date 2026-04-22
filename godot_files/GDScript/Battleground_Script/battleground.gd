extends Node2D


########## NODE REFERENCES ##########
@onready var towers := $Towers
@onready var builder := $Builder 
@onready var round_label := $"CanvasLayer/RoundLabel"
@onready var round_timer := $RoundTimer
@onready var enemy_scene = preload("res://enemy_backup.tscn")
@onready var base_hp_label = $CanvasLayer/BaseHPLabel
@onready var tilemap := $Battleground

# Vars
var menu := false
var escCount = 0 
var tower_scene := preload("res://Turrets/turret.tscn")
var menu_open := false				# Checks menu open 
var mode := "build" # Default build mode 
var base_enemy_count := 3# Initial enemy spawn count 
var enemies_alive := 0 # Keep track of enemies 
var OFFSET_X = 1500
var OFFSET_Y = 50
var round_time := 0.0
var round_running := false
var goal_positions: Array = []
var spawn_tiles = [
	Vector2i(1,11),
	Vector2i(2,10),
	Vector2i(2,9),
	Vector2i(3,8),
	Vector2i(3,7),
	Vector2i(4,6),
	Vector2i(4,5),
	Vector2i(5,4),
	Vector2i(5,3)
]
var goal_tiles = [
	Vector2i(-5,0), Vector2i(-5,-1),
	Vector2i(-4,-2), Vector2i(-4,-3),
	Vector2i(-3,-4), Vector2i(-3,-5),
	Vector2i(-2,-6), Vector2i(-2,-7),
	Vector2i(-1,-8), Vector2i(-1,-9),
	Vector2i(0,-10)
]


func _ready():
	#print("READY WORKED")
	print("Battleground opened in mode: ", mode)
	# restore towers when loading scene 
	restore_towers()
	GameState.base_health_changed.connect(update_base_hp)
	update_base_hp()

	$"CanvasLayer/Panel".visible = false
	round_label.visible = false 
	
	for tile in goal_tiles:
		goal_positions.append(tilemap.map_to_local(tile))
	
	if mode == "build": 
		enter_build_mode()
	else: 
		enter_round_mode()

func is_round_mode():
	return mode == "round"

func _process(delta):
	if not round_running:
		return

	round_time += delta
	update_round_label()
	
# Restore towers 
func restore_towers():
	var positions = GameState.get_saved_towers()

	for pos in positions:
		var tower = tower_scene.instantiate()
		tower.global_position = pos
		tower.add_to_group("tower")
		towers.add_child(tower)
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		# Block menu during round
		if mode == "round":
			return
			
		toggle_menu()

func toggle_menu():
	menu = !menu
	menu_open = menu
	builder.set_process_input(not menu)
	if mode == "round":
		return
	
	if menu:
		# Show menu
		$CanvasLayer/Panel.visible = true
		# Hide base HP label 
		base_hp_label.visible = false
		round_label.visible = false
		# Allow menu to still receive input while paused
		$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS
		
		get_tree().paused = true
	else:
		# Hide menu
		$CanvasLayer/Panel.visible = false
		# Show Base HP 
		base_hp_label.visible = true
		round_label.visible = true
		get_tree().paused = false
		
		# Return to normal
		$CanvasLayer.process_mode = Node.PROCESS_MODE_INHERIT

# BUILDER MODE FUNCTION: 
func open_battleground(mode: String):
	var battleground = preload("res://Battleground.tscn").instantiate()

	battleground.mode = mode   # <-- Set the mode BEFORE switching scenes

	# Swap scenes properly
	get_tree().root.add_child(battleground)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battleground
	
# ROUND MODE FUNCTION: 
func enter_round_mode():
	builder.visible = false
	builder.set_process(false)
	builder.set_process_input(false)
	mode = "round"  
	start_round()

func start_round():
	print("Round started!")
	# Increment round counter 
	GameState.round_counter += 1 
	round_time = 0.0
	round_running = true
	
	round_label.visible = true
	update_round_label() # Show value
	
	# Enemy Spawn  ##### 
	# Enemy Count changes every round 
	var enemy_count = base_enemy_count + GameState.round_counter* 2
	
	# For every new enemy_count spawn those amonut of enemies 
	for i in range(enemy_count):
		spawn_enemy()
		await get_tree().create_timer(0.5).timeout
		
	

func enter_build_mode():
	mode = "build"
	builder.visible = true
	builder.set_process(true)
	builder.set_process_input(true)

# Button menu pressed 
func _on_button_pressed():
	print("Button pressed")

	var tower_positions = []
	for tower in towers.get_children():
		tower_positions.append(tower.global_position)

	GameState.save_towers(tower_positions)
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game.tscn")

# Display round label 
func update_round_label():
	round_label.text = "Time: " + str(round(round_time))
	
	
func _on_round_timer_timeout():
	print("Round ended!")
	round_label.visible = false # Hide label qeqewe
	var positions = []
	for t in towers.get_children():
		positions.append(t.global_position)
	GameState.save_towers(positions)

	get_tree().change_scene_to_file("res://game.tscn")

# Get random spawn tile 
func get_random_spawn_tile() -> Vector2i: 
	return spawn_tiles.pick_random()

func grid_to_world(x: int, y: int) -> Vector2:
	var pos = Vector2(
		(x - y) * 128,
		(x + y) * 64
	)
	pos += Vector2(OFFSET_X, OFFSET_Y)
	return pos 
	
func get_goal_positions() -> Array:
	return goal_positions


func spawn_enemy(): 
	var enemy = enemy_scene.instantiate()
	var tile = get_random_spawn_tile()
	var world_pos = grid_to_world(tile.x, tile.y)

	enemy.global_position = world_pos
	
	# Track enemy count
	enemies_alive += 1
	
	# Connect death signal
	enemy.connect("tree_exited", Callable(self, "_on_enemy_died"))
	
	add_child(enemy)
	
# Decrement whe enemy dies 
func _on_enemy_died():
	if GameState.is_game_over:
		return
	enemies_alive -= 1

	if enemies_alive <= 0:
		end_round()
		
func update_base_hp():
	base_hp_label.text = "Base: " + str(GameState.base_health)

# End round 
func end_round():
	if GameState.is_game_over:
		return

	print("Round complete!")

	var reward = 100 + GameState.round_counter * 50
	GameState.currency += reward

	# Save towers
	var positions = []
	for t in towers.get_children():
		positions.append(t.global_position)

	GameState.save_towers(positions)

	get_tree().change_scene_to_file("res://game.tscn")
