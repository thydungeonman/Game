extends Area2D
var count = 0.0
var deflecttime = 0.1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > deflecttime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy") or i.is_in_group("projectile")):
				pass #deflect projectile in either random opposite direction
					# or stun enemy
