extends Node2D
#property vector = [edible, dangerous, aggressive, ally, smells good, smells weird]
var propertyVector = [1, 1, 0, 1, 0, 0]
var NeuralNet = preload("res://NEAT/NeuralNet.gd")
var score = 0
signal death(thisNode)
signal emitDataToVNN(neuros)
var thisNeuralNet
var organismId
var TIME = 0
var showingVNN = false
var inputPropertyVector = [0, 0, 0, 0, 0, 0]
var inputTickObject = { 0:0.0, 1:0.0, 2:0.0, 3:0.0, 4:0.0 }
var outputTickObject = {5:0.0, 6:0.0, 7:0.0, 8:0.0}
var outputTickVector = []
var outputIdArrayMovement = [5, 6, 7, 8]
#0 state
#1,2,3,4 visual detection
#5,6,7,8 movement


func create(genome, neuroGenome, organismId):
	#self.connect("change_player_health", get_node("GUICanvasLayer/PartyStatus"), "_on_UserInterface_health_changed")
	#self.connect("emitDataToVNN", self.get_tree().get_root().get_node("World/Camera2D/VisualNeuralNet"), "_on_dataEmittedToVNN")
	#self.get_tree().get_root().get_node("World/Camera2D/VisualNeuralNet").connect("emitDataToVNN", self, "_on_dataEmittedToVNN")
	self.organismId = organismId
	self.global_position.x = rand_range(-500, 500)
	self.global_position.y = rand_range(-300, 300)
	self.thisNeuralNet = NeuralNet.new(genome, neuroGenome)
	return self

func _on_InputTickTimer_timeout():
	self.outputTickObject = self.thisNeuralNet.CINNmethod(self.inputTickObject)
	if self.showingVNN == true:
		emit_signal("emitDataToVNN", self.thisNeuralNet.neuros)
	self.inputTickObject = { 0:0.0, 1:0.0, 2:0.0, 3:0.0, 4:0.0 }
	actOnOutputObject()
	
func actOnOutputObject():
	var highestId = 5
	for outputNeuroId in self.outputIdArrayMovement:
		if self.outputTickObject[outputNeuroId] > self.outputTickObject[highestId]:
			highestId = outputNeuroId
	activateOutputNeuro(highestId)


#INPUT HANDLING
func activateInputNeuro(neuroId):
	self.inputTickObject[neuroId] = 1.0#+rand_range(-0.05, 0.05)
	
func _on_RightVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(1)

func _on_DownVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(2)

func _on_LeftVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(3)

func _on_UpVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(4)


#OUTPUT HANDLING
func get_pos():
	return self.position

func move_to(target_position):
	get_node("TweenNode").interpolate_property(self, "position", get_pos(), target_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("TweenNode").start()

func activateOutputNeuro(outputNeuroId):
	if outputNeuroId == 5:
		move_to(self.get_pos()+Vector2(20, 0))
		#move right
	elif outputNeuroId == 6:
		move_to(self.get_pos()+Vector2(0, -20))
		#move down
	elif outputNeuroId == 7:
		move_to(self.get_pos()+Vector2(-20, 0))
		#move left
	elif outputNeuroId == 8:
		move_to(self.get_pos()+Vector2(0, 20))
		#move up
	else:
		pass


#OTHER FUNCTIONS RELEVANT TO ORGANISM
func die():
	emit_signal("death", self)

func _on_NeuroFireRetryTimer_timeout():
	pass # Replace with function body.

func _on_Button_pressed():
	self.thisNeuralNet.CINNmethod(self.inputTickObject)

func _on_CheckBrainButton_pressed():
	self.showingVNN = false
	for node in get_tree().get_nodes_in_group("VNN"):
		node.queue_free()
	var theVNNnode = self.get_tree().get_root().get_node("World").get_node("Camera2D").get_node("Player").get_node("VisualNeuralNet")
	theVNNnode.visible = true
	theVNNnode.create(self.thisNeuralNet.neuros)
	self.showingVNN = true

func _on_WeakSpot_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("bush"):
		self.score += 2
		area.get_parent().queue_free()
	elif area.is_in_group("player"):
		self.score -= 10
		die()
