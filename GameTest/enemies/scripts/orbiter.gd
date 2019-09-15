extends KinematicBody2D

#always spawn with a static body to the right
#goes clockwise

var damage = 3
var knockbackforce = Vector2(200,7)
enum DIRECTIONS {UP=0,DOWN=1,LEFT=2,RIGHT=3}
 #forward or backward
var speed = 300
var velocity = Vector2(0,-50)

var movement = DIRECTIONS.UP
var state = 1
var timer = 0.0

onready var up = get_node("up")
onready var down = get_node("down")
onready var left = get_node("left")
onready var right = get_node("right")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	timer += delta
	
	
	if(timer > 1):
		if(state == 1):
			if(movement == DIRECTIONS.UP):
				if(right.get_overlapping_bodies().size() == 0):
					movement = DIRECTIONS.RIGHT
					velocity = Vector2(speed,0)
			elif(movement == DIRECTIONS.DOWN):
				if(left.get_overlapping_bodies().size() == 0):
					movement = DIRECTIONS.LEFT
					velocity = Vector2(-speed,0)
			elif(movement == DIRECTIONS.LEFT):
				if(up.get_overlapping_bodies().size() == 0):
					movement = DIRECTIONS.UP
					velocity = Vector2(0,-speed)
			elif(movement == DIRECTIONS.RIGHT):
				if(down.get_overlapping_bodies().size() == 0):
					movement = DIRECTIONS.DOWN
					velocity = Vector2(0,speed)
			
		print(str(movement))
		move(velocity * delta)