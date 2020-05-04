extends Node
var NeuroPanel = preload("res://NEAT/NeuroPanel.tscn")
var neuroNodesDictionary = {}
var tempLineCoordinates = []

func create(neuros):
	self.neuroNodesDictionary = {}
	var gridContainer = get_node("GridContainer")
	for neuroId in neuros:
		var newNeuroPanel = NeuroPanel.instance()
		newNeuroPanel.get_node("VBoxContainer").get_child(0).text = str(neuroId)
		self.neuroNodesDictionary[neuroId] = newNeuroPanel
		newNeuroPanel.get_node("VBoxContainer").get_child(1).text = str(neuros[neuroId]["output"])
		gridContainer.add_child(newNeuroPanel)
		if neuros[neuroId]["type"] == "Input":
			newNeuroPanel.modulate = Color(0.0, 0.3, 0.9)
		elif neuros[neuroId]["type"] == "Hidden":
			newNeuroPanel.modulate = Color(1, 1, 1)
		elif neuros[neuroId]["type"] == "Output":
			newNeuroPanel.modulate = Color(0.9, 0.3, 0.0)
#	for neuroId in neuros:
#		#var line = Line2D.new()
#		#line.width = 22.0
#		var test = CanvasItem.new()
#
#		#line.add_point(self.neuroNodesDictionary[neuroId].get_position())
#		if neuros[neuroId]["type"] == "Hidden":
#			print(self.neuroNodesDictionary[neuroId].get_position())
#			if neuros[neuroId]["expected_inputs"] > 0:
#				for incomingNeuroId in neuros[neuroId]["inputsToNeuro"]:
#					test.draw_line(self.neuroNodesDictionary[neuroId].get_position(), Vector2(0, 0), Color(1.0, 0.2, 0.2))
#					#line.add_point(self.neuroNodesDictionary[incomingNeuroId].get_position())
#					#line.draw_line()
#					#line = [self.neuroNodesDictionary[neuroId].get_position(), self.neuroNodesDictionary[incomingNeuroId].get_position()]
#			if len(neuros[neuroId]["outputsFromNeuro"].keys()) > 0:
#				for receivingNeuroId in neuros[neuroId]["outputsFromNeuro"]:
#					test.draw_line(self.neuroNodesDictionary[neuroId].get_position(), self.neuroNodesDictionary[receivingNeuroId].get_position(), Color(1.0, 0.2, 0.2))
#					#line.points = [self.neuroNodesDictionary[neuroId].get_position(), self.neuroNodesDictionary[receivingNeuroId].get_position()]
#		elif neuros[neuroId]["type"] == "Input":
#			if len(neuros[neuroId]["outputsFromNeuro"].keys()) > 0:
#				var teset = CanvasItem.new()
#				for receivingNeuroId in neuros[neuroId]["outputsFromNeuro"]:
#					teset.draw_line(self.neuroNodesDictionary[neuroId].get_position(), self.neuroNodesDictionary[receivingNeuroId].get_position(), Color(1.0, 0.2, 0.2))
#					#test.update()
	return self

#func _draw():
#	test.draw_line(self.neuroNodesDictionary[neuroId].get_position(), self.neuroNodesDictionary[receivingNeuroId].get_position(), Color(1.0, 0.2, 0.2))

func _on_CloseButton_pressed():
	self.visible = false

func _on_dataEmittedToVNN(neuros):
	var newNeuroPanel
	for neuroId in neuros:
		newNeuroPanel = get_node(self.neuroNodesDictionary[neuroId].get_path())
		newNeuroPanel.get_node("VBoxContainer").get_child(0).text = str(neuroId)
		newNeuroPanel.get_node("VBoxContainer").get_child(1).text = str(neuros[neuroId]["output"])
