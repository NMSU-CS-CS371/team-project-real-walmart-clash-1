extends Node2D

@onready var towers := $Towers
@onready var builder := $Builder 
@onready var round_label := $"CanvasLayer/RoundLabel"
@onready var round_timer := $RoundTimer

# Vars
var menu := false
var escCount = 0 
var tower_scene := preload("res://turret.tscn")
var menu_open := false				# Checks menu open 
var mode := "build" # Default build mode 
var base_enemy_count := 5 # Initial enemy spawn count 
var OFFSET_X = 1500
var OFFSET_Y = 100
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

var spawn_positions = [
	Vector2(100, 700),
	Vector2(200, 650),
	Vector2(250, 600),
	Vector2(300, 550),
	Vector2(350, 500),
	Vector2(400, 450),
	Vector2(450, 400),
	Vector2(500, 350),
	Vector2(550, 300)
]


func _ready():
	#print("READY WORKED")
	print("Battleground opened in mode: ", mode)
	# restore towers when loading scene 
	restore_towers()
	$"CanvasLayer/Panel".visible = false
	round_label.visible = false 
	
	if mode == "build": 
		enter_build_mode()
	else: 
		enter_round_mode()

func is_round_mode():
	return mode == "round"

func _process(delta):
	if round_timer.is_stopped():	
		return

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
		print("ESC pressed")
		toggle_menu()

func toggle_menu():
	menu = !menu
	menu_open = menu
	if(escCount == 0 && menu):
		# Show menu 
		$"CanvasLayer/Panel".visible = menu
		# Pause Game 
		get_tree().paused = menu
		$"CanvasLayer".process_mode = Node.PROCESS_MODE_INHERIT
		$"CanvasLayer/Panel".process_mode = Node.PROCESS_MODE_ALWAYS
		escCount = 1 # Update escount 
		print(escCount)
	else:  # Close menu 
			# Hide menu
			$"CanvasLayer/Panel".visible = false 
			#Resume game 
			get_tree().paused = false
			
			$"CanvasLayer".process_mode = Node.PROCESS_MODE_INHERIT
			$"CanvasLayer/Panel".process_mode = Node.PROCESS_MODE_INHERIT
			# Update escCount
			escCount = 0
			print(escCount)
			pass

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

	start_round()

func start_round():
	print("Round started!")
	# Increment round counter 
	GameState.round_counter += 1 
	round_label.visible = true # Show label 
	update_round_label() # Show value 
	$RoundTimer.start()
	print("Round: ", GameState.round_counter)
	
	# Enemy Spawn  ##### 
	# Enemy Count changes every round 
	var enemy_count = base_enemy_count + GameState.round_counter* 2
	
	# For every new enemy_count spawn those amonut of enemies 
	for i in enemy_count: 
		spawn_enemy()
		await get_tree().create_timer(0.5).timeout
		
	

func enter_build_mode():
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
	var time_left = round_timer.get_time_left()
	round_label.text = "Round ends in: " + str(round(time_left))
	
	
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
@onready var enemy_scene = preload("res://enemy_backup.tscn")

func spawn_enemy(): 
	var enemy = enemy_scene.instantiate()
	
	var tile = get_random_spawn_tile()
	var world_pos = grid_to_world(tile.x, tile.y)
	
	# Optional: small randomness so enemies don’t stack perfectly
	world_pos += Vector2(
		randf_range(-10, 10),
		randf_range(-5, 5)
	)
	
	enemy.global_position = world_pos
	add_child(enemy)
