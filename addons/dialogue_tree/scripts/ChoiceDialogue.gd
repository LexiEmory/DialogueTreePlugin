tool
extends GraphNode

signal removed (id)

const choiceContainer = preload("res://addons/dialogue_tree/scripts/ChoiceContainer.gd")

func _ready():
	pass

# used for saving node data
func save_data():
	var dict = {
		"filename" : get_filename(),
		"name" : name,
		"rect_x" : rect_position.x,
		"rect_y" : rect_position.y,
		"rect_size_x" : rect_size.x,
		"rect_size_y" : rect_size.y,
		"Conditonal" : $EditChoices/Conditonals.pressed,
		"RefName" : $ReferenceNameEdit.text,
		"choices" : []
	}
	
	for i in get_children():
		if i is choiceContainer:
			dict.choices.append(i.save_data())
	
	return dict

# used for exporting node data
func export_values():
	var dict = {
		"NodeName" : name,
		"Ref" : $ReferenceNameEdit.text,
		"Conditonal" : $EditChoices/Conditonals.pressed,
		"Choices" : []
	}
	
	for i in get_children():
		if i is choiceContainer:
			dict.Choices.append(i.export_values())
	
	return dict

# used as offloading the connection processing to the node itself in export
func make_connection(connection, dict, isEnd = false):
	var fromIndex = find_with_name(dict.dialogue, connection.from)
	var toIndex = find_with_name(dict.dialogue, connection.to)
	
	if isEnd:
		dict.dialogue[fromIndex]["Choices"][connection.from_port]["next"] = "End"
	else:
		if fromIndex != -1 and toIndex != -1:
			dict.dialogue[fromIndex]["Choices"][connection.from_port]["next"] = toIndex
	
	return dict

# used to load node data
func load_data(dict):
	$EditChoices/Conditonals.pressed = dict.Conditonal
	$ReferenceNameEdit.text = dict.RefName
	var choiceContainerPacked = load("res://addons/dialogue_tree/scenes/ChoiceContainer.tscn")
	for i in dict.choices:
		var newChoice = choiceContainerPacked.instance()
		newChoice.load_data(i)
		add_child(newChoice) 
		set_slot(get_child_count() - 1, false, 0, Color(1, 1, 1), true, 0, Color(1, 1, 1))
		if newChoice.has_method("set_conditonals"):
			newChoice.set_conditonals($EditChoices/Conditonals.pressed)

func _on_PlusButton_pressed():
	var newChoice = load("res://addons/dialogue_tree/scenes/ChoiceContainer.tscn").instance()
	add_child(newChoice) 
	set_slot(get_child_count() - 1, false, 0, Color(1, 1, 1), true, 0, Color(1, 1, 1))
	if newChoice.has_method("set_conditonals"):
		newChoice.set_conditonals($EditChoices/Conditonals.pressed)

func _on_MinusButton_pressed():
	var child = get_child(get_child_count() - 1)
	if child is HBoxContainer:
		emit_signal("removed", get_child_count() - 4)
		clear_slot(get_child_count() - 1)
		child.queue_free() 

func _on_Conditonals_toggled(button_pressed):
	for i in get_children():
		if i.has_method("set_conditonals"):
			i.set_conditonals(button_pressed)

# used to find the index of an exported node with a name value
func find_with_name(inArray, inName):
	for i in range(0, inArray.size()):
		if inArray[i].NodeName == inName:
			return i
	
	return -1