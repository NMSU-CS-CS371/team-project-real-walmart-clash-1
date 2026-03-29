extends Node2D

func _ready():
	for crate in get_tree().get_nodes_in_group("interactable"):
		crate.connect("interacted", Callable(self, "_on_crate_interacted"))

func _on_crate_interacted(type, scene_to_open):
	if type == "change_scene":
		get_tree().change_scene_to_file(scene_to_open)
	elif type == "popup":
		$UI/MyPopup.show()
