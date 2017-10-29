extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var walk = Vector2(0,25)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#set_process(true)
	pass

func _process(delta):
	var motion = walk * delta
	get_node("Label 4").set_text(str(motion))
	var remainder = move(motion)
	var m = remainder
	get_node("Label 3").set_text(str(m))
	if(is_colliding()):
		
		if(walk.x == 0 and get_travel().length() < 5.0 and motion.x < 5.0 and get_collider_velocity() == Vector2()):
			revert_motion()
			motion.y = 0
			print("yes")
		else:
			var colnormal = get_collision_normal()
			remainder = colnormal.slide(remainder)
			get_node("Label").set_text(str(colnormal))
			get_node("Label 2").set_text(str(remainder))
			move(remainder)

