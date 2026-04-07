extends Node

# Store all tower Positions 
var saved_towers: Array = []
var round_counter := 0 

# Saved Towers 
func save_towers(positions: Array):
	saved_towers = positions.duplicate()

# Get saved towers 
func get_saved_towers() -> Array:
	return saved_towers
