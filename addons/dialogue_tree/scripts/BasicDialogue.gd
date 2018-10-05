tool
extends GraphNode

func _ready():
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
		"Actor" : $ActorNameEdit.text,
		"Dialogue" : $DialogueEdit.text,
		"RefName" : $ReferenceNameEdit.text
	}
	
	return dict

# used to export node data
func export_values():
	var dict = {
		"NodeName" : name,
		"Ref" : $ReferenceNameEdit.text,
		"Dialogue" : $DialogueEdit.text,
		"Actor" : $ActorNameEdit.text
	}
	
	return dict

# used to make connections in export
func make_connection(connection, dict, isEnd = false):
	var fromIndex = find_with_name(dict.dialogue, connection.from)
	var toIndex = find_with_name(dict.dialogue, connection.to)
	
	if isEnd:
		dict.dialogue[fromIndex]["next"] = "End"
	else:
		if fromIndex != -1 and toIndex != -1:
			dict.dialogue[fromIndex]["next"] = toIndex
	
	return dict

# used to load node data
func load_data(dict):
	$ActorNameEdit.text = dict.Actor
	$DialogueEdit.text = dict.Dialogue
	$ReferenceNameEdit.text = dict.RefName

# used to find the index of an exported node with a name value
func find_with_name(inArray, inName):
	for i in range(0, inArray.size()):
		if inArray[i].NodeName == inName:
			return i
	
	return -1