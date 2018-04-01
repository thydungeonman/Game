extends KinematicBody2D

var lifetime = 6.0
var life = 0.0
var trajectory = Vector2(0,0)
var knockbackforce = Vector2(200,10)
var parentisheld = false
var creatornode = KinematicBody2D #to be changed to whatever node instantiated this one

func _ready():
	set_fixed_process(true)
	trajectory = trajectory.normalized() * 250
func _fixed_process(delta):
	life += delta
#	move(-get_parent().speed * delta)
	move(trajectory * delta)
	if life >= lifetime:
		self.queue_free()
	
	
	if is_colliding():
		var collider = get_collider()
#		print("fire attack colliding with thing with groups ",str(collider.get_groups()))
		if collider.is_in_group("wall"):
			self.queue_free()
		elif collider.is_in_group("player"):
			if(collider.invincounter > collider.invintime):
				collider.take_damage(2)
				knockbackforce *= -collider.input_direction
				collider.add_horizontal_motion(knockbackforce)
				collider.add_vertical_motion(Vector2(-200,-8))
				collider.invincounter = 0.0
			self.queue_free()
		elif collider.is_in_group("enemy"):
			collider.take_damage(2)
			print("hit enemy")
			self.queue_free()
		elif collider.is_in_group("flying enemy"):
			collider.take_damage(2)
			print("hit enemy")
			self.queue_free()
		elif collider.is_in_group("stationary enemy"):
			collider.take_damage(2)
			print("hit enemy")
			self.queue_free()
#		elif collider.is_in_group("projectile"):
#			print("hit projectile")
#			self.queue_free()
		
func knock_player(var player, var direction = 1):
	if(player.invincounter > player.invintime):
		knockbackforce *= -player.input_direction
		player.add_horizontal_motion(knockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(2)
		player.invincounter = 0.0