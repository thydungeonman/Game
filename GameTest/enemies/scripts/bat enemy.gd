extends KinematicBody2D
#bat
#flies back and forth. If player is within 150 pixels it swoops
#at player. Maybe add if it hits a wall while swooping it is stunned and falls

#ENEMY VARIABLES
var maxhealth = 10
var health = 10
var speed = Vector2(10,0)
var damagetaketimer= 0.0
var damagetaketime = .1
var cantakedamage = true
var knockbackforce = Vector2(300,7)
var damagegivetimer = 0.0
var damagegivetime = 0.25
var cangivedamage = true
var direction = 1
var velocity = 0.0
var state = 1 #0 = dead  1 = flying  2 = stun  5 = swooping  6 = right after stun state #make enum some day
var motions = []
var stuncounter = 0.0
var stuncount = 1.0
var damage = 3
var dontmove = false
var flip = false
var thrownstartingpos = Vector2(0,0)
#experimental
var gravity = 125


#bat specific variables
export(int) var radiushorizontalfull = 100
var positionhorizontal = 0
var speedhorizontal = 60
onready var defaultheight = get_pos().y
var proximitytoplayer = 0
export(int) var proximitythreshold = 150
export(int) var radiusverticalfull = 10
var positionvertical = 0
var speedvertical = 20
var thing = 0
var thang = 0
var swoop = 0
var swoopmultiple = 0
onready var animator = get_node("AnimationPlayer")
onready var healthlabel = get_node("Health label")

func _ready():
	set_fixed_process(true)
	get_node("thrown").set_collision_mask(2)
	get_node("thrown").set_layer_mask(2)

func die():
	queue_free()

func _fixed_process(delta):
	healthlabel.set_text("Health: " + str(health))
	alternate_motion(delta)
	
	
	
	if state == 0: #dead
		die()
	elif state == 1: #alive and moving
		positionhorizontal += delta*speedhorizontal
#		print(positionvertical)
		positionvertical = sin(thing * 10)
		thing += delta
		move(Vector2(delta * speedhorizontal,positionvertical))
		
		if(abs(positionhorizontal) > radiushorizontalfull):
			speedhorizontal = -speedhorizontal
			direction *= -1
			get_node("Sprite").set_flip_h(!get_node("Sprite").is_flipped_h())
		
		proximitytoplayer = get_pos().distance_to(get_parent().get_node("player").get_pos())
		if proximitytoplayer < proximitythreshold:
			state = 5
			swoopmultiple = get_parent().get_node("player").get_pos() - get_pos()
			if swoopmultiple.x/abs(swoopmultiple.x) != direction:
#				print(swoopmultiple.x)
				speedhorizontal = -speedhorizontal
				direction *= -1
				get_node("Sprite").set_flip_h(!get_node("Sprite").is_flipped_h())
			animator.play("swoop")
	elif state == 2: #stunned
		stuncounter += delta
		if stuncounter >= stuncount:
			stuncounter = 0.0
			state = 6
			thang = 0
			animator.play("fly")
		move(Vector2(0,gravity * delta))
	elif state == 3:
		get_node("thrown").heldenemy = true
		if direction == -1:
			get_node("Sprite").set_flip_h(true)
			get_node("thrown/Sprite").set_flip_h(true)
			get_node("thrown").trajectory = Vector2(-200,0)
		else:
			get_node("Sprite").set_flip_h(false)
			get_node("thrown/Sprite").set_flip_h(false)
			get_node("thrown").trajectory = Vector2(200,0)
	elif state == 3.5:
		animator.play("thrown")
		get_node("thrown").set_fixed_process(true)
		set_pos(Vector2(thrownstartingpos.x + (15 * direction),thrownstartingpos.y))
		get_node("thrown").set_collision_mask(1)
		get_node("thrown").set_layer_mask(1)
		set_collision_mask(2)
		set_layer_mask(2)
		changestate(4)
	elif state == 4:
		pass
	
	elif state == 5: #swooping
		swoop = (sin(thang*3) * (swoopmultiple.y + 40))
		thang += delta
		move(Vector2(speedhorizontal * 2 * delta,swoop * delta))
		if thang >= 2 or get_pos().y == defaultheight:
			state = 1
			thang = 0
			animator.play("fly")
		if is_colliding() and get_collider().is_in_group("player"):
			var collider = get_collider()
			knock_player(collider,direction)
	elif state == 6: #right after stun to ascend back to starting height
		move(Vector2(0,-gravity/2 * delta))
		if(get_pos().y <= defaultheight):
			state = 1



func knock_player(var player, var direction = 1):
	if(cangivedamage and player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(damage)
		damagegivetimer = 0.0
		player.invincounter = 0.0
		
func take_damage(var damage):
	if(cantakedamage):
#		animator.play("stunned")
		state = 2
#		print(state)
		damagetaketimer = 0.0
		health -= damage
		if(health <= 0): #find better way to do this
			cangivedamage = false
			damagegivetimer = 0.0
			state = 0
			speed.x = 0
#			print(state)
#			get_node("Sprite").set_opacity(0)
#			set_layer_mask(2)
#			set_collision_mask(2)
#			animator.play("death")

func alternate_motion(var delta):
	if(motions.size() > 0):
		#print(str(motions[0]))
		for n in range(motions.size()):
			var rest = move(Vector2(motions[n].x,0) * delta)
#			print(str(motions[n]) + " " + str(n))
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