extends Node

var innovationDictSize = 14
var MAX_HIDDEN_NEURONS = 20
var connection_weight_mutation_chance = 0.8
var chance_of_each_weight_uniform_mutation = 0.9
var chance_of_each_weight_randomly_mutated = 0.1
var chance_disable_inherited_gene = 0.75
var chance_mutation_NO_crossover = 0.25
var chance_interspecies_mating = 0.001
var chance_new_node = 0.01

var inputNeurosArray = []
var hiddenNeurosArray = []
var outputNeurosArray = []
var inputAndHiddenMatrix = []
var hiddenStateVector = []
var outputVector = []
var inputNeuros = {}
var hiddenNeuros = {}
var outputNeuros = {}
var inputObject = { 0:1.0, 1:0.0, 2:1.0, 3:0.0, 4:0.0}
var hiddenStateObject = {9:0.0, 10:0.0, 11:0.0}
var outputObject = {5:0.0, 6:0.0, 7:0.0, 8:0.0}

var neuros = {}
var connectionGenome = {}
var neuroGenome = {}
var TIME = 0
var f = 0
var current_neuro_id = 0
var num_input_neuros = 5
var num_output_neuros = 4
var topology = []


func _init(connectionGenome, masterNeuroGenome):
	self.connectionGenome = connectionGenome
	self.neuroGenome = masterNeuroGenome
	var modifiedNeuroGenome = self.neuroGenome
	var tempGene
	#Create neuros
	var i = 0
	while i < self.num_input_neuros:
		var new_neuro_id = get_next_neuro_id()
		#self.neuros[new_neuro_id] = Neuro.new(new_neuro_id, "Input")
		self.neuros[new_neuro_id] = {"type":"Input", "output":0, "outputsFromNeuro":{}, "sent_output":false}
		#self.inputAndHiddenNeuros.append(new_neuro_id)
		self.inputNeurosArray.append(new_neuro_id)
		self.inputNeuros[new_neuro_id] = self.neuros[new_neuro_id]
		i += 1
	i = 0
	while i < self.num_output_neuros:
		var new_neuro_id = get_next_neuro_id()
		#self.neuros[new_neuro_id] = Neuro.new(new_neuro_id, "Output")
		self.neuros[new_neuro_id] = {"type":"Output", "inputsToNeuro":{}, "output":0, "inputSum":0, "expected_inputs":0, "received_inputs":0}
		self.outputNeurosArray.append(new_neuro_id)
		self.outputNeuros[new_neuro_id] = self.neuros[new_neuro_id]
		i += 1
	var new_neuro_id
	for geneId in connectionGenome:
		tempGene = connectionGenome[geneId]
		#print(tempGene)
		#go through connectionGenome once and generate new neuros for all new_neuro genes
		if str(geneId) != "fitness" and str(geneId) != "speciesid" and tempGene["type"] == "new_neuro":
			new_neuro_id = tempGene.new_neuroId
			randomize()
			self.neuros[new_neuro_id] = {"type":"Hidden", "inputsToNeuro":{}, "outputsFromNeuro":{}, "output":randf()*2-1, "inputSum":0, "sent_output":false, "inputs_received":0, "expected_inputs":0}
			#self.inputAndHiddenNeuros.append(new_neuro_id)
			self.hiddenNeurosArray.append(new_neuro_id)
			self.hiddenNeuros[new_neuro_id] = self.neuros[new_neuro_id]
	for geneId in connectionGenome:
		tempGene = connectionGenome[geneId]
		#go through entire connectionGenome again and handle all other types of genes
		if str(geneId) == "fitness" or str(geneId) == "speciesid":
			pass
		else:
			print("test")
			if tempGene["type"] == "connection":
				#print(tempGene)
				print(self.neuros[tempGene.out])
				#add connection data to individual Neuros
				#assume self.neuros has both neuros at ends of connection    and self.neuros.has(tempGene.in) and self.neuros.has(tempGene.out)
				self.neuros[tempGene.out]["inputsToNeuro"][tempGene.in] = tempGene.weight
				self.neuros[tempGene.out]["expected_inputs"] += 1
				if self.neuros[tempGene.in]["type"] == "Input":
					pass
				self.neuros[tempGene.in]["outputsFromNeuro"][tempGene.out] = tempGene.weight
				#mutate_weight(tempGene)
				continue
			elif tempGene["type"] == "disable_connection":
				connectionGenome[tempGene.disableInnovationId]["enabled"] = false
				var inConnectionToRemove = connectionGenome[tempGene.disableInnovationId]["in"]
				var outConnectionToRemove = connectionGenome[tempGene.disableInnovationId]["out"]
				var inputsToNeuroDict = self.neuros[outConnectionToRemove]["inputsToNeuro"]
				var outputsFromNeuroDict = self.neuros[inConnectionToRemove]["outputsFromNeuro"]
				if inputsToNeuroDict.has(inConnectionToRemove):
					self.neuros[outConnectionToRemove]["expected_inputs"] -= 1
					inputsToNeuroDict.erase(inConnectionToRemove)
				if outputsFromNeuroDict.has(outConnectionToRemove):
					outputsFromNeuroDict.erase(outConnectionToRemove)
				continue
			elif tempGene["type"] == "enable_connection":
				var connectionToEnable = connectionGenome[tempGene.enableInnovationId]
				connectionToEnable["enabled"] = true
				self.neuros[connectionToEnable.out]["inputsToNeuro"][connectionToEnable.in] = connectionToEnable.weight
				self.neuros[connectionToEnable.out]["expected_inputs"] += 1
				self.neuros[connectionToEnable.in]["outputsFromNeuro"][connectionToEnable.out] = connectionToEnable.weight
				continue
			elif tempGene["type"] == "disable_neuro":
				var selected_neuroId = tempGene.selected_neuroId
				#var temp = self.inputAndHiddenNeuros.find(selected_neuroId)
				var temp = self.hiddenNeurosArray.find(selected_neuroId)
				if temp != -1:
					self.hiddenNeurosArray.erase(self.hiddenNeurosArray[temp])
					#self.inputAndHiddenNeuros.erase(self.inputAndHiddenNeuros[temp])
					self.neuroGenome[selected_neuroId]["enabled"] = false
					self.neuros[selected_neuroId]["enabled"] = false
					self.hiddenNeuros[selected_neuroId] = self.neuros[selected_neuroId]
				else:
					print("no neuro with that id found")
				continue
			elif tempGene["type"] == "enable_neuro":
				var selected_neuroId = tempGene.selected_neuroId
				#just add re-enabled neuro to end of array because we're gonna remake the matrix anyway
				#self.inputAndHiddenNeuros.append(enabled_neuro_id)
				self.hiddenNeurosArray.append(selected_neuroId)
				self.neuroGenome[selected_neuroId]["enabled"] = true
				self.neuros[selected_neuroId]["enabled"] = true
				self.hiddenNeuros[selected_neuroId] = self.neuros[selected_neuroId]
				continue
	self.topology = [len(self.inputNeuros.keys()), len(self.hiddenNeuros.keys()), len(self.outputNeuros.keys())]
	print(self.neuros)


