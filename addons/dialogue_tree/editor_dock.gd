tool
extends Panel

var current_node = null

const choice_dialogue = preload("res://addons/dialogue_tree/scripts/ChoiceDialogue.gd")
const basic_dialogue = preload("res://addons/dialogue_tree/scripts/BasicDialogue.gd")
const conditonal_dialogue = preload("res://addons/dialogue_tree/scripts/ConditonalDialogue.gd")
const random_dialogue = preload("res://addons/dialogue_tree/scripts/RandomDialogue.gd")
const start_dialogue = preload("res://addons/dialogue_tree/scripts/StartNode.gd")
const end_dialogue = preload("res://addons/dialogue_tree/scripts/EndNode.gd")

func _ready():
	$TopBar/TopContainer/MenuButton.get_popup().connect("id_pressed", self, "_on_menubutton_item_pressed")

# when a button on the add menu is pressed
func _on_menubutton_item_pressed(id):
	# add basic dialogue
	if id == 0:
		var basicDialogue = load("res://addons/dialogue_tree/scenes/BasicDialogue.tscn").instance()
		basicDialogue.connect("close_request", self, "_on_node_close", [basicDialogue])
		basicDialogue.connect("resize_request", self, "_on_node_resize", [basicDialogue])
		
		$PrimaryGraphEditor.add_child(basicDialogue, true)
	if id == 1:
		var conditonalDialogue = load("res://addons/dialogue_tree/scenes/ConditonalDialogue.tscn").instance()
		conditonalDialogue.connect("close_request", self, "_on_node_close", [conditonalDialogue])
		conditonalDialogue.connect("resize_request", self, "_on_node_resize", [conditonalDialogue])
		
		$PrimaryGraphEditor.add_child(conditonalDialogue, true)
	if id == 2:
		var choiceDialogue = load("res://addons/dialogue_tree/scenes/ChoiceDialogue.tscn").instance()
		choiceDialogue.connect("close_request", self, "_on_node_close", [choiceDialogue])
		choiceDialogue.connect("resize_request", self, "_on_node_resize", [choiceDialogue])
		choiceDialogue.connect("removed", self, "remove_connection", [choiceDialogue])
		
		$PrimaryGraphEditor.add_child(choiceDialogue, true)
	if id == 3:
		var randomDialogue = load("res://addons/dialogue_tree/scenes/RandomDialogue.tscn").instance()
		randomDialogue.connect("close_request", self, "_on_node_close", [randomDialogue])
		randomDialogue.connect("resize_request", self, "_on_node_resize", [randomDialogue])
		randomDialogue.connect("removed", self, "remove_connection", [randomDialogue])
		
		$PrimaryGraphEditor.add_child(randomDialogue, true)

# when there is a connection request 
func _on_PrimaryGraphEditor_connection_request(from, from_slot, to, to_slot):
	var all_connections = $PrimaryGraphEditor.get_connection_list() 	# {from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }
	var slot_connections = []
	for connection in all_connections:
		if connection["from"] == from and connection["from_port"] == from_slot:
			slot_connections.append(connection)
	for slot_connection in slot_connections:
		$PrimaryGraphEditor.disconnect_node(slot_connection["from"], slot_connection["from_port"], slot_connection["to"], slot_connection["to_port"])
	
	$PrimaryGraphEditor.connect_node(from, from_slot, to, to_slot)

# when there is a disconnection request
func _on_PrimaryGraphEditor_disconnection_request(from, from_slot, to, to_slot):
	$PrimaryGraphEditor.disconnect_node(from, from_slot, to, to_slot)

# when a graph node is closed
func _on_node_close(ref):
	remove_all_connections(ref)
	ref.queue_free()

# when a graph node is resized
func _on_node_resize(newSize, ref):
	ref.rect_size = newSize

