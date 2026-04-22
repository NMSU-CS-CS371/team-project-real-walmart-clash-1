extends Node2D
# Vars
var menu := false
var escCount = 0 
var menu_open = false
func _ready():
	for crate in get_tree().get_nodes_in_group("interactable"):
		crate.connect("interacted", Callable(self, "_on_crate_interacted"))
	$"Menu/CanvasLayer/Panel".visible = false
	$CanvasLayer/ShopUI.visible = false

# Handle Scene 
func _on_crate_interacted(type, scene_to_open):
	if type == "change_scene":
		get_tree().change_scene_to_file(scene_to_open)
	elif type == "popup":
		$UI/MyPopup.show()

# Handle input 
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if menu_open:
			return  
		toggle_menu()

func toggle_menu():
	menu = !menu
	if(escCount == 0):
		# Show menu 
		$"Menu/CanvasLayer/Panel".visible = menu
		# Pause Game 
		get_tree().paused = menu
		$"Menu/CanvasLayer".process_mode = Node.PROCESS_MODE_ALWAYS
		escCount = 1 # Update escount 
		print(escCount)
	else:  # Close menu 
			$"Menu/CanvasLayer/Panel".visible = false 
			get_tree().paused = false
			escCount = 0
			print(escCount)
			pass

# Button menu pressed 
func _on_button_pressed():
	print("Button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
