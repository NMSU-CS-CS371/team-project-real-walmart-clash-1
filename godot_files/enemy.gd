extends CharacterBody2D

@export var speed = 60.0
@export var attack_range = 20.0

var target = null
var move_direction = Vector2.LEFT

func _ready():
	add_to_group("enemy")

	var area = $Area2D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if target != null and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed

		if global_position.distance_to(target.global_position) <= attack_range:
			velocity = Vector2.ZERO
			attack_target()
	else:
		velocity = move_direction * speed

	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("turret") or body.is_in_group("wall"):
		target = body

func _on_body_exited(body):
	if body == target:
		target = null

func attack_target():
	print("Attacking target")
