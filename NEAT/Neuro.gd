extends Node2D


var inputsToNeuro = {}
var outputsFromNeuro = {}
var id
var type
var received_inputs_for_firing = 0
var expected_inputs = 0
var input = 0.0
var output = 0.0
var has_fired = false
#possibly use backprop
var error = {
	"responsibility": 0,
	"projected": 0,
	"gated": 0
}
var gated = []
var enabled = true
var TIME = 0

func _init(newNeuroId, n_type="Hidden"):
	self.id = newNeuroId
	self.type = n_type
	

func think():
	var sum = 0
	for inputNeuro in inputsToNeuro:
		# {3: [0.5, 2: 0.7}
		sum += inputsToNeuro[inputNeuro] * self.neuros[inputNeuro]["output"]
	self.output = activation_function(sum)

func expected_inputs():
	if self.type == "Input":
		return 1
	else:
		return len(self.inputs)

func addConnectionIntoThisNeuro(inputNeuro):
	self.inputsToNeuro.append({inputNeuro.id: inputNeuro.weight})

func addConnectionOutOfThisNeuro(outputNeuro):
	self.outputsFromNeuro.append({outputNeuro.id: outputNeuro.weight})

func getFrom():
	return 

func _ready():
	pass
	#var received_all_inputs = (self.received_inputs == self.expected_inputs())
	#return (not self.sent_output and received_all_inputs)

#func _process(delta):
#	pass

#func fire():
#	self.sent_output = true
#	for gene in self.outputsFromNeuro:
#		if gene.enabled and gene.weight != null:
#			gene.output_neuron.add_input((self.activation()*gene.weight))
#		else:
#			0




#func fire():
#	self.has_fired = true
#	for outputNeuro in self.outputsFromNeuro:
#		self.neuros[ouputNeuro]["received_inputs_for_firing"] += 1 
#	if self.type == "Hidden":
#		for inputNeuro in self.inputsToNeuro:
#			#if incoming neuro fired
#			if inputNeuro[1] == true:
#				continue
#			else:
#				return
#			print("all incoming neuros fired")
#			return self.output
#	else:
#		return self.output


func neuroReady():
	return self.received_inputs_for_firing == self.expected_inputs


func activation_function(input):
	return self.sigmoid(input)

func activation():
	return self.sigmoid(self.input)

func sigmoid(x):
	return 2.0 / (1.0 + pow(2.71828,(-4.9 * x)) - 1.0)

func leakyReLU(x):
	if x >= 0:
		return x
	else:
		return 0.05*x

func reset_neuron():
	self.received_inputs = 0
	self.output = 0.0
	self.sent_output = false

func _process(delta):
	repolarization()
#	self.TIME += delta
#	if self.TIME >= 0.01:
#		self.TIME = 0

func repolarization():
	if self.output > 0:
		self.output - 0.5


func add_input(value):
	self.input += value
	self.received_inputs += 1

func add_input_gene(gene):
	self.input_genes[gene.innovation_number] = gene

func add_output_gene(gene):
	self.output_genes[gene.innovation_number] = gene

func set_id(new_id):
	self.id = new_id

func getOutput():
	return output


