extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Start button
@onready var start_button = $TextureButton1

func _on_texture_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_texture_button_1_mouse_entered():
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(1.2,1.2), 0.2)
	
func _on_texture_button_1_mouse_exited():
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(1,1), 0.2)

# Leaderboard button
@onready var leader_board_b = $TextureButton2

func _on_texture_button_2_pressed() -> void: 
	get_tree().change_scene_to_file("res://leaderboard.tscn")

func _on_texture_button_2_mouse_entered():
	var tween = create_tween()
	tween.tween_property(leader_board_b, "scale", Vector2(1.2,1.2), 0.2)
	
func _on_texture_button_2_mouse_exited():
	var tween = create_tween()
	tween.tween_property(leader_board_b, "scale", Vector2(1,1), 0.2)

#  Exit button 
@onready var exit_button = $TextureButton3

func _on_texture_button_3_pressed() -> void: 
	get_tree().quit()

func _on_texture_button_3_mouse_entered():
	var tween = create_tween()
	tween.tween_property(exit_button, "scale", Vector2(1.2,1.2), 0.2)
	
func _on_texture_button_3_mouse_exited():
	var tween = create_tween()
	tween.tween_property(exit_button, "scale", Vector2(1,1), 0.2)
	
