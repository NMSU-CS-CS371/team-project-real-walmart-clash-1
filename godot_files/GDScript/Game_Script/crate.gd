extends Area2D
@export var crate_type : String = "default"

var player_in_area = false

func _ready():
	$"../Label".visible = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("Interact"):
		interact()

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		$Label.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		$Label.visible = false

# Interact function 
func interact():
	print("Interacted with crate!")
