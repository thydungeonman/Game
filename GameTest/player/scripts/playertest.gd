extends KinematicBody2D
#test script for player input and movement
#as inelegant as it is, most things work around resetting timers
#try to find a better solution - state machine maybe

#coding error: when doing a super attack a regular punch is still done
#a way to solve this may be to have punches done by checking the last input
#in the buffer, clearing it, then doing the punch
#this way all attacks go through the buffer

#BUG
#If held enemy is killed while held: game crashes

#movement variables
var direction = 0
var input_direction = 1
var speed_x = 0
var speed_y = 0
var speed = Vector2()
var velocity = Vector2()
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
export(int) var MAX_SPEED = 150
export(int) var ACCELERATION = 1700
export(int) var DECELERATION = 2000
export(int) var LOW_JUMP_FORCE = 350
export(int) var JUMP_FORCE = 150
export(int) var GRAVITY = 1800 #1800
export(float) var FLOOR_ANGLE_TOLERANCE = 40.0
#jumping variables
var shortjumpslowdownlockout = false
var jump_count = 0
var lowjump = false
var jumppresstime = 0.0
export(float) var HIGHJUMPTIME = .2
var max_jump_count = 1
var airtime = 0.0
var onfloor = false
var jumping = false
var bunnyhopstopper = false
var bunnyhopstopperpart2 = false
var newjumpforce = 0
export(float) var newjumpforcefull = 120
var hithead = false
#sprite for flipping
onready var player_sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
#health and damage variables
var health = 10
var presstime= 0.0
var invincounter = 0.0  
var invintime = 1.5 # make sure this is synced up with the blink time
var damageblinktimer = 5 #this is high so the player doesnt start blinking
var damageblinking = false
#duck variable
var ducking = false
#Attack variables
var attack = false
var attacking = false
var attacktime = 0.0
var attackbreakcounter = 0.0 #counter to wait until attackbreak is up
var attackbreak = .30 #.2
var riderkicked = false
#deflecting variables
var deflect = false
var deflecting = false
var deflecttime = 0.0
var deflectbreakcounter = 0.0
var deflectbreak = .5
#alternate motion variables
var motions = []
#alternate verical motion variables
var verticalmotions = []
#input halting variables
var canmovetimer = 2.1
var canmovetime = 0.5
#input buffer variables
var inputtimer = 0.0
var sincelastinput = 0.0
var inputbuffer = []
var down = false
var right = false
var left = false
var up = false
var B = false
var taptimer = 0.0
var taptime = .175
var specialing = false
#viewport changing variables
var makingscreenbigger = false
var makingscreensmaller = false
#Gravity changing variables
var defaultgravityvalue = 1800
var timepicked = 0.0
var gravitytimer = 0.0
var changedgravity = false
#input polling variables
var inputtimepicked = 0.0
var pollinginput = true
var inputcancelingtimer = 0.0
#grabbing variables
var grab = false
var grabbing = false
var grabtime = 0.3
var grabtimer = 0.0
var currentlyholdingenemy = false
var heldenemy

var numdashesallowed = 1#var for handling only being able to dash once while in the air
var numdashes = 0

onready var inplabel = get_node("inputlabel")
onready var molabel = get_node("motionlabel")
onready var area = get_node("Area2D")

var superattacking = false

#animation controller variables
var bpressed = false
var apressed = false
var leftpressed = false
var rightpressed = false
var downpressed = false



func _ready():
	set_fixed_process(true)
	set_process(true)
	set_process_input(true)

func _input(event):
	pass

func _process(delta):
	#INPUTS and direction
	if pollinginput:
		GetInputs(delta)
	
	InputCancelBack(delta)
	


