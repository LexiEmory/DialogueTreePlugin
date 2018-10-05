tool
extends GraphNode

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

# used to save node data
func save_data():
	var dict = {
		"filename" : get_filename(),
		"name" : name,
		"rect_x" : rect_position.x,
		"rect_y" : rect_position.y,
		"rect_size_x" : rect_size.x,
		"rect_size_y" : rect_size.y,
		"conditonal" : $Conditional.text
	}
	
	return dict

# used to export node data
func export_values():
	var dict = {
		"NodeName" : name,
		"Ref" : $ReferenceNameEdit.text,
		"Condition" : $Conditional.text
	}
	
	return dict

# used to make connections in export
func make_connection(connection, dict, isEnd = false):
	var convertNext = ["next", "failnext"]
	
	var fromIndex = find_with_name(dict.dialogue, connection.from)
	var toIndex = find_with_name(dict.dialogue, connection.to)
	
	if isEnd:
		dict.dialogue[fromIndex][str(convertNext[connection.from_port])] = "End"
	else:
		if fromIndex != -1 and toIndex != -1:
			dict.dialogue[fromIndex][str(convertNext[connection.from_port])] = toIndex
	
	if !dict.dialogue[fromIndex].has("failnext"):
		dict.dialogue[fromIndex]["failnext"] = "End"
	
	if !dict.dialogue[fromIndex].has("next"):
		dict.dialogue[fromIndex]["next"] = "End"
	
	return dict

# used to load node data
func load_data(dict):
	$Conditional.text = dict.conditonal

# used to find the index of an exported node with a name value
func find_with_name(inArray, inName):
	for i in range(0, inArray.size()):
		if inArray[i].NodeName == inName:
			return i
	
	return -1