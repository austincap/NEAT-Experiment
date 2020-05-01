extends Node


var MAX_HIDDEN_NEURONS = 20
var connection_weight_mutation_chance = 0.8
var chance_of_each_weight_uniform_mutation = 0.9
var chance_of_each_weight_randomly_mutated = 0.1
var chance_disable_inherited_gene = 0.75
var chance_mutation_NO_crossover = 0.25
var chance_interspecies_mating = 0.001
var chance_new_node = 0.01




var speciesId
var organismId
#var neuroList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
#var neuroGenome = [
#	{"id":0, "type":"Input", "enabled":true}, 
#	{"id":1, "type":"Input", "enabled":true}, 
#	{"id":2, "type":"Input", "enabled":true}, 
#	{"id":3, "type":"Input", "enabled":true}, 
#	{"id":4, "type":"Input", "enabled":true}, 
#	{"id":5, "type":"Output", "enabled":true},
#	{"id":6, "type":"Output", "enabled":true},
#	{"id":7, "type":"Output", "enabled":true},
#	{"id":8, "type":"Output", "enabled":true}
#]

var neuroGenome = {
	0:{"type":"Input", "enabled":true}, 
	1:{"type":"Input", "enabled":true}, 
	2:{"type":"Input", "enabled":true}, 
	3:{"type":"Input", "enabled":true}, 
	4:{"type":"Input", "enabled":true}, 
	5:{"type":"Output", "enabled":true},
	6:{"type":"Output", "enabled":true},
	7:{"type":"Output", "enabled":true},
	8:{"type":"Output", "enabled":true}
}

var connectionGenome = {
	0:{"type":"connection", "in":1, "out":5, "weight":0.5, "innovationId":0, "enabled":true},
	1:{"type":"connection", "in":2, "out":6, "weight":0.5, "innovationId":1, "enabled":true},
	2:{"type":"connection", "in":3, "out":7, "weight":0.5, "innovationId":2, "enabled":true},
	3:{"type":"connection", "in":4, "out":8, "weight":0.5, "innovationId":3, "enabled":true}
}

#init topology
var topology = [5, 0, 4]



func randomize_weight(innovationId):
	self.connectionGenome[innovationId]["weight"] = rand_range(-2.0, 2.0)

func disable(innovationId):
	self.connectionGenome[innovationId]["enabled"] = false

func copy(genome):
	return genome.duplicate(true)

func addNeuroToInnovationList(globalNeuroList, globalInnovationIdList):
	var connectionList = []
	for innovation in globalInnovationIdList:
		if innovation.type == "connection":
			connectionList.append(innovation)
	var connectionToSplit = connectionList[randi()%connectionList.size()]
	var nextNeuroId = len(globalNeuroList)
	globalNeuroList.append(nextNeuroId)
	globalInnovationIdList.append({"type":"new_neuro", "new_neuroId":nextNeuroId})
	globalInnovationIdList.append({"type":"connection", "in":connectionToSplit.in, "out":nextNeuroId, "weight":0.5})
	globalInnovationIdList.append({"type":"connection", "in":nextNeuroId, "out":connectionToSplit.out, "weight":0.5})

#func addConnectionToInnovationList(globalInnovationIdList):
#	var inputId
#	var outputId
#	var newInnovation = false
#	var newInnovationObjectToAdd
#	while newInnovation == false:
#		inputId = neuroList[randi()%neuroList.size()]
#		outputId = neuroList[randi()%neuroList.size()]
#		var i = 0
#		for innovation in globalInnovationIdList:
#			if i < len(globalInnovationIdList):
#				i+=1
#				if innovation.type == "connection":
#					if (inputId == innovation.in and outputId == innovation.out) or (outputId == innovation.in and inputId == innovation.out):
#						continue
#					else:
#						newInnovationObjectToAdd = {"in":inputId, "out":outputId, "weight":0.5, "type":"connection"}
#						newInnovation = true
#						break
#			else:
#				print("all connections already exist")
#				break
#				return
#	globalInnovationIdList.append(newInnovationObjectToAdd)

func addDisableConnectionToInnovationList(globalInnovationIdList):
	var connectionList = []
	for innovation in globalInnovationIdList:
		if innovation.type == "connection":
			connectionList.append(innovation)
	var connectionToDisable = connectionList[randi()%connectionList.size()]
	globalInnovationIdList.append({"type":"disable_connection", "in":connectionToDisable.in, "out":connectionToDisable.out})



func mutate_weight(gene):
	if randf() < chance_of_each_weight_randomly_mutated:
		if randf() < chance_of_each_weight_uniform_mutation:
			gene.weight += rand_range(-0.1, 0.1)
		else:
			randomize_weight(gene)









# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
