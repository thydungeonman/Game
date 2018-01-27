extends KinematicBody2D
var speed = Vector2(100,0)
var facingright = true
var direction = 1

var knockbackforce = Vector2(200,10)
func _ready():
	set_fixed_process(true)
	if(!facingright):
		speed.x = -speed.x

func _fixed_process(delta):
#	if(facingright):
#		move(speed * delta)
#	else:
#		move(-speed * delta)
	move(speed * delta)
	if(is_colliding()):
		var collider = get_collider()
		if(collider.is_in_group("wall") or collider.is_in_group("projectile") or collider.is_in_group("door")):
			queue_free()
		elif(collider.is_in_group("enemy")or collider.is_in_group("stationary enemy")):
			collider.take_damage(1)
			queue_free()
		elif(collider.is_in_group("player")):
			if(!facingright):
				direction = -1
			knock_player(collider,direction)
			queue_free()
		elif(collider.is_in_group("button")):
			collider.anim.play("closed")
			self.queue_free()


func knock_player(var player, var direction = 1):
	if(player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(1)
		player.invincounter = 0.0