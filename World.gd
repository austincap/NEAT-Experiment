extends Node2D
var NeuralNet = load("res://NEAT/NeuralNet.gd")
var Cat = preload("res://Carnivores/Cat.tscn")

var lifetime_pop = 0
var this_gen_pop = 0
var generation_number = 0
var species_amount = 0
var species_array = []
var population_array = []

#var test_population_array = [
#	{"genome":"data"},
#	{"genome":"data"},
#] test
#
var simpleStartingGenome = {
	0:{"type":"connection", "in":1, "out":5, "weight":0.5, "innovationId":0, "enabled":true},
	1:{"type":"connection", "in":2, "out":6, "weight":0.8, "innovationId":1, "enabled":true},
	2:{"type":"connection", "in":3, "out":7, "weight":0.5, "innovationId":2, "enabled":true},
	3:{"type":"connection", "in":4, "out":8, "weight":0.5, "innovationId":3, "enabled":true},
	"fitness":0,
	9:{"type":"new_neuro", "weight":null, "new_neuroId":10, "innovationId":9, "enabled":true},
	10:{"type":"connection", "in":4, "out":10, "weight":0.1, "innovationId":10, "enabled":true},
	11:{"type":"connection", "in":10, "out":8, "weight":0.5, "innovationId":11, "enabled":true},
	12:{"type":"new_neuro", "weight":null, "new_neuroId":11, "innovationId":12, "enabled":true},
	13:{"type":"connection", "in":2, "out":11, "weight":0.3, "innovationId":13, "enabled":true},
	14:{"type":"connection", "in":1, "out":11, "weight":-0.4, "innovationId":14, "enabled":true}
}
#
#var test_species_array = [
#	{"id":0, "population":33, "avgfitness":10, "typicalgenome":{"genome":"data"}}
#]

var GENERATION_SIZE = 10
var NUMBER_OF_RANDOM_NOVEL_ORGANISMS_PER_GENERATION = 1
var TIMES_TO_CLONE_TOP_ORGANISM_DURING_REPRODUCTION = 5
var innovationDictSize = 9
var MAX_HIDDEN_NEURONS = 20
var connection_weight_mutation_chance = 0.8
var chance_of_each_weight_uniform_mutation = 0.9
var chance_of_each_weight_randomly_mutated = 0.1
var chance_disable_inherited_gene = 0.75
var chance_mutation_NO_crossover = 0.25
var chance_interspecies_mating = 0.001
var chance_new_neuro = 0.01
var chance_disable_connection = 0.02
var chance_enable_connection = 0.02
var chance_disable_neuro = 0.005
var chance_enable_neuro = 0.005
var chance_mess_with_neuros = 0.01
var chance_mess_with_connections = 0.1
var DYNAMIC_POPULATION = false
var SPECIATION = true

#if id number is negative, it is disabled
#0 state input
#1,2,3 4 vision input
#5,6,7,8 movement output

