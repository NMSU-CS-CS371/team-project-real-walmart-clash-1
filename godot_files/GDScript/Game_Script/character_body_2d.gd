extends CharacterBody2D

@export var speed: float = 180.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var can_move := true # keeps track of player movement 

	
# Use your compass directions: N, S, E, W, NE, NW, SE, SW
var last_dir: String = "S"

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vec := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if input_vec.length() > 0:
		velocity = input_vec.normalized() * speed
		play_walk_animation(input_vec)
	else:
		velocity = Vector2.ZERO
		anim.play("Idle_" + last_dir)

	move_and_slide()


func play_walk_animation(v: Vector2) -> void:
	# diagonals
	if v.x > 0 and v.y < 0:
		last_dir = "NE"
		anim.play("Walk_NE")

	elif v.x < 0 and v.y < 0:
		last_dir = "NW"
		anim.play("Walk_NW")

	elif v.x > 0 and v.y > 0:
		last_dir = "SE"
		anim.play("Walk_SE")

	elif v.x < 0 and v.y > 0:
		last_dir = "SW"
		anim.play("Walk_SW")

	# straights
	elif v.x > 0:
		last_dir = "E"
		anim.play("Walk_E")

	elif v.x < 0:
		last_dir = "W"
		anim.play("Walk_W")

	elif v.y < 0:
		last_dir = "N"
		anim.play("Walk_N")

	elif v.y > 0:
		last_dir = "S"
		anim.play("Walk_S")
		
	
# Check if body interacts with crates 
func _input(event):
	if event.is_action_pressed("Interact"): # bind E in InputMap
		for obj in get_tree().get_nodes_in_group("interactable"):
			obj.try_interact()
