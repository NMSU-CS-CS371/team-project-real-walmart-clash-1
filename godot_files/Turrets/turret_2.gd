extends Node2D

var enemies_in_range = []
var last_direction = ""
var max_health = 100.0
var health = max_health
var damage = 35.0
var attacking = false
var target = null

@export var attack_radius := 400.0

@onready var attack_timer = $Timer
@onready var anim_sprite = $AnimatedSprite2D
@onready var laser = $Laser
@onready var detection_shape = $"Area2D (detection)/CollisionShape2D"

func _ready():
	add_to_group("tower")
	
	if detection_shape.shape is CircleShape2D:
		detection_shape.shape.radius = attack_radius
	

func _process(delta):
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.size() > 0:
		var closest = get_closest_enemy()
		if closest:
			if not is_instance_valid(target) or closest != target:
				target = closest
				start_attacking(target)
			update_direction_animation(target.global_position)
	else:
		# No enemies left, stop attacking
		target = null
		stop_attacking()
		
func get_closest_enemy():
	var closest = null
	var closest_dist = INF

	for e in enemies_in_range:
		if not is_instance_valid(e):
			continue

		var dist = global_position.distance_to(e.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = e

	return closest

func update_direction_animation(target_pos: Vector2):
	var direction = (target_pos - global_position).normalized()
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

	if dir != last_direction and not anim_sprite.animation.begins_with("Robot_shoot_"):
		last_direction = dir
		anim_sprite.play("idle_" + last_direction)

func take_damage(amount):
	health -= amount
	print("Turret health: ", health)
	
	if health <= 0:
		queue_free()

func start_attacking(new_target):
	target = new_target
	attacking = true
	if not attack_timer.is_stopped():
		attack_timer.stop()
	attack_timer.start()

func stop_attacking():
	attacking = false
	target = null
	attack_timer.stop()
	laser.visible = false
	
func flash_laser():
	if not is_instance_valid(target):
		return
	# Draw line from turret to enemy
	laser.clear_points()
	laser.add_point(Vector2.ZERO)
	laser.add_point(to_local(target.global_position))
	laser.visible = true
	# Hide it again after a short moment
	await get_tree().create_timer(0.08).timeout
	laser.visible = false

func _on_timer_timeout():
	# Clean dead enemies first
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	if target and is_instance_valid(target):
		target.take_damage(damage)
		flash_laser()
		#this plays atack animation in the current direction
		play_shoot_anim()
	else:
		# Target is gone, grab the next closest
		target = get_closest_enemy()
		if target:
			start_attacking(target)
		else:
			stop_attacking()
func play_shoot_anim():
	# last_direction already holds e, ne, n, nw
	var anim = "shoot_" + last_direction
	anim_sprite.play(anim)

func _on_area_2d_detection_body_entered(body):
	if body.is_in_group("enemy"):
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)

func _on_area_2d_detection_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)
		# If the target just walked out, switch to next closest
		if body == target:
			target = get_closest_enemy()
			if target:
				start_attacking(target)
			else:
				stop_attacking()
