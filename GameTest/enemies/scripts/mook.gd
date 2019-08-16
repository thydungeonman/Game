extends KinematicBody2D
#script for an enemy that does moves on its own back and forth, and has physics
#requires raycasts: forward, back, downleft, downright
#forward begin towards the right, back to the left, the others being on those sides and pointing down
#all raycasts should only cast upon static bodies

#groups: physical, enemy

#ENEMY VARIABLES
var maxhealth = 10
var health = 10
var damagetaketimer= 0.0
var damagetaketime = .1
var cantakedamage = false
var knockbackforce = Vector2(200,7)
var damagegivetimer = 0.0
var damagegivetime = 0.25
var cangivedamage = true
var direction = 1
var state = 1 #0 = dead 1 = walking 2 = stun  3 = held  4 = thrown # make enum some day
var stuncounter = 0.0
var stuncount = .5
var damage = 3

var outsideforce = 0
var motions = []
var verticalmotions = []
var dontmove = false

var speed = Vector2(0,0)
var velocity = 0.0
var gravity = 13
export(float) var FLOOR_ANGLE_TOLERANCE = 40.0
var onfloor = false
var foundplayer = false

onready var downleft = get_node("downleft")
onready var downright = get_node("downright")
onready var wallright = get_node("forward")
onready var wallleft = get_node("back")
onready var sprite = get_node("Sprite")
var flip = false # for flipping the sprite
var standardspeed = 20
var go = 30

var player = null

var wobbly = 0
var stopped = false


onready var vision = get_node("vision")
onready var friendlyvisionleft = get_node("friendlyvisionleft")
onready var friendlyvisionright = get_node("friendlyvisionright")
onready var onfloorlabel = get_node("onfloorlabel")
onready var foundplayerlabel = get_node("foundplayerlabel")
onready var stoppedlabel = get_node("stoppedlabel")
onready var mooklabelleft = get_node("mooklabelleft")
onready var mooklabelright = get_node("mooklabelright")

func _ready():
	set_fixed_process(true)
	#animator.play("walk")
	
func _fixed_process(delta):
	#healthlabel.set_text(str(health))
	#get_node("Label").set_text(str(speed))
	#get_node("state").set_text(str(state))
	#get_node("direction").set_text(str(direction))
	onfloorlabel.set_text(str(onfloor))
	stoppedlabel.set_text(str(stopped))
	get_node("golabel").set_text(str(go))
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
	
	alternate_motion(delta)
	alternate_vertical_motion(delta)
	
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
	elif(state == 5):
		State5(delta)

func State1(delta):
	
	WobblyMovement(delta)
	
	if(vision.get_overlapping_bodies().size() > 1):
		for body in vision.get_overlapping_bodies():
			if(body.is_in_group("player")):
				foundplayer = true
				player = body
				foundplayerlabel.set_text("foundplayer")
				if(body.get_pos().x > get_pos().x and direction == -1):
					FaceRight()
				elif(body.get_pos().x < get_pos().x and direction == 1):
					FaceLeft()
				changestate(5)
				return
	else:
		foundplayerlabel.set_text("no player")
	
	CalculateVelocity(delta)
	var remainder = move(velocity)
	
	if((!downleft.is_colliding()) and onfloor and direction == -1):
		FaceRight()
	if(!downright.is_colliding() and onfloor and direction == 1):
		FaceLeft()
	if(wallleft.is_colliding()):
		if(wallleft.get_collider().is_in_group("wall") or wallleft.get_collider().is_in_group("enemy")):
			FaceRight()
	if(wallright.is_colliding()):
		if(wallright.get_collider().is_in_group("wall") or wallright.get_collider().is_in_group("enemy")):
			FaceLeft()
	
	if(is_colliding() and get_collider().is_in_group("player") and cangivedamage):
		print("enemy hit player")
		var player = get_collider()
		knock_player(player,direction)
	if(is_colliding()):
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			onfloor = true
			
			if(get_collider() != null):
				if(get_collider().is_in_group("bouncer")):
					get_collider().bounce(self)
					onfloor = false
			speed.y = normal.slide(Vector2(0,speed.y)).y
		else:
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
			onfloor = false
	

func State2(delta):
	if(!downleft.is_colliding() and !downright.is_colliding() and onfloor == true):
		onfloor = false
		print("yp")
		
	go = 0
	CalculateVelocity(delta)
	var remainder = move(velocity)
	if(is_colliding()):
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
			onfloor = true
		speed.y = speed.y/-2 #normal.slide(Vector2(0,speed.y)).y
	
	
	stuncounter += delta
	if(stuncounter > stuncount and onfloor):
		stuncounter = 0
		go = standardspeed
		#animator.play("walk")
		state = 1
		
