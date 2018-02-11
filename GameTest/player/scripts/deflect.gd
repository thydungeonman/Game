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
				var shotdirection = i.trajectory.x / abs(i.trajectory.x) #-1 for going left
				i.trajectory = Vector2(300,100) 
				if(Input.is_action_pressed("ui_up")):
					i.trajectory.y += 150
					i.trajectory = i.trajectory * i.trajectory.normalized()
					i.trajectory.y *= -1
				elif(Input.is_action_pressed("ui_duck")):
					i.trajectory.y += 150
					i.trajectory = i.trajectory * i.trajectory.normalized()
				else:
					i.trajectory = i.trajectory * i.trajectory.normalized()
					randomize()
					if(randi() % 2 == 1):
						i.trajectory.y *= -1
				i.trajectory.x *= -shotdirection #reflect its original direction
				print(str(i.trajectory))
				beendeflected = true
				get_parent().deflectbreakcounter = 0.2
				queue_free()
				 #deflect projectile in either random opposite direction
					# or stun enemy
