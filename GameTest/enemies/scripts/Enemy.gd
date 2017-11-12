extends KinematicBody2D

#ENEMY VARIABLES
var health = 5
var speed = Vector2(15,0)
var damagetaketimer= 0.0
var damagetaketime = .19
var cantakedamage = false
var knockbackforce = Vector2(200,7)
var damagegivetimer = 0.0
var damagegivetime = 0.25
var cangivedamage = true
var direction = 1
var velocity = 0.0
var state = 1

onready var left = get_node("downleft")
onready var right = get_node("downright")
onready var wallright = get_node("forward")
onready var wallleft = get_node("back")
var flip = false
onready var animator = get_node("AnimationPlayer")
onready var particles = get_node("Particles2D")

func _ready():
	set_fixed_process(true)
	animator.play("walk")

func _fixed_process(delta):
	
	if(state == 1):
		#KEEP TIME
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
			
		#MOVEMENT
		velocity = speed * delta
		move(velocity)
		if(wallright.is_colliding() and wallright.get_collider().is_in_group("wall") or not right.is_colliding()):
			direction = -1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			knockbackforce *= -1
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
		if(wallleft.is_colliding() and wallleft.get_collider().is_in_group("wall") or not left.is_colliding()):
			direction = 1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			knockbackforce *= -1
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
			#forward.set_cast_to(Vector2(forward.get_cast_to().x * -1,0))
			#forward.set_pos(Vector2(forward.get_pos().x * -1,0))
		if(is_colliding() and get_collider().is_in_group("enemy")):
			direction *= -1
			revert_motion()
			speed.x *= -1
			velocity = speed * delta
			move(velocity)
			knockbackforce *= -1
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
		if(is_colliding() and get_collider().is_in_group("player") and cangivedamage):
			print("enemy hit player")
			var player = get_collider()
			knock_player(player)
	

func die():
	queue_free()

func take_damage(var damage):
	if(cantakedamage):
		cantakedamage = false
		damagetaketimer = 0.0
		health -= damage
		if(health <= 0):
			cangivedamage = false
			damagegivetimer = 0.0
			state = 2
			speed.x = 0
			get_node("Sprite").set_opacity(0)
			set_layer_mask(2)
			set_collision_mask(2)
			animator.play("death")

func knock_player(var player, var direction = 1):
	if(cangivedamage and player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(-200)
		player.take_damage(1)
		damagegivetimer = 0.0
		cangivedamage = false
		player.invincounter = 0.0
		player.anim.play("invincible")
