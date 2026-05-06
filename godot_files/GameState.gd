extends Node
signal base_health_changed 

# Store all tower Positions 
var saved_towers: Array = []
var round_counter := 0 
var currency := 500 # Starting currency 
# inventory = { "turret": 2, "basic_tower": 1 }
var inventory := {}
var base_health := 500  # starting health
var is_game_over := false

# Saved Towers 
func save_towers(positions: Array):
	saved_towers = positions.duplicate()

# Get saved towers 
func get_saved_towers() -> Array:
	return saved_towers

# FOR ADDING TOWERS AND PURCHASING 
# Add to inventory 
func add_item(item_id: String, amount := 1):
	if not inventory.has(item_id):
		inventory[item_id] = 0
	inventory[item_id] += amount

# Remove from inventory 
func remove_item(item_id: String, amount := 1) -> bool:
	if not inventory.has(item_id):
		return false
	if inventory[item_id] < amount:
		return false
	
	inventory[item_id] -= amount
	return true
	
# Get item count 
func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)
	
func take_damage(amount):
	if is_game_over:
		return

	base_health -= amount

	if base_health <= 0:
		base_health = 0
		is_game_over = true
		base_health_changed.emit()
		game_over()
	else:
		base_health_changed.emit()
		
func game_over():
	print("GAME OVER")

	# Reset important values
	base_health = 500
	round_counter = 0
	currency = 500
	inventory.clear()
	saved_towers.clear()

	# Go back to main scene
	get_tree().change_scene_to_file("res://menu.tscn")
	
