extends KinematicBody2D
var trajectory = Vector2(250,0)
var facingright = true
var direction = 1
var heldenemy = false
var parentspeed = Vector2()
#TODO
#Create thrown enemy class with kinematic body but with NO collision shape
#engine bug appears where inherited collisionshape nodes ignore changes and stick to base settings
#the projectile should have an animation player with its own animation

var knockbackforce = Vector2(200,10)
func _ready():
	pass
#	set_fixed_process(true)

func _fixed_process(delta):
	#print(is_colliding())
	move(trajectory * delta)
	if(is_colliding()):
		var collider = get_collider()
		if(collider.is_in_group("wall") or collider.is_in_group("projectile") or collider.is_in_group("door")):
			if heldenemy:
				get_parent().queue_free()
			queue_free()
		elif(collider.is_in_group("enemy")or collider.is_in_group("stationary enemy") or collider.is_in_group("flying enemy")):
			collider.take_damage(1)
			if heldenemy:
				get_parent().queue_free()
			queue_free()
		elif(collider.is_in_group("player")):
			if(!facingright):
				direction = -1
			knock_player(collider,direction)
			if heldenemy:
				get_parent().queue_free()
			queue_free()
		elif(collider.is_in_group("button")):
			collider.anim.play("closed")
			if heldenemy:
				get_parent().queue_free()
			self.queue_free()


func knock_player(var player, var direction = 1):
	if(player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(1)
		player.invincounter = 0.0

func Launch():
	set_fixed_process(true)
	trajectory.x *= direction

func FaceLeft():
	direction = -1
	get_node("Sprite").set_flip_h(true)