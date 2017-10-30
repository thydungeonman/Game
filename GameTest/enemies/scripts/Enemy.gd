extends KinematicBody2D

#ENEMY VARIABLES
var health = 5
var speed = Vector2(15,0)
var damagetaketimer= 0.0
var damagetaketime = .19
var cantakedamage = false
var knockbackforce = Vector2(200,5)

onready var left = get_node("downleft")
onready var right = get_node("downright")
onready var forward = get_node("forward")
var flip = true
onready var animator = get_node("AnimationPlayer")

func _ready():
	set_fixed_process(true)
	animator.play("walk")

func _fixed_process(delta):
	damagetaketimer += delta
	if(damagetaketimer > damagetaketime):
		cantakedamage = true
	
	var velocity = speed * delta
	move(velocity)
	if(!right.is_colliding() or !left.is_colliding()):
		speed.x *= -1
		knockbackforce *= -1
		flip = !flip
		get_node("Sprite").set_flip_h(flip)
		#forward.set_cast_to(Vector2(forward.get_cast_to().x * -1,0))
	
	if(is_colliding() and get_collider().is_in_group("player")):
		print("enemy hit player")
		var player = get_collider()
		knock_player(player)
	
	if(forward.is_colliding()):
		var collider = forward.get_collider()
		if(collider.is_in_group("wall") or collider.is_in_group("enemy")):
			speed.x *= -1
			knockbackforce *= -1
			flip = !flip
			get_node("Sprite").set_flip_h(flip)
			forward.set_cast_to(Vector2(forward.get_cast_to().x * -1,0))
			forward.set_pos(Vector2(forward.get_pos().x * -1,0))
	


func die():
	queue_free()

func take_damage(var damage):
	if(cantakedamage):
		cantakedamage = false
		damagetaketimer = 0.0
		health -= damage
		if(health <= 0):
			die()

func knock_player(var player, var direction = 1):
	var alteredknockbackforce = knockbackforce * direction
	player.add_horizontal_motion(alteredknockbackforce)
	player.add_vertical_motion(-100)
	player.take_damage(5)
