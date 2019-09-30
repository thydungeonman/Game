extends KinematicBody2D

var dropspeed = Vector2(0,0)
var maxdropspeed = 100
onready var ray = get_node("RayCast2D")
var dropping = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(!dropping):
		if(ray.is_colliding()):
			if(ray.get_collider().is_in_group("player")):
				dropping = true
	else:
		Fall(delta)


func Fall(delta):
	move(dropspeed * delta)
	dropspeed.y += maxdropspeed * .1
	clamp(dropspeed.y,0,maxdropspeed)
	if(is_colliding()):
		if(get_collider().is_in_group("player")):
			get_collider().take_damage(5)
			#print("spike touched player")
			add_collision_exception_with(get_collider())
		elif(get_collider().is_in_group("wall")):
			#print("spike hit wall")
			get_node("Sprite").set_pos(Vector2(0,8))