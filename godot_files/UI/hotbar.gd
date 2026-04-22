extends Control

@onready var container = $HBoxContainer
var slot_scene = preload("res://UI/Hotbar.tscn")

var builder = null  # reference to builder

func _ready():
	# find builder automatically
	builder = get_tree().get_nodes_in_group("builder")[0]
	refresh()

func refresh():
	# Clear old slots
	for c in container.get_children():
		c.queue_free()

	for id in builder.available_items:
		var slot = slot_scene.instantiate()
		
		var data = get_data(id)
		
		# Set icon
		var icon = get_icon_from_scene(data.scene)
		slot.get_node("TextureRect").texture = icon
		
		# Set count
		var count = GameState.get_item_count(id)
		slot.get_node("Label").text = "x" + str(count)

		container.add_child(slot)

	update_selection()

func update_selection():
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		
		if i == builder.selected_index:
			slot.modulate = Color(1,1,1,1)  # highlighted
			slot.scale = Vector2(1.2, 1.2)
		else:
			slot.modulate = Color(1,1,1,0.5)
			slot.scale = Vector2(1,1)

func get_data(id):
	if TowerDatabase.turrets.has(id):
		return TowerDatabase.turrets[id]
	return TowerDatabase.towers[id]

func get_icon_from_scene(scene):
	var temp = scene.instantiate()

	var sprite = temp.find_child("Sprite2D", true, false)
	var anim = temp.find_child("AnimatedSprite2D", true, false)

	var texture = null

	if sprite:
		texture = sprite.texture
	elif anim:
		texture = anim.sprite_frames.get_frame_texture(anim.animation, 0)

	temp.queue_free()
	return texture
