extends Area2D
@export var crate_texture: Texture2D

# Variables 
var player_in_area = false

func _ready():
	$"../Label".visible = false

# Interaction 
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("Interact"):
		interact()

# Body enter crate area 
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		$Label.visible = true

# Body leaves crate area 
func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		$Label.visible = false

# Function for if "E" is pressed 
func interact():
	print("Interacted with crate!") # Check if working 
