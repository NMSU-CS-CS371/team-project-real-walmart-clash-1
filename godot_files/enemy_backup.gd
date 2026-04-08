extends CharacterBody2D

@export var speed := 100.0
@export var attack_range := 100.0
@export var damage := 30.0
@export var health := 50.0

@onready var attack_timer = $attack_timer

var attacking = false
var target = null
var last_direction := "s"

func _ready():
	target = get_closest_tower()

#finds closest target
func get_closest_tower():
	var towers = get_tree().get_nodes_in_group("tower")
	var closest = null
	var closest_distance = INF

	for tower in towers:
		if not is_instance_valid(tower):
			continue
		
		var dist = global_position.distance_to(tower.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = tower

	return closest

func _physics_process(delta: float) -> void:
	var root = get_tree().current_scene
	if not root.has_method("is_round_mode") or not root.is_round_mode():
		velocity = Vector2.ZERO
		return

	if target == null or not is_instance_valid(target):
		target = get_closest_tower()
		if target == null:
			velocity = Vector2.ZERO
			play_anim("idle_" + last_direction)
			return

	var direction = target.global_position - global_position
	var distance = direction.length()

	if distance > attack_range:
		stop_attacking()
		velocity = direction.normalized() * speed
		move_and_slide()
		update_animation(direction.normalized())
	else:
		velocity = Vector2.ZERO
		attack_target()

func attack_target():
	if target and is_instance_valid(target):
		if target and target.has_method("take_damage"):
			start_attacking(target)
			play_anim("attack_" + last_direction)
			$AnimatedSprite2D.speed_scale = 2.0
			print("Enemy is attacking: ", target.name)

func start_attacking(turret):
	if attacking:
		return

	attacking = true
	target = turret
	attack_timer.start()

func stop_attacking():
	attacking = false
	attack_timer.stop()

func take_damage(amount): 
	health -= amount
	print("Enemy health: ", health)
	
	if health <= 0:
		is_dead()

func is_dead():
	play_anim("nohp_" + last_direction)
	queue_free()

func update_animation(direction: Vector2):
	var angle = rad_to_deg(direction.angle())
	var dir = "s"
	
	if angle >= -22.5 and angle < 22.5:
		dir = "e"
	elif angle >= 22.5 and angle < 67.5:
		dir = "se"
	elif angle >= 67.5 and angle < 112.5:
		dir = "s"
	elif angle >= 112.5 and angle < 157.5:
		dir = "sw"
	elif angle >= 157.5 or angle < -157.5:
		dir = "w"
	elif angle >= -157.5 and angle < -112.5:
		dir = "nw"
	elif angle >= -112.5 and angle < -67.5:
		dir = "n"
	elif angle >= -67.5 and angle < -22.5:
		dir = "ne"
	
	last_direction = dir
	play_anim("walk_" + last_direction)
	
func play_anim(anim_name: String):
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_attack_timer_timeout():
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
	else:
		stop_attacking()
	
