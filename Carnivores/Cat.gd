extends Node2D
var Neuro = load("res://NEAT/Neuro.gd") # create a Neuro reference object
var Genome = load("res://NEAT/Genome.gd") # create a Neuro reference object
var NeuralNet = preload("res://NEAT/NeuralNet.gd") # create a Neuro reference object
var score = 0
signal sendInputToBrain(inputNeuroId)
signal send_output_vector_to_organism(outputVector)
signal death()
var thisNeuralNet
var TIME = 0
var inputTickObject = { 0:0.0, 1:0.0, 2:0.0, 3:0.0, 4:0.0 }

#0 state
#1,2,3,4 visual detection
#5,6,7,8 movement


func create(genome, neuroGenome):
	self.connect("change_player_health", get_node("GUICanvasLayer/PartyStatus"), "_on_UserInterface_health_changed")
	self.connect("send_output_vector_to_organism", self, "_on_received_output_vector")
	self.global_position.x = rand_range(-500, 500)
	self.global_position.y = rand_range(-300, 300)
	self.thisNeuralNet = NeuralNet.new(genome, neuroGenome)
	print(self.global_position)
	return self


func zeromaker(matrix_X_dim, matrix_Y_dim):
	var resultMatrix = []
	for i in range(matrix_X_dim):
		var tempRow = []
		for j in range(matrix_Y_dim):
			tempRow.append(0)
		resultMatrix.append(tempRow)
	return resultMatrix


func _activation_(X, size_output):
	var output = zeromaker(len(X), 1)
	for index in range(size_output):
		output[index] = 1 / (1 + pow(2.718281,(-4.9*X[index])))
	return output


func feed_forward(X):
	var output
	X = convertToArray(X)
	var slicedW = []
	for i in range(0, len(self.W)-1, 1):
		slicedW.append((self.W[i]))
	var index = 0
	for tuple in zip(slicedW, self.b):
		var size_output = self.topology[index+1]
		var dot_
		if index == 0:
			X = convertToArray(normalize(X))
			dot_ = tuple[0].dot(X)
		else:
			dot_ = tuple[0].dot(output)
		output = self._activation_(dot_ + tuple[1], size_output)
		index += 1
	print(output)


func zip(x, y):
	if len(x) == len(y):
		var zipper = []
		for i in range(len(x)):
			zipper.append([x[i], y[i]])
		return zipper

func min_arr(arr):
	var min_val = arr[0]
	for i in range(1, arr.size()):
		min_val = min(min_val, arr[i])
	return min_val

func max_arr(arr):
	var max_val = arr[0]
	for i in range(1, arr.size()):
		max_val = max(max_val, arr[i])
	return max_val

func normalize(arr):
	var i = 0
	var arr_min = min_arr(arr)
	var arr_max = max_arr(arr)
	for val in arr:
		arr[i] = (val-arr_min)/(arr_max-arr_min)
		i+=1

func convertToArray(matrix):
	var newarray = []
	for row in matrix:
		for col in row:
			newarray.append(matrix[col][row])
	return newarray

func decision():
	if self.output < 0.5:
		return 0
	else:
		return 1


func print_matrices():
	print("Matrices")
	var index = 0
	for layer in self.W:
		print("W{}".format(index+1))
		print(layer)
		print("\n")
		index+=1
	for b in self.b:
		print("b: {}".format(b))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _physics_process(delta):
	self.TIME += delta
	if self.TIME >= .1:
		pass


func fire(neuroId):
	var neuro = self.thisNeuralNet.neuros[neuroId]
	#check if all input neuros have fired
	if neuro["received_inputs_for_firing"] == neuro["expected_inputs"]:
		for outputNeuro in neuro["outputsFromNeuro"]:
			self.thisNeuralNet.neuros[outputNeuro]["received_inputs_for_firing"] += 1
		var sum = 0
		for inputNeuro in neuro["inputsToNeuro"]:
				#if self.neuros[inputNeuro]["has_fired"]:
				# sum += inputNeuroConnectionWeight * inputNeuroOutput
			sum += neuro["inputsToNeuro"][inputNeuro] * self.thisNeuralNet.neuros[inputNeuro]["output"]
		neuro["output"] = activation_function(sum)
		neuro["has_fired"] = true
		print("neuro fired")
		if neuro["type"] == "Output":
			behaviorFunction(neuroId)
	else:
		print("neuro firing failed because not all input neuros fired")

func activation_function(input):
	return self.sigmoid(input)

func sigmoid(x):
	return 2.0 / (1.0 + pow(2.71828,(-4.9 * x)) - 1.0)

func get_pos():
	return self.position

func move_to(target_position):
	get_node("TweenNode").interpolate_property(self, "position", get_pos(), target_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func behaviorFunction(outputNeuroId):
	var tweenNode = get_node("TweenNode")
	#if it's one of the movement neuros
	if outputNeuroId == 5:
		move_to(self.get_pos()+Vector2(10, 0))
		#move right
	elif outputNeuroId == 6:
		move_to(self.get_pos()+Vector2(0, -10))
		#move down
	elif outputNeuroId == 7:
		move_to(self.get_pos()+Vector2(-10, 0))
		#move left
	elif outputNeuroId == 8:
		move_to(self.get_pos()+Vector2(0, 10))
		#move up
	else:
		pass

func die():
	emit_signal("death")

func activateInputNeuro(neuroId):
	#emit_signal("sendInputToBrain", neuroId)
	self.inputTickObject[neuroId] = 1.0#+rand_range(-0.05, 0.05)
	#self.thisNeuralNet.neuros[neuroId]["output"]

func inputObjectChanged():
	var inputNeuros = self.thisNeuralNet.inputNeuros
	self.thisNeuralNet.processInputDataOnce()
#	for inputNeuro in inputNeuros:
#		self.thisNeuralNet.processDataForOneNeuro(inputNeuro)

func _on_RightVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(1)

func _on_DownVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(2)

func _on_LeftVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(3)

func _on_UpVision_area_shape_entered(area_id, area, area_shape, self_shape):
	activateInputNeuro(4)


func _on_InputTickTimer_timeout():
	self.thisNeuralNet.CINNmethod(self.inputTickObject)
	self.inputTickObject = { 0:0.0, 1:0.0, 2:0.0, 3:0.0, 4:0.0 }


func _on_NeuroFireRetryTimer_timeout():
	pass # Replace with function body.


func _on_Button_pressed():
	self.thisNeuralNet.CINNmethod(self.inputTickObject)

func _on_received_output_vector(outputVector):
	print("HURRAY")
