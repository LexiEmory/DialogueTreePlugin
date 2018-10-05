tool
extends HBoxContainer

func _ready():
	pass

func set_conditonals(newConditonals):
	$Conditonal.visible = newConditonals

func save_data():
	var dict = {
		"Conditional" : $Conditonal.text
	}
	
	return dict

func export_values():
	var dict = {
		"Conditional" : $Conditonal.text,
		"PassCondition" : true
	}
	
	return dict

func load_data(dict):
	$Conditonal.text = dict.Conditional