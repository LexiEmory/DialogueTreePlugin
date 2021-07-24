tool
extends GraphNode


func _ready():
	pass

func save_data():
	var dict = {
		"filename" : get_filename(),
		"name" : name,
		"rect_x" : offset.x,
		"rect_y" : offset.y,
		"rect_size_x" : rect_size.x,
		"rect_size_y" : rect_size.y
	}
	
	return dict

func load_data(dict):
	pass
