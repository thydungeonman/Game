extends KinematicBody2D

var lifetime = 6.0
var life = 0.0
var trajectory = Vector2(0,0)
var knockbackforce = Vector2(200,10)

func _ready():
	set_fixed_process(true)
	add_collision_exception_with(get_parent())
	add_collision_exception_with(get_parent().get_parent().get_node("platform"))
	trajectory = trajectory.normalized() * 250
func _fixed_process(delta):
	life += delta
	move(trajectory * delta)
	if life >= lifetime:
		self.queue_free()
	
	
	if is_colliding():
		var collider = get_collider()
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
			self.queue_free()
		elif collider.is_in_group("projectile"):
			self.queue_free()
		
func knock_player(var player, var direction = 1):
	if(player.invincounter > player.invintime):
		knockbackforce *= -player.input_direction
		player.add_horizontal_motion(knockbackforce)
		player.add_vertical_motion(Vector2(-200,-8))
		player.take_damage(2)
		player.invincounter = 0.0