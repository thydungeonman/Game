extends KinematicBody2D

#movement variables
var direction = 0
var input_direction = 0
var speed_x = 0
var speed_y = 0
var speed = Vector2()
var velocity = Vector2()
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
export(int) var MAX_SPEED = 200
export(int) var ACCELERATION = 1700
export(int) var DECELERATION = 2000
export(int) var LOW_JUMP_FORCE = 350
export(int) var JUMP_FORCE = 150
export(int) var GRAVITY = 1400
export(float) var FLOOR_ANGLE_TOLERANCE = 40.0
#jumping variables
var jump_count = 0
var lowjump = false
var jumppresstime = 0.0
export(float) var HIGHJUMPTIME = .2
var max_jump_count = 1
var airtime = 0.0
var onfloor = false
var jumping = false
#sprite for flipping
onready var player_sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
#game variables
var health = 10
var presstime= 0.0
var invincounter = 0.0
var invintime = 1.5
#duck variable
var ducking = false
#Attact variables
var attack = false
var attacking = false
var attacktime = 0.0
var attackbreakcounter = 0.0 #counter to wait until attackbreak is up
var attackbreak = .2
#alternate motion variables
var motions = []
#input halting variables
var canmovetimer = 2.1
var canmovetime = 0.5


func _ready():
	set_fixed_process(true)
	set_process(true)
	set_process_input(true)

func _input(event):
	pass

func _process(delta):
	#INPUTS and direction
	GetInputs(delta)
	#move this into getInputs
	if(Input.is_action_pressed("ui_jump")):
		jumppresstime += delta
		presstime+= delta
	else:
		jumppresstime = 0.0


func _fixed_process(delta):
	#ALTERNATE MOTIONS
	alternate_motion(delta)
	#ATTACKING
	handle_attack(delta)
	#HORIZONTAL MOVEMENT
	HandleMovement(delta)



func GetInputs(delta):
	canmovetimer += delta
	if canmovetimer >= canmovetime:
		canmovetimer = 10 #just incase theres a problem with this rising forever
		attack = Input.is_action_pressed("ui_attack")
		if(direction):
			input_direction = direction
		if(not Input.is_action_pressed("ui_duck")):
			ducking = false
			if(Input.is_action_pressed("ui_right")):
				direction = 1
				player_sprite.set_flip_h(false)
			elif(Input.is_action_pressed("ui_left")):
				direction = -1
				player_sprite.set_flip_h(true)
			else:
				anim.play("restpose")
				direction = 0
		else:
			anim.play("duck")
			direction = 0
			ducking = true
	else:
		direction = 0

func HandleMovement(delta):
	Jump(delta)
	#HORIZONAL MOVEMENT
	if(input_direction == - direction):
		speed.x = 0
	if(direction):
		speed.x += ACCELERATION * delta
	else:
		speed.x -= DECELERATION * delta
	
	speed.x = clamp(speed.x,0,MAX_SPEED)
	velocity.x = speed.x * input_direction * delta
	speed.y += GRAVITY * delta
	velocity.y = speed.y * delta
	
	var remainder = move(velocity)
	get_node("angel label").set_text(str(onfloor))
	
	#COLLSIIONS
	if(is_colliding()):
		if(get_collider().is_in_group("enemy")):
			#if touched enemy
			print("player touch enemy")
			get_collider().knock_player(self,-1)
			print("sdfsd")
		var floorvel = Vector2()
		var normal = get_collision_normal()
		if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			#if touched floor or floor with tolerated angle
			onfloor = true
			jumping = false
			jumppresstime = 0.0
			jump_count = 0
			speed.y = normal.slide(Vector2(0,speed.y)).y
			floorvel = get_collider_velocity()
			get_node("normallabel").set_text(str(airtime))
			get_node("Label").set_text(str(presstime))
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
		if(floorvel != Vector2()):
			#if floor is not stationary
			move(floorvel * delta)
	elif(!is_colliding() and onfloor == true):
		onfloor = false
	else:
		airtime += delta


func Jump(delta):
	if(Input.is_action_pressed("ui_jump")):
	#if pressed jump button and havent jumped more times than allowed and on the floor
		if(onfloor and jump_count < max_jump_count and jumppresstime < .035):
			presstime= 0
			airtime = 0.0
			speed.y = -LOW_JUMP_FORCE
			jumping = true
			lowjump = true
			jump_count += 1
		onfloor = false
		if(jumppresstime > .06 and airtime < .16 and jumping and lowjump):
			speed.y += -JUMP_FORCE
			lowjump = false

func handle_attack(var delta):
	attackbreakcounter += delta
	invincounter += delta
	if(attack and not attacking and not ducking and attackbreakcounter > attackbreak):
		var attack = preload("res://player/scenes/punch.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 15,0))
		attackbreakcounter = 0.0
	elif(attack and not attacking and ducking and attackbreakcounter > attackbreak):
		var attack = preload("res://player/scenes/kick.tscn").instance()
		self.add_child(attack)
		attack.set_pos(Vector2(input_direction * 15,10))
		print("kick")
		attackbreakcounter = 0.0
	attacking = attack



func take_damage(var damage):
	canmovetimer = 0.0
	
	if(invincounter > invintime):
		invincounter = 0.0
		health -= damage
		print("health is "+str(health))
		if(health <= 0):
			get_node("label").set_text("GAME OVER")

#for knockbacks when taking damage
func alternate_motion(var delta):
	if(motions.size() > 0):
		#print(str(motions[0]))
		for n in range(motions.size()):
			var rest = move(Vector2(motions[n].x,0) * delta)
			if(is_colliding()):
				var floorvel = Vector2()
				var normal = get_collision_normal()
				if(rad2deg(acos(normal.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
					#if touched floor or floor with tolerated angle
					onfloor = true
					jumping = false
					jumppresstime = 0.0
					jump_count = 0
					speed.y = normal.slide(Vector2(0,speed.y)).y
					floorvel = get_collider_velocity()
					get_node("normallabel").set_text(str(airtime))
					get_node("Label").set_text(str(presstime))
					rest = normal.slide(rest)
					velocity = normal.slide(velocity)
					move(rest)
				if(normal == Vector2(1,0) or normal == Vector2(-1,0)):
					# if hit flat wall
					motions[n].x = 0 
			elif(!is_colliding() and onfloor == true):
				onfloor = false
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

func add_horizontal_motion(var motion):
	motions.append(motion)
	#x is the horizontal motion
	#y is how much to lower that per second multiplied my delta
	#remember that the second value must be the same sign as the first as the second is subtracted from the first
func add_vertical_motion(var motion):
	speed.y += motion
	airtime = 0.0
	


