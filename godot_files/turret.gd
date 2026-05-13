extends Node2D

@export var show_radius := true
@export var radius_fill_color := Color(0.2, 0.7, 1.0, 0.12)
@export var radius_outline_color := Color(0.2, 0.7, 1.0, 0.55)

var enemies_in_range = []
var last_direction = ""
var max_health = 100.0
var health = max_health
var damage = 10.0
var attacking = false
var target = null

@export var attack_radius := 500.0

@onready var attack_timer = $Timer
@onready var anim_sprite = $AnimatedSprite2D
@onready var detection_shape = $"Area2D (detection)/CollisionShape2D"

func _ready():
	add_to_group("tower")
	last_direction = "s"
	anim_sprite.play("idle_s")
	
	if detection_shape.shape is CircleShape2D:
		detection_shape.shape.radius = attack_radius
	
	queue_redraw()

func _process(delta):
	enemies_in_range = enemies_in_range.filter(func(e): 
		return is_instance_valid(e) and e.health > 0
	)
	if enemies_in_range.size() > 0:
		var closest = get_closest_enemy()
		if closest:
			if not is_instance_valid(target) or closest != target:
				target = closest
				start_attacking(target)
			update_direction_animation(target.global_position)
	else:
		target = null
		stop_attacking()
		
func get_closest_enemy():
	var closest = null
	var closest_dist = INF

	for e in enemies_in_range:
		if not is_instance_valid(e):
			continue
		if e.health <= 0:
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

	if dir != last_direction:
		last_direction = dir
		if not anim_sprite.animation.begins_with("shoot_"):
			anim_sprite.play("idle_" + last_direction)

func take_damage(amount):
	health -= amount
	print("Turret health: ", health)
	
	if health <= 0:
		queue_free()

func start_attacking(new_target):
	target = new_target
	attacking = true
	
	if target != null and is_instance_valid(target):
		update_direction_animation(target.global_position)
		
	if not attack_timer.is_stopped():
		attack_timer.stop()
	
	_on_timer_timeout()
	
	attack_timer.start()

func stop_attacking():
	attacking = false
	target = null
	attack_timer.stop()
	return_to_idle()
	
func return_to_idle():
	if last_direction == "":
		last_direction = "s"
	anim_sprite.stop()
	anim_sprite.play("idle_" + last_direction)
	
func _on_timer_timeout():
	# Clean invalid/dead enemies first
	enemies_in_range = enemies_in_range.filter(func(e): 
		return is_instance_valid(e) and e.health > 0
	)

	# If target is gone or dead, find a new one
	if target == null or not is_instance_valid(target) or target.health <= 0:
		target = get_closest_enemy()
		if target:
			start_attacking(target)
		else:
			stop_attacking()
		return

	# Damage target
	target.take_damage(damage)

	# After damaging, check if that hit killed the enemy
	if not is_instance_valid(target) or target.health <= 0:
		target = null
		return_to_idle()
		
		var new_target = get_closest_enemy()
		if new_target:
			target = new_target
			start_attacking(new_target)
		else:
			stop_attacking()
		
		return

	# Only play shoot animation if enemy is still alive
	update_direction_animation(target.global_position)
	play_shoot_anim()
	
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

func _draw():
	if show_radius and detection_shape and detection_shape.shape is CircleShape2D:
		var center = to_local(detection_shape.global_position)
		
		var circle_shape := detection_shape.shape as CircleShape2D
		var edge_global = detection_shape.global_position + Vector2(circle_shape.radius * detection_shape.global_scale.x, 0)
		var edge_local = to_local(edge_global)
		var visual_radius = center.distance_to(edge_local)
		
		draw_circle(center, visual_radius, radius_fill_color)
		draw_arc(center, visual_radius, 0, TAU, 96, radius_outline_color, 3.0)

func set_radius_visible(value: bool):
	show_radius = value
	queue_redraw()
