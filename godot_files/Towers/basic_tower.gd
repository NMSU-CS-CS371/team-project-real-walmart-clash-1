extends CharacterBody2D

@export var speed := 120.0
@export var attack_range := 40.0
@export var damage := 20.0
@export var health := 50.0
@export var retarget_interval := 0.2

@onready var attack_timer = $Timer
@onready var anim_sprite = $Area2D/AnimatedSprite2D
@onready var detection_shape = $"Area2D (detection)/CollisionShape2D"

var attacking := false
var target = null
var last_direction := "s"
var retarget_time := 0
var placement_position : Vector2

func _ready():
	add_to_group("troop")
	placement_position = global_position
	target = get_closest_enemy()

func _process(delta):
	var root = get_tree().current_scene
	if not root.has_method("is_round_mode") or not root.is_round_mode():
		play_anim("idle_" + last_direction)
		return
	
	retarget_time -= delta
	if retarget_time <= 0:
		target = get_closest_enemy()
		retarget_time = retarget_interval
		
	if target == null or not is_instance_valid(target):
		target = get_closest_enemy()

	if target == null:
		play_anim("idle_" + last_direction)
		return

	var direction = target.global_position - global_position
	var distance = direction.length()

	if distance <= attack_range:
		attack_target()
	else:
		stop_attacking()
		velocity = direction.normalized() * speed
		move_and_slide()
		update_animation(direction.normalized())

func get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest = null
	var closest_distance = INF

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = enemy

	return closest

func attack_target():
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		start_attacking(target)
		play_anim("attack_" + last_direction)

func start_attacking(new_target):
	if attacking:
		return

	attacking = true
	target = new_target
	attack_timer.start()

func stop_attacking():
	attacking = false
	if not attack_timer.is_stopped():
		attack_timer.stop()

func _on_attack_timer_timeout():
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
	else:
		stop_attacking()
		target = get_closest_enemy()

func take_damage(amount):
	health -= amount
	print("Troop health:", health)

	if health <= 0:
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
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		if anim_sprite.animation != anim_name:
			anim_sprite.play(anim_name)

func _on_timer_timeout():
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		print("Troop damaging enemy")
		target.take_damage(damage)
	else:
		stop_attacking()
		target = get_closest_enemy()

func reset_to_placement_position():
	global_position = placement_position
	target = null
	attacking = false
	
	if not attack_timer.is_stopped():
		attack_timer.stop()
	
	play_anim("idle_" + last_direction)
