extends Node

# Store health 
var health := 500

# Store takes damage when enemy enters goal vectors 
func take_damage(amount):
	health -= amount
	print("Store HP:", health)
	
	if health <= 0:
		print("Game Over")
