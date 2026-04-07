extends Area2D
@export var crate_type : String = "default"

var player_in_area = false

func _ready():
	$Label.visible = false

func _process(_delta):
	if not player_in_area: 
		return 
	if Input.is_action_just_pressed("Interact"): # Pressed E
		open_battleground("build")
	
	if Input.is_action_just_pressed("start_round"):
		open_battleground("round")
		
func _on_Area2D_body_entered(body):
	if body.name == "CharacterBody2D":
		player_in_area = true
		$Label.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "CharacterBody2D":
		player_in_area = false
		$Label.visible = false

# Open battleground function 
func open_battleground(mode: String):
	var battleground = preload("res://Battleground.tscn").instantiate()

	battleground.mode = mode   # <-- Set the mode BEFORE switching scenes

	# Swap scenes properly
	get_tree().root.add_child(battleground)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battleground
# Interaction Function
func interact():
	print("Interacted with crate!")
	var battleground_scene = preload("res://Battleground.tscn").instantiate()

	match crate_type:
		"Start":
			battleground_scene.mode = "round"   # ← tell scene to enter ROUND mode

		"Shop":
			battleground_scene.mode = "build"   # ← use build mode (E)

	# Switch to scene
	get_tree().root.add_child(battleground_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battleground_scene
	
