extends Area2D
var count = 0.0
var deflecttime = 0.1
var beendeflected = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > deflecttime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy")):
				queue_free()
			elif(i.is_in_group("projectile") and not beendeflected):
				i.speed += Vector2(300,100)
				if(Input.is_action_pressed("ui_up")):
					i.speed.y += 200
					i.speed = i.speed * i.speed.normalized()
					i.speed.y *= -1
				else:
					i.speed = i.speed * i.speed.normalized()
					randomize()
					if(randi() % 2 == 1):
						i.speed.y *= -1
				i.speed.x *= -1
				print(str(i.speed))
				beendeflected = true
				get_parent().deflectbreakcounter = 0.2
				queue_free()
				 #deflect projectile in either random opposite direction
					# or stun enemy
