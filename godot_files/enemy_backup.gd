extends CharacterBody2D

# Exported Vars 
@export var speed := 100.0
@export var attack_range := 100.0
@export var damage := 20.0
@export var health := 50.0
@export var retarget_interval := 0.2
# On Read vars 
@onready var attack_timer = $attack_timer
# Vars 
var attacking = false
var target = null
var last_direction := "s"
var goal_tile := Vector2i(-3,-5) # Ultimate enemy goal 
var retarget_time := 0

func _ready():
	add_to_group("enemy")
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
	
	# Recheck closet target ever small interval
	retarget_time -= delta
	if retarget_time <= 0:
		target = get_closest_tower()
	retarget_time = retarget_interval
	
	var target_position: Vector2


	# Decide what to move toward
	if target and is_instance_valid(target):
		target_position = target.global_position
	else:
		target_position = get_closest_goal()

	var direction = target_position - global_position
	var distance = direction.length()
	
	# Check if ienemy is in store range 
	if target == null and distance < 20:
		velocity = Vector2.ZERO
		
		# Damage the base/store
		GameState.take_damage(damage)  # or StoreManager
		
		queue_free()  # remove enemy after hitting base
		return

	if target and is_instance_valid(target) and distance <= attack_range:
		velocity = Vector2.ZERO
		attack_target()
	else:
		stop_attacking()
		velocity = direction.normalized() * speed
		move_and_slide()
		update_animation(direction.normalized())

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
		die()

func die():
	print("Enemy died")
	#play_anim("nohp_" + last_direction)
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
	
func get_closest_goal():
	var battleground = get_tree().current_scene
	var goals = battleground.get_goal_positions()

	var closest = null
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