# sets the current node to edit
func set_edit_node(ref):
	clear_all_nodes()
	current_node = ref
	
	if current_node != null and current_node.DialogueResource != null:
		for i in current_node.DialogueResource.Nodes:
			if i["name"] != "StartNode" and i["name"] != "EndNode":
				var newNode = load(i.filename).instance()
				newNode.name = i.name
				newNode.offset = Vector2(i.rect_x, i.rect_y)
				newNode.rect_size = Vector2(i.rect_size_x, i.rect_size_y)
				
				newNode.connect("close_request", self, "_on_node_close", [newNode])
				newNode.connect("resize_request", self, "_on_node_resize", [newNode])
				if newNode is choice_dialogue or newNode is random_dialogue:
					newNode.connect("removed", self, "remove_connection", [newNode])
				
				$PrimaryGraphEditor.add_child(newNode, true)
				
				newNode.load_data(i)
			else:
				var editNode = $PrimaryGraphEditor.get_node(i["name"])
				editNode.offset = Vector2(i["rect_x"], i["rect_y"])
				editNode.rect_size = Vector2(i["rect_size_x"], i["rect_size_y"])
		
		for i in current_node.DialogueResource.connections:
			$PrimaryGraphEditor.connect_node(i.from, i.from_port, i.to, i.to_port)

# saves the resource to the active node
func save_resource():
	# if there is no current resource, create it
	if current_node != null:
		if current_node.DialogueResource == null:
			var newRes = create_resource()
			
			newRes.connections = $PrimaryGraphEditor.get_connection_list()
			
			for i in $PrimaryGraphEditor.get_children():
				if i.has_method("save_data"):
					newRes.Nodes.append(i.save_data())
			
			newRes.DialogueTree = make_exported_dialogue()
			
			ResourceSaver.save(current_node.owner.filename, newRes)
			current_node.DialogueResource = newRes
		else:
			var newRes = current_node.DialogueResource
			newRes.connections = $PrimaryGraphEditor.get_connection_list()
			
			newRes.Nodes.clear()
			
			for i in $PrimaryGraphEditor.get_children():
				if i.has_method("save_data"):
					newRes.Nodes.append(i.save_data())
			
			newRes.DialogueTree = make_exported_dialogue()
			
			ResourceSaver.save(current_node.DialogueResource.resource_path, newRes)

# creates a new dialouge resource
func create_resource():
	var newRes = load("res://addons/dialogue_tree/resource/DialougeRes.tres").duplicate()
	return newRes

# creates a json friendly version of the data for reading
func make_exported_dialogue():
	var exportedDict = {
		"start_index" : 0,
		"dialogue" : []
	}
	
	# add all nodes
	for i in $PrimaryGraphEditor.get_children():
		if i.name != "StartNode" and i.name != "EndNode" and i.has_method("export_values"):
			exportedDict.dialogue.append(i.export_values())
	
	# create connections
	for i in $PrimaryGraphEditor.get_connection_list():
		var fromNode = $PrimaryGraphEditor.get_node(i.from)
		var toNode = $PrimaryGraphEditor.get_node(i.to)
		
		# if we have a starting connection
		if fromNode is start_dialogue:
			var toIndex = find_with_name(exportedDict.dialogue, i.to)
			
			exportedDict.start_index = toIndex
		# for all other node types
		else:
			if fromNode.has_method("make_connection"):
				exportedDict = fromNode.make_connection(i, exportedDict, toNode is end_dialogue)
	
	return exportedDict

# used to find the index of an exported node with a name value
func find_with_name(inArray, inName):
	for i in range(0, inArray.size()):
		if inArray[i].NodeName == inName:
			return i
	
	return -1

# used to clear everything from the graph
func clear_all_nodes():
	$PrimaryGraphEditor.clear_connections()
	for i in $PrimaryGraphEditor.get_children():
		if i is GraphNode and i.name != "StartNode" and i.name != "EndNode":
			i.free()

# removes connections going from an id
func remove_connection(id, node):
	for i in $PrimaryGraphEditor.get_connection_list():
		if i.from == node.name and i.from_port == id:
			$PrimaryGraphEditor.disconnect_node(i.from, i.from_port, i.to, i.to_port)

# used to remove all connections going in or out of a node
func remove_all_connections(node):
	for i in $PrimaryGraphEditor.get_connection_list():
		if i.from == node.name or i.to == node.name:
			$PrimaryGraphEditor.disconnect_node(i.from, i.from_port, i.to, i.to_port)