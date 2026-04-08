extends Node2D

var enemies_in_range = []
var last_direction = ""
var max_health = 100.0
var health = max_health
var damage = 20.0
var attacking = false
var target = null

@onready var attack_timer = $Timer

func _ready():
	add_to_group("tower")

func _process(delta):
	if enemies_in_range.size() > 0:
		var target = get_closest_enemy()
		if target:
			update_direction_animation(target.global_position)

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
	var anim = "Robot_idle_S"

	if angle >= -22.5 and angle < 22.5:
		anim = "Robot_Idle_E"
	elif angle >= 22.5 and angle < 67.5:
		anim = "Robot_idle_SE"
	elif angle >= 67.5 and angle < 112.5:
		anim = "Robot_idle_S"
	elif angle >= 112.5 and angle < 157.5:
		anim = "Robot_idle_WS"
	elif angle >= 157.5 or angle < -157.5:
		anim = "Robot_idle_W"
	elif angle >= -157.5 and angle < -112.5:
		anim = "Robot_idle_NW"
	elif angle >= -112.5 and angle < -67.5:
		anim = "Robot_idle_N"
	elif angle >= -67.5 and angle < -22.5:
		anim = "Robot_idle_NE"

	if anim != last_direction:
		last_direction = anim
		$AnimatedSprite2D.play(anim)

func take_damage(amount):
	health -= amount
	print("Turret health: ", health)
	
	if health <= 0:
		queue_free()

func start_attacking(turret):
	if attacking:
		return

	attacking = true
	target = turret
	attack_timer.start()

func stop_attacking():
	attacking = false
	attack_timer.stop()

func _on_timer_timeout():
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
	else:
		stop_attacking()

func _on_area_2d_detection_body_entered(body):
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)
		start_attacking(body)

func _on_area_2d_detection_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)
