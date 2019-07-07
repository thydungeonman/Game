extends KinematicBody2D

#ENEMY VARIABLES
var maxhealth = 50
var health = 50
var standardspeed = 20
var go = 20
var speed = Vector2(0,0)
var damagetaketimer= 0.0
var damagetaketime = .1
var cantakedamage = false
var knockbackforce = Vector2(200,7)
var damagegivetimer = 0.0
var damagegivetime = 0.25
var cangivedamage = true
var direction = 1
var velocity = 0.0
var state = 1 #0 = dead 1 = walking 2 = stun  3 = held  4 = thrown # make enum some day
var motions = []
var verticalmotions = []
var stuncounter = 0.0
var stuncount = .5
var damage = 3
var dontmove = false
var thrownstartingpos = Vector2(0,0)
var flip = false # for flipping the sprite
var onfloor = true


onready var downleft = get_node("downleft")
onready var downright = get_node("downright")
onready var wallright = get_node("forward")
onready var wallleft = get_node("back")

onready var sprite = get_node("Sprite")
onready var animator = get_node("AnimationPlayer")
#onready var particles = get_node("Particles2D")
#onready var healthlabel = get_node("healthlabel")

var gravity = 800
export(float) var FLOOR_ANGLE_TOLERANCE = 40.0
var thrown #thrown enemy scene. 

func _ready():
	set_fixed_process(true)
	#animator.play("restpose")
	#animator.play("walk")
	#get_node("thrown").set_collision_mask(2)
	#get_node("thrown").set_layer_mask(2)

func _fixed_process(delta):
	#healthlabel.set_text(str(health))
	get_node("Label").set_text(str(speed))
	get_node("state").set_text(str(state))
	get_node("direction").set_text(str(direction))
	
	alternate_motion(delta)
	alternate_vertical_motion(delta)
	damagegivetimer += delta
	damagetaketimer += delta
	
	if(damagetaketimer > damagetaketime):
		cantakedamage = true
	else:
		cantakedamage = false
	if(damagegivetimer >= damagegivetime):
		cangivedamage = true
	else:
		cangivedamage = false
	
	
	if(state == 1): #ALIVE
		State1(delta)
	elif(state == 2): #STUNNED
		State2(delta)
	elif(state == 3): #HELD
		State3(delta)
	elif(state == 3.5): #RIGHT BEFORE THROWN
		State3_5(delta)
	elif(state == 4): #THROWN
		State4(delta)
	

func State1(delta):
	#KEEP TIME
	#MOVEMENT
	speed.x = go * direction
	speed.y += gravity * delta
	velocity = speed * delta
	var remainder = move(velocity)
	#print(str(downleft.is_colliding()))
	if((!downleft.is_colliding()) and onfloor and direction == -1): # may want to specify direction as well at some point
		direction = 1
		sprite.set_flip_h(false)
		wallleft.set_enabled(false)
		wallright.set_enabled(true)
	if(!downright.is_colliding() and onfloor and direction == 1):
		direction = -1
		sprite.set_flip_h(true)
		wallleft.set_enabled(true)
		wallright.set_enabled(false)
	if(wallleft.is_colliding()):
		#print(str(wallleft.get_collider().is_in_group("wall")))
		if(wallleft.get_collider().is_in_group("wall") or wallleft.get_collider().is_in_group("enemy")):
			direction = 1
			sprite.set_flip_h(false)
			wallleft.set_enabled(false)
			wallright.set_enabled(true)
	if(wallright.is_colliding()):
		if(wallright.get_collider().is_in_group("wall") or wallright.get_collider().is_in_group("enemy")):
			direction = -1
			sprite.set_flip_h(true)
			wallleft.set_enabled(true)
			wallright.set_enabled(false)

#	
	if(is_colliding()):
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			onfloor = true
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
		speed.y = normal.slide(Vector2(0,speed.y)).y
	else:
		onfloor = false
	
	if(is_colliding() and get_collider().is_in_group("player") and cangivedamage):
		print("enemy hit player")
		var player = get_collider()
		knock_player(player,direction)

func State2(delta):
	go = 0
	speed.y += gravity * delta
	speed.x = go * direction
	velocity = speed * delta
	var remainder = move(velocity)
	if(is_colliding()):
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
		speed.y = speed.y/-20 #normal.slide(Vector2(0,speed.y)).y
	
	stuncounter += delta
	if(stuncounter > stuncount):
		stuncounter = 0
		go = standardspeed
		animator.play("walk")
		state = 1
		
func State3(delta):
	motions.clear()
	verticalmotions.clear()
	#print("global pos:" + str(get_global_pos()))
	if direction == -1:
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)

func State3_5(delta):
	thrown = preload("res://enemies/scenes/physical thrown.tscn").instance()
	get_parent().add_child(thrown)
	print("global pos:" + str(get_global_pos()))
	thrown.set_global_pos(thrownstartingpos + Vector2(20*direction,0))
	thrown.add_collision_exception_with(self)
	if(direction == -1):
		thrown.FaceLeft()
	changestate(4)

func State4(delta):
	thrown.Launch()
	queue_free()

func die():
	queue_free()

func take_damage(var damage):
	if(cantakedamage):
		animator.play("stunned")
		if(state != 3 and state != 4):
			state = 2
		cantakedamage = false
		damagetaketimer = 0.0
		health -= damage
		if(health <= 0): #find better way to do this
			cangivedamage = false
			damagegivetimer = 0.0
			state = 0
			speed.x = 0
			get_node("Sprite").set_opacity(0)
			set_layer_mask(2)
			set_collision_mask(2)
			animator.play("death")

func knock_player(var player, var direction = 1):
	#print(str(direction))
	if(cangivedamage and player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(damage)
		damagegivetimer = 0.0
		cangivedamage = false
		player.invincounter = 0.0

func alternate_motion(var delta):
	if(motions.size() > 0):
		#print(str(motions[0]))
		for n in range(motions.size()):
			var rest = move(Vector2(motions[n].x,0) * delta)
			#print(str(motions[n]) + " " + str(n))
			motions[n].x -= motions[n].y
		var finished = null
		for n in motions:
			if n.x <= 20 and n.x >= -20:
				finished = n
		if finished != null:
			motions.remove(motions.find(finished))
		if dontmove == true:
			dontmove = false
			motions.clear()
func add_horizontal_motion(var motion):
	motions.append(motion)
func changestate(var newstate):
	state = newstate

func alternate_vertical_motion(delta):
	if(verticalmotions.size() > 0):
		for n in range(verticalmotions.size()):
			var rest = move(Vector2(0,verticalmotions[n].x) * delta)
			verticalmotions[n].x -= verticalmotions[n].y
		var finished = null
		for n in verticalmotions:
			if(n.x <= 20 and n.x >= -20):
				finished = n
		if(finished != null):
			verticalmotions.remove(verticalmotions.find(finished))
func add_vertical_motion(motion):
	verticalmotions.push_back(motion)