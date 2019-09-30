extends KinematicBody2D

#always spawn with a static body to the right
# GO FOR THE CORNERS

var damage = 3
var knockbackforce = Vector2(200,7)
enum DIRECTIONS {UP=0,DOWN=1,LEFT=2,RIGHT=3}
 #forward or backward
var speed = 30
var velocity = Vector2(0,-50)

var movement = DIRECTIONS.UP
var state = 1
var timer = 0.0

onready var upleft = get_node("upleft")
onready var downleft = get_node("downleft")
onready var lefttop = get_node("lefttop")
onready var righttop = get_node("righttop")

onready var upright = get_node("upright")
onready var downright = get_node("downright")
onready var leftbottom = get_node("leftbottom")
onready var rightbottom = get_node("rightbottom")

onready var toprightcorner = get_node("toprightcorner")
onready var topleftcorner = get_node("topleftcorner")
onready var bottomrightcorner = get_node("bottomrightcorner")
onready var bottomleftcorner = get_node("bottomleftcorner")

onready var directionlabel = get_node("Label")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	timer += delta
	directionlabel.set_text(str(movement))
	
	
	if(timer > .4):
		if(state == 1):
			if(movement == DIRECTIONS.UP):
				if(rightbottom.get_overlapping_bodies().size() == 0 and toprightcorner.get_overlapping_bodies().size() == 0):
					GoRight()
				elif(upright.get_overlapping_bodies().size() > 0):
					GoLeft()
			elif(movement == DIRECTIONS.DOWN):
				if(lefttop.get_overlapping_bodies().size() == 0 and bottomleftcorner.get_overlapping_bodies().size() == 0):
					GoLeft()
				elif(downleft.get_overlapping_bodies().size() > 0):
					GoRight()
			elif(movement == DIRECTIONS.LEFT):
				if(upright.get_overlapping_bodies().size() == 0 and toprightcorner.get_overlapping_bodies().size() > 0):
					GoUp()
				elif(lefttop.get_overlapping_bodies().size() > 0):
					GoDown()
			elif(movement == DIRECTIONS.RIGHT):
				if(downleft.get_overlapping_bodies().size() == 0 and bottomrightcorner.get_overlapping_bodies().size() == 0):
					GoDown()
				elif(rightbottom.get_overlapping_bodies().size() > 0):
					GoUp()
			
		#print(str(movement))
		move(velocity * delta)
		if(is_colliding()):
			if(get_collider().is_in_group("player")):
				var knock = 1
				if(movement == 2):
					knock = -1
				knock_player(get_collider(),knock)


func knock_player(var player, var direction = 1):
	#print(str(direction))
	if(player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(damage)
		player.invincounter = 0.0

func GoUp():
	movement = DIRECTIONS.UP
	velocity = Vector2(0,-speed)
func GoDown():
	movement = DIRECTIONS.DOWN
	velocity = Vector2(0,speed)
func GoLeft():
	movement = DIRECTIONS.LEFT
	velocity = Vector2(-speed,0)
func GoRight():
	movement = DIRECTIONS.RIGHT
	velocity = Vector2(speed,0)