func _fixed_process(delta):
	
	if(Input.is_action_pressed("ui_deflect")):
		if(numdashes > 0):
			for body in area.get_overlapping_bodies():
				if(body.is_in_group("enemy")):
					motions.clear()
	
	#get_node("label").set_text(str(airtime))
	get_node("label").set_text("Health: " + str(health))
	get_node("normallabel").set_text("overlaps: "+str(get_node("Area2D").get_overlapping_bodies().size()))
	#GRAVITY
	GravityChange(delta)
	#ALTERNATE MOTIONS
	alternate_motion(delta)
	alternate_vertical_motion(delta)
	#INPUT BUFFER FOR COMPLEX INPUTS
	handle_input_buffer(delta)
	#ATTACKING
	handle_attack(delta)
	#DEFLECTING
	handle_delfect(delta)
	#GRABBING
	handle_grab(delta)
	#HORIZONTAL MOVEMENT
	HandleMovement(delta)
	
	molabel.set_text("")
	for x in verticalmotions:
		molabel.set_text(molabel.get_text() + str(x) + "\n")
	get_node("invinlabel").set_text(str(invincounter))
	damage_blink(delta)

func GravityChange(delta):
	if changedgravity:
		gravitytimer += delta
		if gravitytimer >= timepicked:
			GRAVITY = defaultgravityvalue
			changedgravity = false
			gravitytimer = 0.0
			timepicked = 0.0

func GravityFront(var time):
	if !changedgravity:
		timepicked = time
		changedgravity = true
		GRAVITY = 0
		speed = Vector2(0,0)

func InputCancelFront(var time):
	if pollinginput:
		inputtimepicked = time
		direction = 0
		pollinginput = false

func InputCancelBack(delta):
	if!pollinginput:
		inputcancelingtimer += delta
		if inputcancelingtimer >= inputtimepicked:
			inputcancelingtimer = 0.0
			inputtimepicked = 0.0
			pollinginput = true

func handle_input_buffer(delta):
	#TODO FIX BUG 
	#the time between the first and second imput of a three input combo doesn't matter
	#TODO maybe add a gap between combos being able to be excecuted so a player can't dash almost forever
#	inputtimer += delta
	sincelastinput += delta
	specialing = false
#	if inputtimer > 0.4:
#		if inputbuffer.size() > 0:
#			inputbuffer.pop_front()
#			inputtimer = 0.0
	#CHECKING BUFFER FOR PROPER INPUTS AND THEN ADDING EFFECT
	if inputbuffer.size() >= 2:
		if inputbuffer[inputbuffer.size() - 1] == "right" and inputbuffer[inputbuffer.size() - 2] == "right" and taptimer < taptime and numdashes < numdashesallowed:
			add_horizontal_motion(Vector2(400,20))
			inputbuffer.clear()
			GravityFront(.3)
			speed.y = 0
			speed.x = 0
			onfloor = false
			numdashes += 1
		elif inputbuffer[inputbuffer.size() - 1] == "left" and inputbuffer[inputbuffer.size() - 2] == "left" and taptimer < taptime and numdashes < numdashesallowed:
			add_horizontal_motion(Vector2(-400,-20))
			inputbuffer.clear()
			GravityFront(.3)
			onfloor = false
			speed.y = 0
			speed.x = 0
			numdashes += 1
		elif inputbuffer[inputbuffer.size() - 3] == "down" and inputbuffer[inputbuffer.size() - 2] == "up" and inputbuffer[inputbuffer.size() - 1] == "attack" and taptimer < taptime:
			print("SUPER ATTACK")
			specialing = true
			var lightningattackrange = preload("res://player/scenes/lightningattackrange.tscn").instance()
			lightningattackrange.first = true
			lightningattackrange.direction = input_direction
			add_child(lightningattackrange)
			inputbuffer.clear()
	inplabel.set_text("")
	for x in inputbuffer:
		inplabel.set_text(inplabel.get_text() + str(x) + "\n" )
	if pollinginput:
		if Input.is_action_pressed("ui_right"):
			if !right:
				inputbuffer.append("right")
				taptimer = sincelastinput
				sincelastinput = 0.0
			right = true
		else:
			right = false
		if Input.is_action_pressed("ui_left"):
			if !left:
				inputbuffer.append("left")
				taptimer = sincelastinput
				sincelastinput = 0.0
			left = true
		else:
			left = false
		if Input.is_action_pressed("ui_attack"):
			if !B:
				inputbuffer.append("attack")
				taptimer = sincelastinput
				sincelastinput = 0.0
			B = true
		else:
			B = false
		if Input.is_action_pressed("ui_duck"):
			if !down:
				inputbuffer.append("down")
				taptimer = sincelastinput
				sincelastinput = 0.0
			down = true
		else:
			down = false
		if Input.is_action_pressed("ui_up"):
			if !up:
				inputbuffer.append("up")
				taptimer = sincelastinput
				sincelastinput = 0.0
			up = true
		else:
			up = false

