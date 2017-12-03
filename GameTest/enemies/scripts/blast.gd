extends KinematicBody2D
var speed = Vector2(100,0)
var facingright = true
var direction = 1

var knockbackforce = Vector2(200,10)
func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(facingright):
		move(speed * delta)
	else:
		move(-speed * delta)
	if(is_colliding()):
		var collider = get_collider()
		if(collider.is_in_group("wall") or collider.is_in_group("projectile")):
			queue_free()
		elif(collider.is_in_group("player")):
			if(!facingright):
				direction = -1
			knock_player(collider,direction)
			queue_free()


func knock_player(var player, var direction = 1):
	if(player.invincounter > player.invintime):
		var alteredknockbackforce = knockbackforce * direction
		player.add_horizontal_motion(alteredknockbackforce)
		player.add_vertical_motion(-200)
		player.take_damage(1)
		player.invincounter = 0.0