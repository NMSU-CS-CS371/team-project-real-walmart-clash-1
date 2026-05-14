extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Purchase tower 
func buy_turret(name: String, cost: int):
	if GameState.currency < cost:
		print("Not enough money")
		return

	GameState.currency -= cost
	GameState.add_tower(name)

	print(name, " purchased!")


func _on_turret_button_pressed(): 
	buy_turret("turret", 100)
