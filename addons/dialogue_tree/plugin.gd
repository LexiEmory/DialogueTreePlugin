tool
extends EditorPlugin

var dock 
var dockButton

const dialogue_script = preload("res://addons/dialogue_tree/scripts/dialogue.gd")
const dialogue_resource_script = preload("res://addons/dialogue_tree/resource/dialogue_tree.gd")

func _enter_tree():
	dock = preload("res://addons/dialogue_tree/editor_dock.tscn").instance()
	
	dockButton = add_control_to_bottom_panel(dock, "Dialogue Tree")
	dockButton.hide()
	
	add_custom_type("Dialogue", "Node", dialogue_script, preload("res://addons/dialogue_tree/assets/Icon.png"))
	add_custom_type("DialogueResource", "Resource", dialogue_resource_script, preload("res://addons/dialogue_tree/assets/ResIcon.png"))

func _exit_tree():
	dock.hide()
	dockButton.hide()
	
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
	
	remove_custom_type("Dialogue")
	remove_custom_type("DialogueResource")

func make_visible(visible):
	dockButton.visible = visible
	
	if !visible:
		dock.visible = false
		dock.set_edit_node(null)

func save_external_data():
	dock.save_resource()

func edit(object):
	if dockButton.pressed:
		dock.visible = true
	
	dock.set_edit_node(object)

func handles(object):
	return object is dialogue_script