func GetInputs(delta):
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_page_up"):
		if !makingscreenbigger:
			var rect = get_viewport().get_rect()
			if rect.size.x < 1000:
				rect.size *= 1.25
			print(rect.size)
			get_viewport().set_rect(rect)
			makingscreenbigger = true
	else:
		makingscreenbigger = false
	if Input.is_action_pressed("ui_page_down"):
		if !makingscreensmaller:
			var rect = get_viewport().get_rect()
			if rect.size.x > 430:
				rect.size /= 1.25
			print(rect.size)
			get_viewport().set_rect(rect)
			makingscreensmaller = true
	else:
		makingscreensmaller = false
	
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	#movement controls onward
	if pollinginput:
		attack = Input.is_action_pressed("ui_attack")
		deflect = Input.is_action_pressed("ui_deflect")
		grab = Input.is_action_pressed("ui_grab")
		if(direction):
			input_direction = direction
		if Input.is_action_pressed("ui_right"):
			if direction == 0 or direction == -1:
				anim.play("run")
			direction = 1
			player_sprite.set_flip_h(false)
			
		elif(Input.is_action_pressed("ui_left")):
			if direction == 0 or direction == 1:
				anim.play("run")
				direction = -1
				player_sprite.set_flip_h(true)
		elif Input.is_action_pressed("ui_duck"):
			#anim.play("duck")
			ducking = true
			direction = 0
		else:
			#anim.play("restpose")
			ducking = false
			if direction != 0:
				anim.play("restpose")
			direction = 0
#		if(not Input.is_action_pressed("ui_duck")):
#			ducking = false
#			if(Input.is_action_pressed("ui_right")):
#				direction = 1
#				player_sprite.set_flip_h(false)
#			elif(Input.is_action_pressed("ui_left")):
#				direction = -1
#				player_sprite.set_flip_h(true)
#			else:
#				anim.play("restpose")
#				direction = 0
#		else:
#			anim.play("duck")
#			direction = 0
#			ducking = true
	else:
		direction = 0
	if(Input.is_action_pressed("ui_jump")):
		jumppresstime += delta
		presstime+= delta
		bunnyhopstopper = true
	else:
		bunnyhopstopper = false
		if(onfloor == false):
			lowjump = false
	
	
	
	#ANIMATION CONTROLLER
	if(Input.is_action_pressed("ui_attack")):
		if bpressed == false and specialing == false:
			bpressed = true
			if ducking:
				pass
			else:
				pass
				#anim.play("punch")
	else:
		bpressed = false
	if(Input.is_action_pressed("ui_duck")):
		if downpressed == false:
			downpressed = true
			anim.play("duck")
	else:
		if downpressed:
			downpressed = false
			anim.play("restpose")
	#i believe moving left and right can be handled similarly to ducking
	

