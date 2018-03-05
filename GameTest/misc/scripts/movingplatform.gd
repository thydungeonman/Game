extends RigidBody2D
var timer = 0.0
var time = 5
var speed = 1

func _ready():
	set_fixed_process(true)
	set_applied_force(Vector2(0,-200 * speed))

func _fixed_process(delta):
	timer += delta
	
	if timer > time:
		speed *= -1.003
		set_applied_force(Vector2(0,-200 * speed))
	
