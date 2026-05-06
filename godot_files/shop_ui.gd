extends CanvasLayer
# Vars
@onready var container = $Panel/VBoxContainer
@onready var money_label = $Panel/MoneyLabel
@onready var error_label = $Panel/ErrorLabel
var current_category = "turrets" # or "towers"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


#  Handle input 
func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled() 

# Open the panel 
func open(category: String):
	current_category = category
	visible = true
	populate_shop()
	get_tree().paused = true
	
	# Parent scene menu 
	var root = get_tree().current_scene
	root.menu_open = true 
	# Stop player movement 
	var player = root.get_node("_Leader_")
	
	player.can_move = false

func close():
	visible = false
	get_tree().paused = false # Handles closing the shop UI 
	# Override menu esc input 
	var root = get_tree().current_scene
	root.menu_open = false
	
	# Resume player movement 
	var player = root.get_node("_Leader_")
	player.can_move = true

func populate_shop():
	money_label.text = "Money: $" + str(GameState.currency)
	# Clear old buttons
	for child in container.get_children():
		child.queue_free()

	var data_set = get_data_set()

	for id in data_set.keys():
		var data = data_set[id]

		var btn = Button.new()
		btn.text = data.name + " ($" + str(data.cost) + ")"

		btn.pressed.connect(func():
			buy_item(id)
		)

		container.add_child(btn)

# Get data 
func get_data_set():
	if current_category == "turrets":
		return TowerDatabase.turrets
	else:
		return TowerDatabase.towers

# Buy item function 
func buy_item(item_id: String):
	var data = get_data_set()[item_id]

	if GameState.currency >= data.cost:
		GameState.currency -= data.cost
		GameState.add_item(item_id, 1)
		print("Bought:", data.name)
		# Hide no money label if there is money 
		error_label.visible = false 
		# Update money label
		populate_shop()
		print(GameState.inventory)
	else:
		# Show no money 
		show_error()
		print("Not enough money")
		
# Function to prevent label from showing infinetly 
func show_error():
	error_label.visible = true
	await get_tree().create_timer(0.5).timeout
	error_label.visible = false