func HandleMovement(delta):
	if(bunnyhopstopperpart2 == false):
		Jump(delta)
	#HORIZONAL MOVEMENT
	if(input_direction == - direction):
		speed.x = 0
	if(direction):
		speed.x += ACCELERATION * delta
	else:
		speed.x -= DECELERATION * delta
	
	speed.x = clamp(speed.x,0,MAX_SPEED)
	speed.y = clamp(speed.y, -500,400)
	velocity.x = speed.x * input_direction * delta
	speed.y += GRAVITY * delta
	velocity.y = speed.y * delta
	
	var remainder = move(velocity)
	get_node("angel label").set_text(str(onfloor))
	
	#COLLSIIONS
	if(is_colliding()):
		if((get_collider().is_in_group("enemy") and get_collider().state != 2) or get_collider().is_in_group("projectile") and invincounter > invintime):
			#if touched enemy
			if damageblinking != true:
				damageblinktimer = 0.0
			print("player touch enemy")
			get_collider().knock_player(self,-input_direction)
			#anim.play("invincible")
			print("sdfsd")
		var floorvel = Vector2()
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			#if touched floor or floor with tolerated angle
			
			#if holding the jump button right as touching
			#the ground from a jump
			if(jumping and bunnyhopstopper):
				bunnyhopstopperpart2 = true
			else: 
				bunnyhopstopperpart2 = false
				jumping = false
			onfloor = true
			numdashes = 0
			riderkicked = false
			newjumpforce = newjumpforcefull
			airtime = 0.0
			jumppresstime = 0.0
			jump_count = 0
			hithead = false
			speed.y = normal.slide(Vector2(0,speed.y)).y
			floorvel = get_collider_velocity()
			#get_node("normallabel").set_text(str(airtime))
			get_node("Label").set_text(str(presstime))
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE and get_collider().is_in_group("button")):
			get_collider().anim.play("closed")
			#trigger button events
		if(speed.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and velocity.x < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			#if is on slanted floor and would have slid down by 1 pixel
			revert_motion()
			velocity.y = 0
		else:
			remainder = normal.slide(remainder)
			velocity = normal.slide(velocity)
			move(remainder)
		if(normal == Vector2(1,0) or normal == Vector2(-1,0)):
			# if hit flat wall
			speed.x = 0
		if(normal == Vector2(0,1)):
			#if hit roof
			speed.y = 0
			hithead = true
		if(floorvel != Vector2()):
			#if floor is not stationary
			move(floorvel * delta)
	elif(!is_colliding() and onfloor == true):
		onfloor = false
	else:
		airtime += delta


func Jump(delta):
	if(Input.is_action_pressed("ui_jump")):
		if onfloor:
			shortjumpslowdownlockout = true
		if((onfloor or (airtime < .013 and jumping == false)) and pollinginput):
#			print(jumping)
			presstime= 0
			airtime = 0.0
			jumping = true
			lowjump = true
			speed.y += -150
		if(lowjump and jumppresstime < .185 and bunnyhopstopper):
			speed.y += -newjumpforce
			newjumpforce -= newjumpforce/4
			newjumpforce = clamp(newjumpforce,0,100)
#			print(str(newjumpforce))
		onfloor = false
	else:
		if shortjumpslowdownlockout == true and jumppresstime < .28 and !onfloor and hithead == false:
			speed.y = -250#-150
			shortjumpslowdownlockout = false
			#bug as a feature? time your jump release to get an additional boost
		else:
			shortjumpslowdownlockout = false

func handle_attack(var delta):
	
	attackbreakcounter += delta
	invincounter += delta
	if(attack and !attacking and !deflecting and !grabbing and !currentlyholdingenemy and !ducking and attackbreakcounter > attackbreak and !specialing and !Input.is_action_pressed("ui_up")):
		anim.play("punch")
		print("punch")
		print("super attack: ",superattacking)
		var attack = preload("res://player/scenes/punch.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 18,0))
		attackbreakcounter = 0.0
		#add_horizontal_motion(Vector2(100 * input_direction,10 * input_direction))
		if(onfloor):
			add_horizontal_motion(Vector2(100 * input_direction,5 * input_direction))
		inputbuffer.clear()
	elif(attack and not attacking and !deflecting and !grabbing and ducking and onfloor and attackbreakcounter > attackbreak):
		var attack = preload("res://player/scenes/kick.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 15,10))
		print("kick")
		attackbreakcounter = 0.0
	elif(attack and not attacking and !deflecting and !grabbing and not onfloor and down and attackbreakcounter > attackbreak and !riderkicked):
		var attack = preload("res://player/scenes/rider kick.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 13,20))
		print("rider kick")
		GravityFront(.4)
		InputCancelFront(.3)
		add_horizontal_motion(Vector2(input_direction * 300,15 * input_direction))
		add_vertical_motion(Vector2(300,15))
		attackbreakcounter = 0.0
		riderkicked = true
	elif(attack and not attacking and !deflecting and !grabbing and !currentlyholdingenemy and !ducking and attackbreakcounter > attackbreak and !specialing and Input.is_action_pressed("ui_up")):
		anim.play("punch")
		var attack = preload("res://player/scenes/uppercut.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 18,0))
		attackbreakcounter = 0.0
		print("uppercut")
	attacking = attack

func handle_delfect(var delta):
	deflectbreakcounter += delta
#	print(deflectbreakcounter)
	if(deflect and not deflecting and not attacking and !grabbing and deflectbreakcounter > deflectbreak):
		deflectbreakcounter = 0.0
		var deflect = preload("res://player/scenes/deflect.tscn").instance()
		self.add_child(deflect)
		deflect.set_pos(Vector2(input_direction * 15,0))
	deflecting = deflect

func handle_grab(var delta):
	grabtimer += delta
	if(grab and !grabbing and !currentlyholdingenemy and !attacking and grabtimer > grabtime):
		grabtimer = 0.0
		var grab = preload("res://player/scenes/grab.tscn").instance()
		self.add_child(grab)
		grab.set_pos(Vector2(input_direction * 20,0))
	if currentlyholdingenemy:
#		print(get_child(11))
		heldenemy.direction = input_direction
		if(grab and !grabbing): #pressing button again to throw
			heldenemy.changestate(3.5)
			heldenemy.thrownstartingpos = get_pos()
			print(str(get_pos()))
			remove_child(heldenemy)
			get_parent().add_child(heldenemy)
			currentlyholdingenemy = false
	grabbing = grab


func take_damage(var damage):
	get_node("CameraAnimator").play("rumble")
	InputCancelFront(1.0)
	damageblinktimer = 0.0
	get_node("label").set_text(str(health))
	attackbreakcounter = 0.0
	if(invincounter > invintime):
		invincounter = 0.0
		health -= damage
		speed.y = 0
		print("health is "+str(health))
		if(health <= 0):
			get_node("label").set_text("GAME OVER")

#for knockbacks when taking damage
func alternate_motion(var delta):
	if(motions.size() > 0):
		#print(str(motions[0]))
		for n in range(motions.size()):
			var rest = move(Vector2(motions[n].x,0) * delta)
			motions[n].x -= motions[n].y
		var finished = null
		for n in motions:
			if n.x <= 20 and n.x >= -20:
				finished = n
		if finished != null:
			motions.remove(motions.find(finished))
	#take array of vector2s of x motion and how much to decrease it by each frame
	#apply motion and its rest if collided, and decrease it for next frame
	#if motion has decreased to zero or less remove it
	#hope this doesnt lag
	
	#put this function in fixed process and have it take delta
	#have an enemy trigger a function that lets them add a vector to the array rather than
	#the enemy affecting the array directly
	#also fix function
	#TODO get it to go towards zero
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

func add_horizontal_motion(var motion):
	motions.append(motion)
	#x is the horizontal motion
	#y is how much to lower that per second multiplied by delta
	#remember that the second value must be the same sign as the first as the second is subtracted from the first
func add_vertical_motion(var motion):
	verticalmotions.append(motion)
	airtime = 0.0

func clear_motions():
	motions.clear()
	verticalmotions.clear()

#reset damageblink timer to blink
func damage_blink(delta):
	damageblinktimer += delta
	if(damageblinktimer < 1.5):
		damageblinking = true
		if((fmod(damageblinktimer,.33)) > .17):
			player_sprite.hide()
		else:
			player_sprite.show()
	else:
		damageblinking = false


