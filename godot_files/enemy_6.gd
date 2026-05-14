extends CharacterBody2D

# Exported Vars 
@export var speed := 50.0
@export var attack_range := 115.0
@export var damage := 50.0
@export var health := 300.0
@export var retarget_interval := 0.2
@export var base_hit_radius := 300.0

# On Ready vars 
@onready var attack_timer = $attack_timer
@onready var anim_sprite = $AnimatedSprite2D

# Vars 
var attacking = false
var target = null
var last_direction := "s"
var goal_tile := Vector2i(-3, -5) # Ultimate enemy goal 
var retarget_time := 0.0
var just_lost_target := false
var dying := false


func _ready():
	print("THIS ENEMY SCRIPT IS RUNNING: ", name)
	add_to_group("enemy")
	target = get_closest_tower()

	# Manually connects timer in case the signal was not connected in Godot
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)


# Finds closest tower target
func get_closest_tower():
	var towers = get_tree().get_nodes_in_group("tower")
	var closest = null
	var closest_distance = INF

	for tower in towers:
		if not is_valid_target(tower):
			continue
		
		var dist = global_position.distance_to(tower.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = tower

	return closest


func _physics_process(delta: float) -> void:
	if dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var root = get_tree().current_scene

	if not root.has_method("is_round_mode") or not root.is_round_mode():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# If the enemy just killed/lost a tower, freeze for one frame
	if just_lost_target:
		just_lost_target = false
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Recheck closest target every small interval
	retarget_time -= delta
	if retarget_time <= 0:
		target = get_closest_tower()
		retarget_time = retarget_interval

	# Debug target check
	if target != null:
		print("Current target: ", target.name, " valid: ", is_valid_target(target))
	else:
		print("Current target is null")
	
	# If target was deleted or is being deleted, clear it safely
	if not is_valid_target(target):
		target = null
		stop_attacking()

	var target_position: Vector2

	# Decide what to move toward
	if is_valid_target(target):
		target_position = target.global_position
	else:
		target_position = get_closest_goal()
		print("Enemy goal position: ", target_position, " enemy position: ", global_position)

	# Safety check: if goal is invalid, stop movement
	if target_position == Vector2.ZERO:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = target_position - global_position
	var distance = direction.length()

	# Prevent weird movement from tiny/invalid direction
	if distance < 1:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# If enemy reaches the base/store
	if target == null and distance <= base_hit_radius:
		attack_base()
		return

	# Attack tower
	if is_valid_target(target) and distance <= attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		attack_target()
	else:
		stop_attacking()
		velocity = direction.normalized() * speed
		move_and_slide()
		update_animation(direction.normalized())

func attack_base():
	if dying:
		return

	print("Enemy reached base and dealt damage: ", damage)

	velocity = Vector2.ZERO
	stop_attacking()

	# Damage the base
	GameState.take_damage(damage)

	# Remove enemy after hitting the base
	queue_free()
	
func attack_target():
	if is_valid_target(target) and target.has_method("take_damage"):
		start_attacking(target)
		play_anim("attack_" + last_direction)
		anim_sprite.speed_scale = 2.0
		print("Enemy is attacking: ", target.name)
	else:
		target = null
		stop_attacking()
		velocity = Vector2.ZERO


func start_attacking(turret):
	if not is_valid_target(turret):
		target = null
		stop_attacking()
		return

	if attacking:
		return

	attacking = true
	target = turret

	if attack_timer.is_stopped():
		attack_timer.start()


func stop_attacking():
	attacking = false

	if not attack_timer.is_stopped():
		attack_timer.stop()

	anim_sprite.speed_scale = 1.0


func take_damage(amount): 
	if dying:
		return
		
	health -= amount
	print("Enemy health: ", health)
	
	if health <= 0:
		die()


func die():
	if dying:
		return

	dying = true
	print("Enemy died")

	# Stop everything
	velocity = Vector2.ZERO
	target = null
	stop_attacking()

	# Remove from enemy group so turrets ignore it
	if is_in_group("enemy"):
		remove_from_group("enemy")

	# Optional: disable collision so it does not block anything while dying
	set_collision_layer(0)
	set_collision_mask(0)

	# Play death animation
	play_anim("nohp_" + last_direction)

	# Wait for animation to finish, then delete
	await anim_sprite.animation_finished

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
	else:
		print("Missing animation: ", anim_name)


func _on_attack_timer_timeout():
	print("Attack timer triggered")

	if is_valid_target(target) and target.has_method("take_damage"):
		print("Damaging target: ", target.name)
		target.take_damage(damage)

		# If target is now dying/deleted, stop immediately
		if not is_valid_target(target):
			print("Target died after damage")
			target = null
			stop_attacking()
			velocity = Vector2.ZERO
			just_lost_target = true
	else:
		print("No valid target in timer")
		target = null
		stop_attacking()
		velocity = Vector2.ZERO
		just_lost_target = true


func get_closest_goal():
	var battleground = get_tree().current_scene

	if not battleground.has_method("get_goal_positions"):
		print("ERROR: current scene does not have get_goal_positions()")
		return global_position

	var goals = battleground.get_goal_positions()

	if goals == null or goals.size() == 0:
		print("ERROR: No goal positions found")
		return global_position

	var closest = goals[0]
	var closest_dist = INF

	for g in goals:
		var dist = global_position.distance_to(g)
		if dist < closest_dist:
			closest_dist = dist
			closest = g

	return closest


func apply_scaling(round: int):
	# -------- HEALTH SCALING --------
	# +0.5% HP every round
	var health_multiplier = 1.0 + (round * 0.005)
	health *= health_multiplier

	# -------- SPEED SCALING --------
	# +5 speed every 5 rounds
	var speed_steps = int(round / 5)
	speed += speed_steps * 5


func is_valid_target(t):
	return t != null and is_instance_valid(t) and not t.is_queued_for_deletion()
