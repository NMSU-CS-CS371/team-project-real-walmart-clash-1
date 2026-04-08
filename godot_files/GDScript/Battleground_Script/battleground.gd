extends Node2D

@onready var towers := $Towers
@onready var builder := $Builder 
@onready var round_label := $"CanvasLayer/RoundLabel"
@onready var round_timer := $RoundTimer

# Vars
var menu := false
var escCount = 0 
var tower_scene := preload("res://Towers/basic_tower.tscn")
var menu_open := false				# Checks menu open 
var mode := "build" # Default build mode 


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
	round_label.visible = true # Show label 
	update_round_label() # Show value 
	$RoundTimer.start()

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
