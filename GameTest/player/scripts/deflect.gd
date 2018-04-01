extends Area2D
var count = 0.0
var deflecttime = 0.1
var beendeflected = false
onready var player = get_parent()

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
				player.deflectbreakcounter = .6
			elif(i.is_in_group("flying enemy") and i.state == 5):
				i.state = 2 #stunned
				player.deflectbreakcounter = .6
				queue_free()
			elif(i.is_in_group("eliteenemy") and i.state == 8):
				i.state = 2
				player.deflectbreakcounter = .6
				i.add_horizontal_motion(Vector2(50,2) * player.input_direction)
				queue_free()
			elif(i.is_in_group("projectile") and not beendeflected):
				print("projectile deflected")
#				i.remove_collision_exception_with(i.get_parent())
				i.remove_collision_exception_with(i.creatornode)
				player.deflectbreakcounter = .4
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
				queue_free()
				 #deflect projectile in either random opposite direction
					# or stun enemy