var masterNeuroGenome = {
	0:{"type":"Input", "enabled":true}, 
	1:{"type":"Input", "enabled":true}, 
	2:{"type":"Input", "enabled":true}, 
	3:{"type":"Input", "enabled":true}, 
	4:{"type":"Input", "enabled":true}, 
	5:{"type":"Output", "enabled":true},
	6:{"type":"Output", "enabled":true},
	7:{"type":"Output", "enabled":true},
	8:{"type":"Output", "enabled":true},
	9:{"type":"Hidden", "enabled":false},
	10:{"type":"Hidden", "enabled":true},
	11:{"type":"Hidden", "enabled":true}
}
var inputNeurosArray = [0, 1, 2, 3, 4]
var outputNeurosArray = [5, 6, 7, 8]
var masterInnovationList = {
	0:{"type":"connection", "in":1, "out":5, "weight":0.5, "innovationId":0, "enabled":true},
	1:{"type":"connection", "in":2, "out":6, "weight":0.5, "innovationId":1, "enabled":true},
	2:{"type":"connection", "in":3, "out":7, "weight":0.5, "innovationId":2, "enabled":true},
	3:{"type":"connection", "in":4, "out":8, "weight":0.5, "innovationId":3, "enabled":true},
	4:{"type":"new_neuro", "weight":null, "new_neuroId":9, "innovationId":4, "enabled":true},
	5:{"type":"enable_neuro", "weight":null, "selected_neuroId":9, "innovationId":5, "enabled":true},
	6:{"type":"disable_neuro", "weight":null, "selected_neuroId":9, "innovationId":6, "enabled":true},
	7:{"type":"disable_connection", "weight":null, "disableInnovationId":2, "innovationId":7, "enabled":true},
	8:{"type":"enable_connection", "weight":null, "enableInnovationId":2, "innovationId":8, "enabled":true},
	9:{"type":"new_neuro", "weight":null, "new_neuroId":10, "innovationId":9, "enabled":true},
	10:{"type":"connection", "in":4, "out":10, "weight":0.5, "innovationId":10, "enabled":true},
	11:{"type":"connection", "in":10, "out":8, "weight":0.5, "innovationId":11, "enabled":true},
	12:{"type":"new_neuro", "weight":null, "new_neuroId":11, "innovationId":12, "enabled":true},
	13:{"type":"connection", "in":2, "out":11, "weight":0.5, "innovationId":13, "enabled":true},
	14:{"type":"connection", "in":1, "out":11, "weight":0.5, "innovationId":14, "enabled":true}
}


class MyCustomSorter:
	static func sort_ascending(a, b):
		if a < b:
			return true
		return false
	
	static func sort_ascending_make_array(a, b):
		if a < b:
			return a
		return b
	
	static func sort_geneticDistancesArray_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
		
	static func sort_pop_array_of_genome_objects_ascending_make_array(a, b):
		if a["fitness"] < b["fitness"]:
			return true
		return false


#signal based
func evaluate_organism(organism_genome):
	determineWhichSpeciesToClassifyItAs(organism_genome)

func _on_StartSimulation_toggled(button_pressed):
	create_new_generation(self.GENERATION_SIZE)


func create_new_generation(gen_size):
	self.this_gen_pop = 0
	var tempArray = []
	var timesClone = self.TIMES_TO_CLONE_TOP_ORGANISM_DURING_REPRODUCTION
	var timesRando = self.NUMBER_OF_RANDOM_NOVEL_ORGANISMS_PER_GENERATION
	
	if self.generation_number > 0:
		for organism_genome in self.population_array:
			evaluate_organism(organism_genome)
		var sorted_genome_array = self.population_array.sort_custom(MyCustomSorter, "sort_pop_array_of_genome_objects_ascending_make_array")
		var top_organism = sorted_genome_array[0]
		var tempOrganismGenome
		for i in range(timesClone):
			tempOrganismGenome = cloning(top_organism)
			tempArray.append(tempOrganismGenome)
		for i in range(timesRando):
			tempOrganismGenome = create_new_genome_from_innovation_list()
			tempArray.append(tempOrganismGenome)
		for i in range(gen_size-timesClone-timesRando):
			tempOrganismGenome = mating(sorted_genome_array[i+1], sorted_genome_array[i+2])
			tempArray.append(tempOrganismGenome)
	else:
		for i in range(gen_size):
			var genome = self.simpleStartingGenome.duplicate(true)
			mutate_random_weight(genome)
			print(genome)
			tempArray.append(genome)
	self.population_array = tempArray
	for enemy in get_tree().get_nodes_in_group("organisms"):
		enemy.queue_free()
	print(self.population_array)
	for genome in self.population_array:
		print(genome)
		create_new_organism(genome)
	self.generation_number += 1
	$"Camera2D/PanelContainer1/Container/HSplitContainer1/Label".text = str(self.generation_number)
	print("new generation born")
	print(len(self.population_array))

