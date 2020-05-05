extends Node2D
var NeuroPanel = preload("res://NEAT/NeuroPanel.tscn")
var neuroNodesDictionary = {}
var neurosCopy = {}
var listOfConnectionPoints = []


func create(neuros):
	self.neuroNodesDictionary = {}
	
	self.neurosCopy = neuros
	var gridContainer = get_node("GridContainer")
	for neuroId in neuros:
		var newNeuroPanel = NeuroPanel.instance()
		newNeuroPanel.get_node("VBoxContainer").get_child(0).text = str(neuroId)
		self.neuroNodesDictionary[neuroId] = newNeuroPanel
		listOfConnectionPoints.append(newNeuroPanel.get_node("VBoxContainer").get_global_position())
		newNeuroPanel.get_node("VBoxContainer").get_child(1).text = str(neuros[neuroId]["output"])
		gridContainer.add_child(newNeuroPanel)
		if neuros[neuroId]["type"] == "Input":
			newNeuroPanel.modulate = Color(0.0, 0.3, 0.9)
		elif neuros[neuroId]["type"] == "Hidden":
			newNeuroPanel.modulate = Color(1, 1, 1)
		elif neuros[neuroId]["type"] == "Output":
			newNeuroPanel.modulate = Color(0.9, 0.3, 0.0)
	update()
	return self

	
#func _draw():
#	var tempNeuro = {}
#	for neuroId in self.neurosCopy:
#		tempNeuro = self.neurosCopy[neuroId]
#		print(self.neuroNodesDictionary[neuroId].get_node("VBoxContainer").get_global_position())
#		if tempNeuro["type"] == "Hidden":
#			if tempNeuro["expected_inputs"] > 0:
#				for incomingNeuroId in tempNeuro["inputsToNeuro"]:
#					draw_line(self.neuroNodesDictionary[neuroId].get_global_transform()[2], self.neuroNodesDictionary[incomingNeuroId].get_global_transform()[2], Color(1.0, 0.2, 0.2))
#			if len(tempNeuro["outputsFromNeuro"].keys()) > 0:
#				for receivingNeuroId in tempNeuro["outputsFromNeuro"]:
#					draw_line(self.neuroNodesDictionary[neuroId].get_global_transform()[2], Vector2(0,0), Color(1.0, 0.2, 0.2))
#		elif tempNeuro["type"] == "Input":
#			if len(tempNeuro["outputsFromNeuro"].keys()) > 0:
#				for receivingNeuroId in tempNeuro["outputsFromNeuro"]:
#					draw_line(self.neuroNodesDictionary[neuroId].get_global_transform()[2], self.neuroNodesDictionary[receivingNeuroId].get_global_transform()[2], Color(1.0, 0.2, 0.2))
#	self.neurosCopy = {}
	
func _on_CloseButton_pressed():
	self.visible = false

func _on_dataEmittedToVNN(neuros):
	var newNeuroPanel
	for neuroId in neuros:
		newNeuroPanel = get_node(self.neuroNodesDictionary[neuroId].get_path())
		newNeuroPanel.get_node("VBoxContainer").get_child(0).text = str(neuroId)
		newNeuroPanel.get_node("VBoxContainer").get_child(1).text = str(neuros[neuroId]["output"])
