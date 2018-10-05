# DialogueTreePlugin

A plug-in for godot 3.0 for dialogue trees.

## How-to

Add the plug-in to your project and create a dialogue node. This node will act as the *engine* for that dialogue tree. 

When a dialogue node is selected, the tree editor will open. 

You can add new nodes via the *Add* button. 

The end and start nodes are meant for the beginning and end of the dialouge. 

The dialogue node will never display dialogue. It's up to your to build the front end.


**Note: The tree resource will not save unless you press CTRL+S inside of the tree editor**

## Docs

### Signals

`Dialogue_Next (ref, actor, text)`

Called when a *basic dialogue* is called. 

- ref (string) is the name of the node, given by the first line edit the node
- actor (string) is the name of the actor in the node
- text (string) is the dialouge on the node

`Choice_Next (ref, choices)`

Called when a *choice dialogue* is called.

- ref (string) is the name of the node, given by the first line edit on the node
- choices (array) An array of choices, data will be displayed as follows:

```py
[
  {
    "Conditional" : "Condition here",
    "ToolTip" : "Tooltip here",
    "Dialogue" : "Dialogue here",
    "PassCondition" : true # If the conditon is true. (will not be false if conditionals is false on the node)
  },
  {...}
]
```

`Conditonal_Data_Needed`

Called when the dialogue needs new conditional data. If this is called, the dialogue tree is paused until `send_conditonal_data` is called.

`Dialogue_Started`

Called when dialogue starts.

`Dialogue_Ended`

Called when dialogue ends, rather prematurely, or on purpose.

### Functions

`void start_dialogue(start_at = -1)`

Starts the dialogue. Used to initialize, as well as resume at an index.

If start_at is -1, the dialogue will start at whatever node is connected to the start node.

`void next_dialogue(choice = -1, conditon = -1)`

Causes the dialogue to follow the tree to the next dialogue node. 

- choice (int) will push a choice through.
- conditon (bool) weither or not the conditon to continue is true (meant for internal calling)

`void end_dialogue()`

Prematurely ends the dialogue.

`void send_conditonal_data(dict)`

Sets the custom conditional data. Will continue the dialogue tree.

### Variables


`(int) current_index`

The currently running dialogue tree node. This can be used for loading and saving the current state.

`(bool) in_dialogue`

Whether or not the dialogue tree is running.

`export (bool) RandomizeBeforeRandom`

Whether or not we should call `randomize` before random number generators.

`export (Resource) DialogueResource`

The actual reference to the dialogue resource. This is automatically generated and saved when using the dialogue tree.

### Dialogue nodes

`Basic Dialogue`

This is the most basic version of dialogue. 

- ReferenceName The name of the node. This can be used to call events based on specific dialogue nodes.
- Actor The name of the actor.
- Dialogue The dialogue text.

`Conditonal`

This can be used to control the flow of dialogue. This will automatically call `next_dialogue`, depending on the condition.

- ReferenceName The name of the node. This can be used to call events based on specific dialogue nodes.
- Condition The condition to run (in gdscript) to determine whether or not the *true* output is called. This is formatted with `String.format` with the conditional data given from `send_conditonal_data`

`Choice`

This allows the user (or AI, up to you) to select a choice and effect the dialogue. You can add more choices with the -/+ buttons.

- ReferenceName The name of the node. This can be used to call events based on specific dialogue nodes.
- Conditionals Determines whether or not conditionals should be tested.

`Random`

This randomly selects an output. This will automatically call `next_dialogue`. You can add more choices with the -/+ buttons.

- ReferenceName The name of the node. This can be used to call events based on specific dialogue nodes.
- Conditionals Determines whether or not conditionals should be tested before calling `next_dialogue`
