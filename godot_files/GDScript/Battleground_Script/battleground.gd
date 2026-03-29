extends Node2D
# Vars
var menu := false
var escCount = 0 
var tower_scene := preload("res://Towers/basic_tower.tscn")
@onready var towers := $Towers
var menu_open := false				# Checks menu open 

func _ready():
	print("READY WORKED")
	# restore towers when loading scene 
	restore_towers()
	$"CanvasLayer/Panel".visible = false

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
		$"CanvasLayer".process_mode = Node.PROCESS_MODE_ALWAYS
		escCount = 1 # Update escount 
		print(escCount)
	else:  # Close menu 
			$"CanvasLayer/Panel".visible = false 
			get_tree().paused = false
			escCount = 0
			print(escCount)
			pass

# Button menu pressed 
func _on_button_pressed():
	print("Button pressed")

	var tower_positions = []
	for tower in towers.get_children():
		tower_positions.append(tower.global_position)

	GameState.save_towers(tower_positions)
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game.tscn")