func State3(delta):
	#animator.play("stun")
	#motions.clear()
	#verticalmotions.clear()
	#print("global pos:" + str(get_global_pos()))
	if direction == -1:
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)

func State3_5(delta):
	pass

func State4(delta):
	#thrown.Launch()
	queue_free()

func State5(delta): #found player, enter attack mode
	
	#evade player by lurching back but maintain proximity
	#set random timer to attack
	#if friendly mook is between this and player
	#maintain distance between this and friendly mook
	if(!stopped and !foundplayer):
		changestate(1)
		return
	
	if(!stopped and foundplayer):
		WobblyPlayerMovement(delta)
	
	LookForPlayer()
	
	CalculateVelocity(delta)
	var remainder = move(velocity)
	
	if((!downleft.is_colliding()) and onfloor and direction == -1):
		if(foundplayer):
			StopMoving()
		else:
			FaceRight()
			StartMoving()
	if(!downright.is_colliding() and onfloor and direction == 1):
		if(foundplayer):
			StopMoving()
		else:
			FaceLeft()
			StartMoving()
	if(wallleft.is_colliding()):
		if(wallleft.get_collider().is_in_group("wall") or wallleft.get_collider().is_in_group("enemy")):
			if(foundplayer):
				StopMoving()
			else:
				FaceRight()
				StartMoving()
	if(wallright.is_colliding()):
		if(wallright.get_collider().is_in_group("wall") or wallright.get_collider().is_in_group("enemy")):
			if(foundplayer):
				StopMoving()
			else:
				FaceLeft()
				StartMoving()
	
	if(is_colliding() and get_collider().is_in_group("player") and cangivedamage):
		print("enemy hit player")
		var player = get_collider()
		knock_player(player,direction)
	if(is_colliding()):
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			onfloor = true
			
			if(get_collider() != null):
				if(get_collider().is_in_group("bouncer")):
					get_collider().bounce(self)
					onfloor = false
			speed.y = normal.slide(Vector2(0,speed.y)).y
		else:
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
			onfloor = false

func State6(delta): #found player but friendly is front
	
	
	pass


func take_damage(var damage):
	if(cantakedamage):
		#animator.play("stun")
		if(state != 3 and state != 4):
			state = 2
		cantakedamage = false
		damagetaketimer = 0.0
		health -= damage
		if(health <= 0): #find better way to do this
			cangivedamage = false
			damagegivetimer = 0.0
			state = 0
			#speed.x = 0
			get_node("Sprite").set_opacity(0)
			set_layer_mask(2)
			set_collision_mask(2)
			#animator.play("death")
	
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

func die():
	queue_free()


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

func add_vertical_motion(motion):
	verticalmotions.push_back(motion)

func add_outside_force(var force):
	outsideforce = force


func CalculateVelocity(delta):
	speed.x = go * direction 
	speed.y += gravity
	speed.y += outsideforce
	
	outsideforce = 0
	velocity = speed * delta

func FaceLeft():
	stopped = false
	direction = -1
	sprite.set_flip_h(true)
	wallleft.set_enabled(true)
	wallright.set_enabled(false)
	print("flip to the left")

func FaceRight():
	stopped = false
	direction = 1
	sprite.set_flip_h(false)
	wallleft.set_enabled(false)
	wallright.set_enabled(true)
	print("flip to the right")

func WobblyMovement(delta):
	
	wobbly += delta
	go = abs(sin(wobbly * 2) * 60)
	

func StopMoving():
	go = 0
	stopped = true

func StartMoving():
	go = standardspeed
	stopped = false

func WobblyPlayerMovement(delta):
	var distance = abs(get_pos().x - player.get_pos().x)
	if (distance <= 60):
		go = -50
		if(distance <= 40):
			go = -67 # wacky bug where go can't go below -69
	elif(distance > 100):
		go = 90


func LookForPlayer():
	if(vision.get_overlapping_bodies().size() > 1):
		for body in vision.get_overlapping_bodies():
			if(body.is_in_group("player")):
				foundplayer = true
				foundplayerlabel.set_text("foundplayer")
				if(body.get_pos().x > get_pos().x and direction == -1):
					FaceRight()
				elif(body.get_pos().x < get_pos().x and direction == 1):
					FaceLeft()
				return
		foundplayer = false
		foundplayerlabel.set_text("lost player")
	else:
		foundplayerlabel.set_text("lost player")
		foundplayer = false

