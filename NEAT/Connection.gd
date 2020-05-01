extends Node
var output = 0.0


#{"type":"connection", "in":1, "out":5, "weight":0.5, "innovationId":0, "enabled":true}
func calculate(connectionGenome, inputData):
	var sum = 0
	for gene in connectionGenome:
		if gene.enabled == true and gene.type == "connection":
			sum += gene.weight * self.neuros[gene.in]["output"]
	self.output = activation_function(sum)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