func create_new_organism(genome):
	genome.fitness = 0
	self.this_gen_pop += 1
	self.lifetime_pop += 1
	#var newOrganism = Cat.new(genome, self.masterNeuroGenome)
	var newOrganism = Cat.instance().create(genome, self.masterNeuroGenome)
	#print(newOrganism)
	#print(print_tree())
	get_tree().get_root().add_child(newOrganism)
	#newOrganism.connect("death", self, "_on_organism_dead")

func _on_organism_dead():
	self.this_gen_pop -= 1


func geneticDistance(genomeA, genomeB):
	var numGenesA = len(genomeA.values())
	var numGenesB = len(genomeB.values())
	var disjointGenes = 0
	var sameGenes = 0
	var totalGenes = 0
	var c1 = 0.6
	var c2 = 0.4
	var averageWeightDifferencesSum = 0
	if numGenesA > numGenesB:
		totalGenes = numGenesA-1 #-1 because of fitness key in genome object
		for gene in genomeA:
			if str(gene) != "fitness" and str(gene) != "speciesid":
				if genomeB.has(gene):
					sameGenes += 1
					if genomeA[gene]["weight"] != null:
						averageWeightDifferencesSum += (genomeA[gene]["weight"] - genomeB[gene]["weight"])
				else:
					disjointGenes += 1
	elif numGenesA <= numGenesB:
		totalGenes = numGenesB-1 #-1 because of fitness key in genome object
		for gene in genomeB:
			if str(gene) != "fitness" and str(gene) != "speciesid":
				if genomeA.has(gene):
					sameGenes += 1
					if genomeB[gene]["weight"] != null:
						averageWeightDifferencesSum += (genomeB[gene]["weight"] - genomeA[gene]["weight"])
				else:
					disjointGenes += 1
	return c1*disjointGenes/totalGenes + c2*averageWeightDifferencesSum/totalGenes

func determineWhichSpeciesToClassifyItAs(genomeA):
	var geneticDistancesArray = []
	var existingSpeciesMatchFound = false
	var tempDistance
	#if initial species
	if self.species_amount == 0:
		var speciesInfoObject = {"speciesid":0, "population":1, "avgfitness":genomeA.fitness, "typicalgenome":genomeA}
		genomeA.speciesid = 0
		self.species_amount += 1
		self.species_array.append(speciesInfoObject)
		return
	for exampleGenomeB in self.species_array:
		tempDistance = geneticDistance(genomeA, exampleGenomeB.typicalgenome)
		print("tempDistance="+str(tempDistance))
		if tempDistance < 2:
			existingSpeciesMatchFound = true
			geneticDistancesArray.append([tempDistance, exampleGenomeB.speciesid])
	#if not initial species but no match is found, add a new species
	if existingSpeciesMatchFound == false:
		self.species_amount += 1
		var speciesInfoObject = {"speciesid":self.species_amount, "population":1, "avgfitness":genomeA.fitness, "typicalgenome":genomeA}
		self.species_array.append(speciesInfoObject)
		genomeA.speciesid = self.species_amount
		return
	else:
		#sort to find closest match, add to species population, incorporate fitness
		#print(geneticDistancesArray)
		var sortedGeneticDistancesArray = geneticDistancesArray.sort_custom(MyCustomSorter, "sort_geneticDistancesArray_ascending")
		#print(sortedGeneticDistancesArray)
		if sortedGeneticDistancesArray != null:
			var closestMatchSpeciesId = self.species_array[sortedGeneticDistancesArray[0][1]] #[[closest genetic distance, speciesid],[],[]]
			var newavgfitness = closestMatchSpeciesId["avgfitness"] * closestMatchSpeciesId["population"]
			closestMatchSpeciesId["population"] += 1
			newavgfitness += genomeA["fitness"]
			closestMatchSpeciesId["avgfitness"] = newavgfitness / closestMatchSpeciesId["population"]
			genomeA["speciesid"] = closestMatchSpeciesId["speciesid"]
		return


