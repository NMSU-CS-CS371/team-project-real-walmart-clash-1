extends Area2D
@export var crate_type : String = "default"

var player_in_area = false

func _ready():
	$Label.visible = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("Interact"):
		interact()

func _on_Area2D_body_entered(body):
	if body.name == "CharacterBody2D":
		player_in_area = true
		$Label.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "CharacterBody2D":
		player_in_area = false
		$Label.visible = false

# Interaction Function
func interact():
	print("Interacted with crate!")
	
	# Choose which crate is interacted with
	match crate_type: 
		"Start": 
			get_tree().change_scene_to_file("res://Battleground.tscn")
