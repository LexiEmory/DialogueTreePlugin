extends Node

signal Dialogue_Next (ref, actor, text)
signal Choice_Next (ref, choices)
signal Conditonal_Data_Needed
signal Dialogue_Started
signal Dialogue_Ended

export (Resource) var DialogueResource = null
export (bool) var RandomizeBeforeRandom = false

var current_index = 0
var in_dialogue = false

var conditonalData = {}
var queued_for_conditonal = false
var current_node = {}

func _ready():
	pass

# used to start dialogue
func start_dialogue(start_at = -1):
	if DialogueResource != null and DialogueResource.DialogueTree != {}:
		# start at first node if no start_at is provided
		emit_signal("Dialogue_Started")
		in_dialogue = true
		var tempIndex = 0
		
		var nodeDict
		if start_at == -1:
			nodeDict = DialogueResource.DialogueTree.dialogue[DialogueResource.DialogueTree.start_index]
			tempIndex = DialogueResource.DialogueTree.start_index
		else:
			nodeDict = DialogueResource.DialogueTree.dialogue[start_at]
			tempIndex = start_at
		
		_process_next(nodeDict, tempIndex)

# used to switch to next dialogue
func next_dialogue(choice = -1, conditon = -1):
	if in_dialogue:
		# get the current dialogue
		var currentDialogue = DialogueResource.DialogueTree.dialogue[current_index]
		# the next dialogue
		var nextDialogueIndex
		# assume choice not taken
		# for safety reasons, assume a node without a connection connects to end
		if choice == -1:
			if int(conditon) == -1:
				if currentDialogue.has("next"):
					nextDialogueIndex = currentDialogue.next
				else:
					end_dialogue()
					return
			else:
				var convertNext = ["failnext", "next"]
				var nextStr = str(convertNext[int(conditon)])
				if current_node.has(nextStr):
					nextDialogueIndex = current_node[nextStr]
		else:
			if currentDialogue.has("Choices"):
				if currentDialogue.Choices[choice].has("next"):
					nextDialogueIndex = currentDialogue.Choices[choice].next
				else:
					end_dialogue()
					return
			elif currentDialogue.has("RandomChoices"):
				if currentDialogue.RandomChoices[choice].has("next"):
					nextDialogueIndex = currentDialogue.RandomChoices[choice].next
				else:
					end_dialogue()
					return
		
		if str(nextDialogueIndex) == "End":
			end_dialogue()
		else:
			var nextDialogue = DialogueResource.DialogueTree.dialogue[nextDialogueIndex]
			_process_next(nextDialogue, nextDialogueIndex)

# processes what to do based on different events
func _process_next(nextDialogue, nextIndex):
	current_node = nextDialogue
	current_index = nextIndex
	
	if nextDialogue.has("Choices"):
		if nextDialogue["Conditonal"]:
			queued_for_conditonal = true
			emit_signal("Conditonal_Data_Needed")
		else:
			emit_signal("Choice_Next", nextDialogue.Ref, nextDialogue.Choices)
	elif nextDialogue.has("RandomChoices"):
		if nextDialogue["Conditonal"]:
			queued_for_conditonal = true
			emit_signal("Conditonal_Data_Needed")
		else:
			if RandomizeBeforeRandom:
				randomize()
			next_dialogue(round(rand_range(0, nextDialogue["RandomChoices"].size() - 1)))
	elif nextDialogue.has("failnext"):
		queued_for_conditonal = true
		emit_signal("Conditonal_Data_Needed")
	else:
		emit_signal("Dialogue_Next", nextDialogue.Ref, nextDialogue.Actor, nextDialogue.Dialogue)

# used to end the dialogue prematurely
func end_dialogue():
	emit_signal("Dialogue_Ended")
	in_dialogue = false

# processing conditonal information
# conditional nodes will automatically skip to whatever node is proper for the operation
func send_conditonal_data(dict):
	if queued_for_conditonal:
		queued_for_conditonal = false
		conditonalData = dict
		if current_node.has("Choices"):
			var ChoicesNew = current_node.Choices
			for i in ChoicesNew:
				i["PassCondition"] = evaluate(str(i["Conditional"]).format(dict))
			emit_signal("Choice_Next", current_node.Ref, ChoicesNew)
		elif current_node.has("failnext"):
			var evaledConditon = evaluate(str(current_node["Condition"]).format(dict))
			next_dialogue(-1, evaledConditon)
		elif current_node.has("RandomChoices"):
			if RandomizeBeforeRandom:
				randomize()
			var selectedChoice = 0
			var choicePassed = false
			
			while !choicePassed:
				selectedChoice = round(rand_range(0, current_node["RandomChoices"].size() - 1))
				choicePassed =  evaluate(str(current_node["RandomChoices"][selectedChoice]["Conditional"]).format(dict))
			
			next_dialogue(selectedChoice)

# evaluates a string in gdscript
func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	
	var obj = Reference.new()
	obj.set_script(script)
	
	return obj.eval()