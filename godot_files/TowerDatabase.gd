extends Node
# Holds turrets 
var turrets = {
	"turret_basic": {
		"scene": preload("res://Turrets/turret.tscn"),
		"cost": 100,
		"name": "Basic Turret"
	}
}
# Holds towers as
var towers = {
	"blocker_basic": {
		"scene": preload("res://Towers/basic_tower.tscn"),
		"cost": 50,
		"name": "Block Tower"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
