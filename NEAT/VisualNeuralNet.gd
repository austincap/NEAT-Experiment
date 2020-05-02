extends Node
var NeuroPanel = preload("res://NEAT/NeuroPanel.tscn")

func create(neuros):
	var gridContainer = get_node("GridContainer")
	for neuroId in neuros:
		var newNeuroPanel = NeuroPanel.instance()
		newNeuroPanel.get_node("VBoxContainer").get_child(0).text = str(neuroId)
		newNeuroPanel.get_node("VBoxContainer").get_child(1).text = str(neuros[neuroId]["output"])
		gridContainer.add_child(newNeuroPanel)
		if neuros[neuroId]["type"] == "Input":
			newNeuroPanel.modulate = Color(0.0, 0.3, 0.9)
		elif neuros[neuroId]["type"] == "Hidden":
			newNeuroPanel.modulate = Color(1, 1, 1)
		elif neuros[neuroId]["type"] == "Output":
			newNeuroPanel.modulate = Color(0.9, 0.3, 0.0)
	return self

func _on_CloseButton_pressed():
	self.get_parent().showingVNN = false
	self.queue_free()
