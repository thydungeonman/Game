extends Area2D
var punchtime = 0.1
var count = 0.0
onready var player = get_parent()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > punchtime):
		player.anim.play("restpose")
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy") and (i.state == 1 or i.state == 2)):
				#player.attackbreakcounter = .1
				player.health += 1
				i.take_damage(5)
				#i.add_horizontal_motion(Vector2(270,10)* player.input_direction)
				if(i.is_in_group("physical")):
					#i.add_vertical_motion(Vector2(-150,-5))
					i.add_outside_force(-300)
					i.add_horizontal_motion(Vector2(50*player.input_direction,3*player.input_direction))
			elif(i.is_in_group("stationary enemy")):
				i.take_damage(5)
				player.health += 1
			elif(i.is_in_group(("flying enemy"))):
				i.take_damage(5)
				i.add_horizontal_motion(Vector2(200,15)* player.input_direction)
				player.health += 1
			elif(i.is_in_group("eliteenemy") and i.state == 2):
				i.take_damage(5)
				i.add_horizontal_motion(Vector2(300,15)* player.input_direction)
				player.health += 1
		self.queue_free()