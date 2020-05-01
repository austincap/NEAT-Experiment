extends KinematicBody2D


var speed = 200
var velocity = Vector2()

func _ready():
	$Camera2D.current = true

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input()
	velocity = self.move_and_slide(velocity)



#func _input(event):
#	if event.is_action_pressed("ui_right"):
#		velocity.x += 1
#	if event.is_action_pressed("ui_up"):
#		velocity.y += 1
#		#self.position += transform.x * 10
#	if event.is_action_pressed("ui_left"):
#		velocity.x -= 1
#	if event.is_action_pressed("ui_down"):
#		velocity.y -= 1
#	velocity = velocity.normalized() * speed

func _on_Area2D_area_entered(area):
	pass # Replace with function body.
