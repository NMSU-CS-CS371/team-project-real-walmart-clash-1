extends Node2D
# Vars
var menu := false
var escCount = 0 

func _ready():
	print("READY WORKED")
	$"CanvasLayer/Panel".visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed")
		toggle_menu()

func toggle_menu():
	menu = !menu
	if(escCount == 0):
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
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game.tscn")