func mating(genomeA, genomeB):
	#copy all matching genes
	#if match not found, copy whatever the highest fitness genome has
	var newGenome = {}
	#if genomeA has more elements than genomeB
	if len(genomeA.values()) >= len(genomeB.values()):
		#for each gene in genomeA
		for i in genomeA:
			if i != "fitness" and i != "speciesid":
				#if a matching innovationId can be found in genomeB
				if genomeB.has(i):
					newGenome[i] = genomeA[i]
				else:
					#if genomeB doesnt contain relevant gene
					#if genomeA is overall better than genomeB, go with genomeA
					if genomeA["fitness"] > genomeB["fitness"]:
						newGenome[i] = genomeA[i]
					else:
						pass
						#if they have equal fitness, go with smaller genome (genomeB) which is adding nothing
						#newGenome[i] = genomeB[i]
		mutate_random_weight(newGenome)
	else:
		for i in genomeB:
			if i != "fitness" and i != "speciesid":
				if genomeA.has(i):
					newGenome[i] = genomeB[i]
				else:
					if genomeA["fitness"] > genomeB["fitness"]:
						newGenome[i] = genomeA[i]
					else:
						pass
						#newGenome[i] = genomeB[i]
		mutate_random_weight(newGenome)
	newGenome["fitness"] = 0
	return newGenome

func cloning(genome):
	var newGenome = genome.duplicate(true)
	newGenome.fitness = 0
	return newGenome

func create_new_genome_from_innovation_list():
	var newGenome = {}
	var i = 0
	var innovationIdToPick = 0
	var totalInnovations = len(self.masterInnovationList)
	while i < 8:
		innovationIdToPick = randi()%(totalInnovations+1)+1
		#if random innovationId hasn't already been added
		if newGenome.has(innovationIdToPick) == false:
			newGenome[innovationIdToPick] = self.masterInnovationList[innovationIdToPick]
			i += 1
	return newGenome


func mutate_weight(gene):
	print(gene)
	if randf() < chance_of_each_weight_randomly_mutated:
		if randf() < chance_of_each_weight_uniform_mutation:
			randomize_tweak_weight(gene)
		else:
			randomize_set_weight(gene)
	print(gene)

func randomize_set_weight(gene):
	if gene["weight"] != null:
		gene["weight"] = rand_range(-2.0, 2.0)

func randomize_tweak_weight(gene):
	if gene["weight"] != null:
		gene["weight"] += rand_range(-0.1, 0.1)

func mutate_random_weight(genome):
	print(genome)
	var tempArray = genome.keys()
	randomize()
	var randomKey = tempArray[randi()%len(tempArray)]
	while str(randomKey) == "fitness" or str(randomKey) == "speciesid":
		randomize()
		randomKey = tempArray[randi()%len(tempArray)]
	print('geneID: '+str(randomKey))
	mutate_weight(genome[int(randomKey)])


func chooseMutationType(genome):
	if randf() < chance_mess_with_neuros:
		if randf() < chance_new_neuro:
			addNewNeuroGene()
		if randf() < chance_disable_neuro:
			addDisableNeuroGene()
		if randf() < chance_enable_neuro:
			addEnableNeuroGene()
	elif randf() < chance_mess_with_connections:
		if randf() < connection_weight_mutation_chance:
			addConnectionToInnovationList()
		if randf() < chance_disable_connection:
			addDisableConnectionGene()
		if randf() < chance_enable_connection:
			addEnableConnectionGene()

func addNewNeuroGene():
	#first select existing connection
	var innovationArray = self.masterInnovationList.keys()
	randomize()
	var randomValue = self.masterInnovationList[randi()%len(innovationArray)]
	#make that connection terminate in a new neuro
	var new_neuroId = len(self.masterNeuroGenome.keys())
	self.innovationDictSize += 1
	self.masterInnovationList[self.innovationDictSize] = {"type":"new_neuro", "weight":null, "new_neuroId":new_neuroId, "innovationId":self.innovationDictSize, "enabled":true}
	#add a new connection out from the new neuro
	self.innovationDictSize += 1
	#select neuro to terminate connection in
	self.masterInnovationList[self.innovationDictSize] = {"type":"connection", "in":new_neuroId, "out":5, "weight":0.5, "innovationId":0, "enabled":true}
	print(self.masterInnovationList)

