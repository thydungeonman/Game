extends KinematicBody2D

#ENEMY VARIABLES
var health = 7
var speed = Vector2(10,0)
var damagetaketimer= 0.0
var damagetaketime = .1
var cantakedamage = false
var knockbackforce = Vector2(200,7)
var damagegivetimer = 0.0
var damagegivetime = 0.25
var cangivedamage = true
var direction = 1
var velocity = 0.0
var state = 1 #0 = dead 1 = walking 2 = stun # make enum some day
var motions = []
var stuncounter = 0.0
var stuncount = .5
var damage = 3
var dontmove = false

onready var left = get_node("downleft")
onready var right = get_node("downright")
onready var wallright = get_node("forward")
onready var wallleft = get_node("back")
var flip = false
onready var animator = get_node("AnimationPlayer")
onready var particles = get_node("Particles2D")
onready var healthlabel = get_node("healthlabel")

func _ready():
	set_fixed_process(true)
	animator.play("walk")

func _fixed_process(delta):
	healthlabel.set_text("Health: " + str(health))
	alternate_motion(delta)
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
	if(state == 1): #alive
		#KEEP TIME
			
		#MOVEMENT
		velocity = speed * delta
		move(velocity)
		if(wallright.is_colliding() and wallright.get_collider().is_in_group("wall") or not right.is_colliding()):
			direction = -1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
		if(wallleft.is_colliding() and wallleft.get_collider().is_in_group("wall") or not left.is_colliding()):
			direction = 1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
		if(is_colliding() and get_collider().is_in_group("enemy")):
			direction *= -1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
		if(is_colliding() and get_collider().is_in_group("player") and cangivedamage):
			print("enemy hit player")
			var player = get_collider()
			knock_player(player,direction)
	elif(state == 2): #stunned
		stuncounter += delta
		if(stuncounter > stuncount):
			stuncounter = 0
			state = 1
			animator.play("walk")
		pass
	

func die():
	queue_free()

func take_damage(var damage):
	if(cantakedamage):
		animator.play("stunned")
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
	print(str(direction))
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
			print(str(motions[n]) + " " + str(n))
			if((not left.is_colliding()) or (not right.is_colliding())):
				print("notcolliding")
				revert_motion()
				dontmove = true
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

