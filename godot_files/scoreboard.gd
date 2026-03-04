extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grid = GridContainer.new()
	grid.columns = 3
	add_child(grid)
	
	var label1 = Label.new()
	label1.text = "Rank"
	grid.add_child(label1)
	
	var label2 = Label.new()
	label2.text = "Name"
	grid.add_child(label2)
	
	var label3 = Label.new()
	label3.text = "Score"
	grid.add_child(label3)
	
	
	add_row(grid, "1", "Nathan", "1000")
	add_row(grid, "2", "Eddie", "0900")
	add_row(grid, "3", "Key", "0800")
	add_row(grid, "1", "Hakeem", "0700")
	
func add_row(grid, rank, name, score) :
	var r = Label.new()
	r.text = rank
	grid.add_child(r)
	
	var n = Label.new()
	n.text = name
	grid.add_child(n)
	
	var s = Label.new()
	s.text = score
	grid.add_child(s)
