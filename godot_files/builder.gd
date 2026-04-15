extends Node2D

# Node references
@onready var tilemap := $"../Battleground"     # Uses battleground tilemap 
@onready var towers := $"../Towers"            # Holds Towers 
@onready var cursor_preview := $CursorPreview  # Holds the tower sprite ## FIX FIX: Need to be able to scroll through different sprites 
@onready var root := get_parent()   # Node containing menu_open
# Variables
var tower_scene := preload("res://turret.tscn") # Tower scene to place
var current_tile := Vector2i.ZERO                           # Tracks the tile the mouse is over
# Boundary vector tiles 
var topLeft = Vector2(-4,0)
var topRight = Vector2(0,-8)
var bottomLeft = Vector2(1,10)
var bottomRight = Vector2(5,2)


# Called every frame
func _process(delta):
	if root.menu_open: 
		return 
	update_tile_under_mouse()
	

# Check if tower placement is in boundary
func is_within_bounds(tile: Vector2i) -> bool:
	var world_pos = tilemap.map_to_local(tile)
	
	var poly = PackedVector2Array([
		tilemap.map_to_local(Vector2i(topLeft)),
		tilemap.map_to_local(Vector2i(topRight)),
		tilemap.map_to_local(Vector2i(bottomRight)),
		tilemap.map_to_local(Vector2i(bottomLeft))
	])
	# For tile (-1,7) fix 
	if tile == Vector2i(-1,7): 
		return true
		
	return Geometry2D.is_point_in_polygon(world_pos, poly)

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
	var world_pos = tilemap.map_to_local(current_tile)
	cursor_preview.global_position = world_pos

	if can_place_at(current_tile):
		cursor_preview.modulate = Color(0, 1, 0, 0.5)  # Green
	else:
		cursor_preview.modulate = Color(1, 0, 0, 0.5)  # Redent


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

# See if tower can be placed 
func can_place_at(tile: Vector2i) -> bool: 
	var tile_data = tilemap.get_cell_tile_data(tile)
	# No tile = Invalid 
	if tile_data == null: 
		return false 
	
	#Outside of bounds
	if not is_within_bounds(tile): 
		return false 
	# Tile already has tower 
	for t in towers.get_children(): 
		if t.global_position.distance_to(tilemap.map_to_local(tile)) < 1: 
			return false
	return true
	
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
	if not can_place_at(current_tile):
		print("Invalid placement!")
		return
	place_tower()


# Place the tower 
func place_tower():
	var t = tower_scene.instantiate()
	t.global_position = cursor_preview.global_position
	towers.add_child(t)
	t.add_to_group("tower") #for tower targeting
	print("Placed tower at: ", current_tile)
