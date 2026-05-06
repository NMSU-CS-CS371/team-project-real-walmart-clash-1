extends Node

# Holds turrets 
var turrets = {
	"turret_basic": {
		"scene": preload("res://Turrets/turret.tscn"),
		"cost": 100,
		"name": "Sniper Turret"
	},
	"turret_2": {
		"scene": preload("res://Turrets/turret_2.tscn"),
		"cost": 150,
		"name": "Machince Gun Turret"
	},
	"turret_3": {
		"scene": preload("res://Turrets/turret_3.tscn"),
		"cost": 250,
		"name": "Bomb Turret"
	},
	"turret_4": {
		"scene": preload("res://Turrets/turret_4.tscn"),
		"cost": 500,
		"name": "Omega Turret"
	},
}
# Holds towers as
var troops = {
	"troop_basic": {
		"scene": preload("res://Towers/basic_tower.tscn"),
		"cost": 50,
		"name": "Bat Troop"
	},
"second_troop": {
	"scene": preload("res://Towers/second_tower.tscn"),
	"cost": 100,
	"name": "Hammer Troop"
},
"third_troop": {
	"scene": preload("res://Towers/third_tower.tscn"),
	"cost": 150,
	"name": "Chainsaw Troop"
},
"fourth_troop": {
	"scene": preload("res://Towers/fourth_tower.tscn"),
	"cost": 200,
	"name": "Sword Troop"
},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
