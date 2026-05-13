extends Node
signal base_health_changed 
signal currency_changed

# Store all tower Positions 
var saved_towers: Array = []
var round_counter := 0 
var currency := 500 # Starting currency 
# inventory = { "turret": 2, "basic_tower": 1 }
var inventory := {}
var base_health := 500  # starting health
var is_game_over := false
var leaderboard = [] # For leaderboard stats

# On load
func _ready():
	load_game()
	
	
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
	
	# Save score
	add_score("Player", round_counter)

	# SAVE IMMEDIATELY
	save_game()

	# Reset important values
	base_health = 500
	round_counter = 0
	currency = 500
	inventory.clear()
	saved_towers.clear()

	# Go back to main scene
	get_tree().change_scene_to_file("res://menu.tscn")
	
# FOr leaderboard function 
func add_score(player_name: String, score: int):
	leaderboard.append({
		"name": player_name,
		"score": score
	})

	# Sort highest first
	leaderboard.sort_custom(func(a, b): 
		return a["score"] > b["score"]
	)

	# Keep top 10 only
	if leaderboard.size() > 10:
		leaderboard.resize(10)

## Save game
func save_game():
	var save_data = {
		"currency": currency,
		"round_counter": round_counter,
		"inventory": inventory,
		"base_health": base_health,
		"saved_towers": saved_towers, 
		"leaderboard": leaderboard
		
	}

	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

	print("Game Saved")
## Load game
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("No save file found")
		return

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)

	if data:
		currency = data.get("currency", 0)
		round_counter = data.get("round_counter", 1)
		inventory = data.get("inventory", {})
		base_health = data.get("base_health", 300)
		saved_towers = data.get("saved_towers", [])
		leaderboard = data.get("leaderboard", [])

	print("Game Loaded")
	
# Auto save on game close 
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