func addEnableNeuroGene():
	var neuroIdToEnable = randi()%(len(self.masterNeuroGenome.keys()))
	if self.masterNeuroGenome[neuroIdToEnable]["enabled"] == false:
		self.innovationDictSize += 1
		self.masterInnovationList[self.innovationDictSize] = {"type":"enable_neuro", "weight":null, "selected_neuroId":neuroIdToEnable, "innovationId":self.innovationDictSize, "enabled":true}
	print(self.masterInnovationList)

func addDisableNeuroGene():
	var neuroIdToDisable = randi()%(len(self.masterNeuroGenome.keys())+1)
	if self.masterNeuroGenome[neuroIdToDisable]["enabled"] == true:
		self.innovationDictSize += 1
		self.masterInnovationList[self.innovationDictSize] = {"type":"disable_neuro", "weight":null, "selected_neuroId":neuroIdToDisable, "innovationId":self.innovationDictSize, "enabled":true}
	print(self.masterInnovationList)

func addEnableConnectionGene():
	var innovationIdToEnable = randi()%self.innovationDictSize
	while self.masterInnovationList[innovationIdToEnable]["type"] != "connection":
		innovationIdToEnable = randi()%self.innovationDictSize
	self.innovationDictSize += 1
	self.masterInnovationList[self.innovationDictSize] = {"type":"enable_connection", "weight":null, "enableInnovationId":innovationIdToEnable, "innovationId":self.innovationDictSize, "enabled":true}
	print(self.masterInnovationList)

func addDisableConnectionGene():
	var innovationIdToEnable = randi()%self.innovationDictSize
	while self.masterInnovationList[innovationIdToEnable]["type"] != "connection":
		innovationIdToEnable = randi()%self.innovationDictSize
	self.innovationDictSize += 1
	self.masterInnovationList[self.innovationDictSize] = {"type":"disable_connection", "weight":null, "disableInnovationId":innovationIdToEnable, "innovationId":self.innovationDictSize, "enabled":true}
	print(self.masterInnovationList)

func addConnectionToInnovationList():
	var newOutConnectionNeuroId = randi()%len(self.masterNeuroGenome.keys())
	var newInConnectionNeuroId = randi()%len(self.masterNeuroGenome.keys())
	var i = 0
	#try to find a connection randomly, cancel after 300 attempts
	while self.masterInnovationList[newOutConnectionNeuroId]["out"].has(newInConnectionNeuroId) and i < 300 and !inputNeurosArray.has(newOutConnectionNeuroId) and !outputNeurosArray.has(newInConnectionNeuroId):
		newOutConnectionNeuroId = randi()%len(self.masterNeuroGenome.keys())
		newInConnectionNeuroId = randi()%len(self.masterNeuroGenome.keys())
	if i < 300:
		self.innovationDictSize += 1
		self.masterInnovationList[self.innovationDictSize] = {"type":"connection", "in":newInConnectionNeuroId, "out":newOutConnectionNeuroId, "weight":0.5, "innovationId":self.innovationDictSize, "enabled":true}
	else:
		print("no connection added")
	print(self.masterInnovationList)

func checkIfConnectionExists(neuroA, neuroB):
	if self.neuros[neuroA]["inputsToNeuro"].has(neuroB):
		if self.neuros[neuroB]["outputsToNeuro"].has(neuroA):
			return true
		else:
			return false
	elif self.neuros[neuroB]["inputsToNeuro"].has(neuroA):
		if self.neuros[neuroA]["outputsToNeuro"].has(neuroB):
			return true
		else:
			return false
	else:
		return false