#NEURAL NET FUNCTIONS
func activation_function(input):
	return self.sigmoid(input)

func sigmoid(x):
	return 2.0 / (1.0 + pow(2.71828,(-4.9 * x)) - 1.0)

func leakyReLU(x):
	if x >= 0:
		return x
	else:
		return 0.035*x

func disable(innovationId):
	self.connectionGenome[innovationId]["enabled"] = false

func mutate_weight(gene):
	if randf() < chance_of_each_weight_randomly_mutated:
		if randf() < chance_of_each_weight_uniform_mutation:
			randomize_tweak_weight(gene)
		else:
			randomize_set_weight(gene)

func randomize_set_weight(gene):
	if gene["weight"] != null:
		gene["weight"] = rand_range(-2.0, 2.0)

func randomize_tweak_weight(gene):
	if gene["weight"] != null:
		gene["weight"] += rand_range(-0.1, 0.1)

func get_new_innovation_number():
	var innovation_number = self.current_innovation_number
	self.current_innovation_number += 1
	return innovation_number

func get_next_neuro_id():
	var current_id = self.current_neuro_id
	self.current_neuro_id += 1
	return current_id


func CINNmethod(inputTickObject):
	self.inputObject = inputTickObject
	for inputId in inputTickObject:
		self.neuros[inputId]["output"] = inputTickObject[inputId]
	var inputAndHiddenNeurosIdArray = self.inputNeurosArray + self.hiddenNeurosArray
	#print(inputAndHiddenNeurosIdArray)
	self.inputAndHiddenMatrix = convertInputObjectAndNeurosToWeightMatrix(inputAndHiddenNeurosIdArray, self.neuros)
	#print(self.inputAndHiddenMatrix)
	var inputWeightVector = convertInputAndHiddenNeurosArrayToWeightVector(inputAndHiddenNeurosIdArray)
	#print(inputWeightVector)
	#print("DOT")
	var processedInputAndHiddenWeightVector = dotProduct(inputWeightVector, self.inputAndHiddenMatrix)
	self.hiddenStateVector = processedInputAndHiddenWeightVector.slice(len(inputNeurosArray), len(inputNeurosArray)+len(hiddenNeurosArray)-1, 1, true)
	var outputMatrix = convertNeurosToOutputMatrix(inputAndHiddenNeurosIdArray, self.neuros)
	#print(outputMatrix)
	self.outputVector = dotProduct(processedInputAndHiddenWeightVector, outputMatrix)
	#print("output array")
	#print(self.outputVector)
	var i = 0
	for outputId in self.outputNeurosArray:
		self.outputObject[outputId] = self.outputVector[i]
		i += 1
	return self.outputObject

