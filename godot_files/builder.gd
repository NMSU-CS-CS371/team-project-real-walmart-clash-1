extends Node2D

@export var show_preview_radius := true
@export var radius_fill_color := Color(0.2, 0.7, 1.0, 0.12)
@export var radius_outline_color := Color(0.2, 0.7, 1.0, 0.55)

var current_preview_radius := 0.0
var preview_radius_center := Vector2.ZERO

# References 
@onready var tilemap := $"../Battleground"
@onready var towers := $"../Towers"
@onready var cursor_preview := $CursorPreview
@onready var root := get_parent()
@onready var preview_anim = $CursorPreview/AnimatedSprite2D
@onready var preview_sprite = $CursorPreview/Sprite2D

# Variables 
var available_items: Array = []
var selected_index := 0
var selected_item := ""


var current_tile := Vector2i.ZERO

# Placement bounds
var top_left = Vector2i(-4, 0)
var top_right = Vector2i(0, -8)
var bottom_left = Vector2i(1, 10)
var bottom_right = Vector2i(5, 2)

func _ready():
	update_available_items()

func _process(_delta):
	if root.menu_open:
		return
	
	update_tile_under_mouse()

func _input(event):
	if root.menu_open:
		return

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				change_selection(1)
			MOUSE_BUTTON_WHEEL_DOWN:
				change_selection(-1)
			MOUSE_BUTTON_LEFT:
				try_place_tower()
			MOUSE_BUTTON_RIGHT:
				try_remove_tower()

func update_available_items():
	available_items.clear()

	for id in GameState.inventory:
		if GameState.inventory[id] > 0:
			available_items.append(id)

	if available_items.is_empty():
		selected_item = ""
		cursor_preview.visible = false
		return

	selected_index = 0
	selected_item = available_items[selected_index]
	update_preview_sprite()

func change_selection(direction: int):
	if available_items.is_empty():
		return

	selected_index = (selected_index + direction) % available_items.size()
	selected_item = available_items[selected_index]

	print("Selected:", selected_item)
	update_preview_sprite()

func update_tile_under_mouse():
	var mouse_pos = tilemap.to_local(get_global_mouse_position())
	var tile_pos = tilemap.local_to_map(mouse_pos)

	if tile_pos != current_tile:
		current_tile = tile_pos
		move_cursor_preview()

func move_cursor_preview():
	var world_pos = tilemap.to_global(tilemap.map_to_local(current_tile))
	preview_radius_center = world_pos
	cursor_preview.global_position = world_pos + Vector2(0, -16)

	if can_place_at(current_tile):
		cursor_preview.modulate = Color(0, 1, 0, 0.5)
	else:
		cursor_preview.modulate = Color(1, 0, 0, 0.5)
	queue_redraw()

func _draw():
	if show_preview_radius and cursor_preview.visible and current_preview_radius > 0:
		var center = to_local(preview_radius_center)
		
		draw_circle(center, current_preview_radius, radius_fill_color)
		draw_arc(center, current_preview_radius, 0, TAU, 96, radius_outline_color, 3.0)
		
func can_place_at(tile: Vector2i) -> bool:
	if tilemap.get_cell_tile_data(tile) == null:
		return false

	#if not is_within_bounds(tile):
	#	return false

	var world_pos = tilemap.to_global(tilemap.map_to_local(tile))

	for t in towers.get_children():
		if t.global_position.distance_to(world_pos) < 1:
			return false

	return true

func try_place_tower():
	if not can_place_at(current_tile):
		print("Invalid placement!")
		return
	
	place_tower()

func place_tower():
	if selected_item == "":
		print("No item selected")
		return

	if GameState.get_item_count(selected_item) <= 0:
		print("Out of this item!")
		return

	var scene = get_scene_from_id(selected_item)
	if scene == null:
		print("Invalid item:", selected_item)
		return
	print("Placing item:", selected_item)
	print("Scene returned:", scene)
	

	var t = scene.instantiate()
	t.global_position = tilemap.to_global(tilemap.map_to_local(current_tile))
	
	t.set_meta("id", selected_item)
	towers.add_child(t)

	assign_group(t, selected_item)

	GameState.remove_item(selected_item, 1)
	update_available_items()

	print("Placed:", selected_item)
	get_tree().call_group("hotbar", "refresh")

func try_remove_tower():
	for t in towers.get_children():
		if t.global_position.distance_to(cursor_preview.global_position) < 1:
			print("Removed at:", current_tile)
			t.queue_free()
			
			update_available_items()
			get_tree().call_group("hotbar", "refresh")
			return

	print("No tower here")

func get_scene_from_id(id: String):
	if TowerDatabase.turrets.has(id):
		return TowerDatabase.turrets[id]["scene"]
	elif TowerDatabase.troops.has(id):
		return TowerDatabase.troops[id]["scene"]
	return null

func assign_group(node: Node, id: String):
	if TowerDatabase.turrets.has(id):
		node.add_to_group("turret")
	elif TowerDatabase.troops.has(id):
		node.add_to_group("troop")

func update_preview_sprite():
	if selected_item == "":
		cursor_preview.visible = false
		current_preview_radius = 0.0
		queue_redraw()
		return

	cursor_preview.visible = true

	var scene = get_scene_from_id(selected_item)
	if scene == null:
		current_preview_radius = 0.0
		queue_redraw()
		return

	var temp = scene.instantiate()

	current_preview_radius = 0.0

	if temp.get("attack_radius") != null:
		current_preview_radius = temp.attack_radius

	var anim_sprite = temp.find_child("AnimatedSprite2D", true, false)
	var static_sprite = temp.find_child("Sprite2D", true, false)

	preview_anim.visible = false
	preview_sprite.visible = false

	if anim_sprite:
		preview_anim.visible = true
		preview_anim.sprite_frames = anim_sprite.sprite_frames
		
		var anims = anim_sprite.sprite_frames.get_animation_names()
		if anims.size() > 0:
			preview_anim.play(anims[0])

	elif static_sprite:
		preview_sprite.visible = true
		preview_sprite.texture = static_sprite.texture

	else:
		print("No valid sprite found in scene:", selected_item)

	temp.queue_free()

	queue_redraw()

	print("Preview:", selected_item)
	get_tree().call_group("hotbar", "update_selection")

func is_within_bounds(tile: Vector2i) -> bool:
	var local_pos = tilemap.map_to_local(tile)

	var poly = PackedVector2Array([
		tilemap.map_to_local(top_left),
		tilemap.map_to_local(top_right),
		tilemap.map_to_local(bottom_right),
		tilemap.map_to_local(bottom_left)
	])

	if tile == Vector2i(-1, 7):
		return true

	return Geometry2D.is_point_in_polygon(local_pos, poly)
