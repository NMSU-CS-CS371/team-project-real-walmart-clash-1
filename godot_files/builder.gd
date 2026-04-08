extends Node2D

# Node references
@onready var tilemap := $"../Battleground"     # Uses battleground tilemap 
@onready var towers := $"../Towers"            # Holds Towers 
@onready var cursor_preview := $CursorPreview  # Holds the tower sprite ## FIX FIX: Need to be able to scroll through different sprites 
@onready var root := get_parent()   # Node containing menu_open
# Variables
var tower_scene := preload("res://turret.tscn") # Tower scene to place
var current_tile := Vector2i.ZERO                           # Tracks the tile the mouse is over


# Called every frame
func _process(delta):
	if root.menu_open: 
		return 
	update_tile_under_mouse()
	


# Tracks the tile under the mouse and updates preview
func update_tile_under_mouse():
	var mouse_pos = get_global_mouse_position()       # Get mouse world position
	var tile_pos = tilemap.local_to_map(mouse_pos)    # Convert to tile coordinates

	# Only update when mouse moves to a new tile
	if tile_pos != current_tile:
		current_tile = tile_pos
		move_cursor_preview()


# Moves the cursor preview sprite to the tile,
# and changes its color depending on if tower exists or not 
func move_cursor_preview():
	var world_pos = tilemap.map_to_local(current_tile)  # Convert tile cords to  world cords
	cursor_preview.global_position = world_pos          # Move preview to that tile

	# Get tile info
	var tile_data = tilemap.get_cell_tile_data(current_tile)

	# No tile = invalid placement (turn red)
	if tile_data == null:
		cursor_preview.modulate = Color(1, 0, 0, 0.5)  # Red transparent
	else:
		cursor_preview.modulate = Color(0, 1, 0, 0.5)  # Green transparent


# Handle input (Mouse click) s
func _input(event):
	if root.menu_open:
		return  # menu open, no clicks 
	# Place tower
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_place_tower()

		if event.button_index == MOUSE_BUTTON_RIGHT:
			try_remove_tower()

# Checks if tower can be removed 
func try_remove_tower():
	# Check if a tower exists close to the cursor preview
	for t in towers.get_children():
		if t.global_position.distance_to(cursor_preview.global_position) < 1:
			print("Tower removed at tile: ", current_tile)
			t.queue_free()
			return
	print("No tower here to remove.")
	
	
# Checks whether a tower can be placed
func try_place_tower():
	var tile_data = tilemap.get_cell_tile_data(current_tile)

	# Don't place if tile DNE 
	if tile_data == null:
		print("Can't build here!")
		return

	# Make sure tile does not already have a tower 
	for t in towers.get_children():
		if t.global_position.distance_to(cursor_preview.global_position) < 1:
			print("Tile already has a tower!")
			return

	# If tile is valid tile, place tower 
	place_tower()


# Place the tower 
func place_tower():
	var t = tower_scene.instantiate()
	t.global_position = cursor_preview.global_position
	towers.add_child(t)
	print("Placed tower at: ", current_tile)
