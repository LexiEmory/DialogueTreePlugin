tool
extends HBoxContainer

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_conditonals(newConditonals):
	$Conditional.visible = newConditonals
	$ToolTip.visible = newConditonals


func save_data():
	var dict = {
		"Conditional" : $Conditional.text,
		"ToolTip" : $ToolTip.text,
		"Dialogue" : $Dialogue.text,
	}
	
	return dict

func export_values():
	var dict = {
		"Conditional" : $Conditional.text,
		"ToolTip" : $ToolTip.text,
		"Dialogue" : $Dialogue.text,
		"PassCondition" : true
	}
	
	return dict

func load_data(dict):
	$Conditional.text = dict.Conditional
	$ToolTip.text = dict.ToolTip
	$Dialogue.text = dict.Dialogue