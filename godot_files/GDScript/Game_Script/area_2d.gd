extends Area2D
@export var crate_type : String = "default"
@onready var shop_ui = get_tree().get_root().get_node("Game/CanvasLayer/ShopUI")

var player_in_area = false

func _ready():
	$Label.visible = false

func _process(_delta):
	if not player_in_area: 
		return 
	match crate_type: 
		"Start": 
			if Input.is_action_just_pressed("Interact"): # Pressed E
				open_battleground("build")
			
			if Input.is_action_just_pressed("start_round"):
				open_battleground("round")
		"TurretShop": 
			if Input.is_action_just_pressed("Interact"): 
				shop_ui.open("turrets")
		"TowerShop": 
			if Input.is_action_just_pressed("Interact"): 
				shop_ui.open("towers")
		
		
func _on_Area2D_body_entered(body):
	if body.name == "CharacterBody2D":
		player_in_area = true
		$Label.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "CharacterBody2D":
		player_in_area = false
		$Label.visible = false

# Open battleground function 
func open_battleground(mode: String):
	var battleground = preload("res://Battleground.tscn").instantiate()

	battleground.mode = mode   # <-- Set the mode BEFORE switching scenes

	# Swap scenes properly
	get_tree().root.add_child(battleground)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battleground

# Turret shop function 
func open_turret_shop():
	var item_id = "turret_basic"
	var data = TowerDatabase.turrets[item_id]

	if GameState.currency >= data.cost:
		GameState.currency -= data.cost
		GameState.add_item(item_id, 1)
		print("Bought turret:", data.name)
	else:
		print("Not enough money")
		
# Tower shop function 
func open_tower_shop():
	var item_id = "blocker_basic"
	var data = TowerDatabase.towers[item_id]

	if GameState.currency >= data.cost:
		GameState.currency -= data.cost
		GameState.add_item(item_id, 1)
		print("Bought tower:", data.name)
	else:
		print("Not enough money")
