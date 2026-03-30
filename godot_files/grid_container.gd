extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	var num = randi_range(0001, 1000)
	var num1 = randi_range(0001, 1000)
	var num2 = randi_range(0001, 1000)
	var num3 = randi_range(0001, 1000)
	
	var values =[ {"name": "Nathan", "score": num},
					{"name": "Eddy", "score": num1},
					{"name": "Hakeem", "score": num2},
					{"name": "Key", "score": num3}]
	sort_leader(values)
	for i in range(values.size()):
		var player = values[i]
		add_row(i + 1, player["name"], player["score"])

func sort_leader (arr):
	arr.sort_custom(func(a,b): return a["score"] > b["score"])

func add_row(rank, name, score):
	add_child(add_label(rank))
	add_child(add_label(name))
	add_child(add_label(score))

func add_label(text):
	var label = Label.new()
	label.text = str(text)
	
	#var font = #can be used to change font
	#label.add_theme_font_override("font", font) #adds the font from above
	
	#the size of the font
	label.add_theme_font_size_override("font_size", 30) 
	
	#adds clear box behind labels
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 0.5, 0.4)
	label. add_theme_stylebox_override("normal", style)
	
	#makes clear box seemless
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(0, 50)
	return label
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
