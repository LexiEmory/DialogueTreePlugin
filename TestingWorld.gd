extends Node2D

var apple = 5
var basket = 0

func _ready():
	$Dialogue3.start_dialogue()
	
func _on_Dialogue2_Dialogue_Started():
	pass 

func _on_Dialogue2_Dialogue_Next(ref, actor, text):
	if ref == "Apple" and basket > 0:
		basket -= 1
		apple += 1
	elif ref == "Basket" and apple > 0:
		basket += 1
		apple -= 1
	$CanvasLayer/ChoiceBasic.hide() 
	$CanvasLayer/DialogueBasic.show()
	
	$CanvasLayer/DialogueBasic/Label.text = text
	$CanvasLayer/NextTimer.start()

func _on_Dialogue2_Dialogue_Ended():
	$CanvasLayer/DialogueBasic.hide()
	$CanvasLayer/ChoiceBasic.hide()

func _on_Dialogue2_Choice_Next(ref, choices):
	$CanvasLayer/DialogueBasic.hide() 
	$CanvasLayer/ChoiceBasic.show()
	
	for i in $CanvasLayer/ChoiceBasic/VBoxContainer.get_children():
		i.free()
	
	for i in range(0, choices.size()):
		var newButton = Button.new()
		newButton.text = choices[i].Dialogue
		newButton.connect("pressed", self, "_on_choice_pressed", [i])
		newButton.disabled = !choices[i]["PassCondition"]
		newButton.hint_tooltip = choices[i]["ToolTip"]
		$CanvasLayer/ChoiceBasic/VBoxContainer.add_child(newButton) 

func _on_choice_pressed(id):
	$Dialogue2.next_dialogue(id)
	$Dialogue3.next_dialogue(id)

func _on_NextTimer_timeout():
	$Dialogue2.next_dialogue()
	$Dialogue3.next_dialogue()

func _on_Dialogue2_Conditonal_Data_Needed():
	$Dialogue2.send_conditonal_data({"test" : "hello"})
	$Dialogue3.send_conditonal_data({"apple" : apple, "basket" : basket})