func convertInputAndHiddenNeurosArrayToWeightVector(theArray):
	var weightVector = []
	for inputId in self.inputNeurosArray:
		weightVector.append(self.inputObject[inputId])
	for hiddenNeuroId in self.hiddenNeurosArray:
		weightVector.append(self.neuros[hiddenNeuroId]["output"])
	#for neuroId in theArray:
	#	weightVector.append(self.neuros[neuroId]["output"])
	return weightVector

func convertInputObjectAndNeurosToWeightMatrix(inputAndHiddenNeurosArray, neurosObject):
	var inputAndHiddenWeightMatrix = []
	var i = 0
	var tempRow = []
	#outgoingNeuroId is the id of neuro that is pushing out signals
	for outgoingNeuroId in inputAndHiddenNeurosArray:
		i = 0
		tempRow = []
		for incomingNeuroId in inputAndHiddenNeurosArray:
			#if we're still in the "input section" of the inputAndHiddenNeurosArray create identity matrix
			if i < len(self.inputObject.keys()):
				if outgoingNeuroId == incomingNeuroId:
					tempRow.append(float(1))
				else:
					tempRow.append(float(0))
				i += 1
			else:
				#once we're at the "hidden section" of the inputAndHiddenNeurosArray look up the corresponding 
				#weight that hidden neuro receives from either an input neuro or another hidden neuro
				if self.neuros[incomingNeuroId]["inputsToNeuro"].has(outgoingNeuroId):
					tempRow.append(float(self.neuros[incomingNeuroId]["inputsToNeuro"][outgoingNeuroId]))
				else:
					tempRow.append(float(0))
		inputAndHiddenWeightMatrix.append(tempRow)
	return inputAndHiddenWeightMatrix

func convertNeurosToOutputMatrix(combinedInputAndHiddenArray, neurosObject):
	var outputMatrix = []
	var tempRow = []
	#outgoingNeuroId is the id of neuro that is pushing out signals
	for outgoingNeuroId in combinedInputAndHiddenArray:
		tempRow = []
		for outputNeuroId in self.outputNeurosArray:
			#print(outputNeuroId)
			#print(self.neuros)
			#print(self.neuros[outputNeuroId]["inputsToNeuro"])
			if self.neuros[outputNeuroId]["inputsToNeuro"].has(outgoingNeuroId):
				tempRow.append(float(self.neuros[outputNeuroId]["inputsToNeuro"][outgoingNeuroId]))
			else:
				tempRow.append(float(0))
		outputMatrix.append(tempRow)
	return outputMatrix


#MATRIX FUNCTIONS
func dotProduct(inputVector, weightMatrix):
	var output = []
	var rowNumber = 0
	var tempValue = 0
	for columnNumber in range(len(weightMatrix[0])):
		rowNumber = 0
		tempValue = 0
		for element in inputVector:
			tempValue += element * weightMatrix[rowNumber][columnNumber]
			rowNumber += 1
		output.append(tempValue)
	return output

func zerosMatrix(out, inn):
	var matrix = []
	for i in range(out):
		var row = []
		for j in range(inn):
			row.append(0)
		matrix.append(row)
	return matrix
