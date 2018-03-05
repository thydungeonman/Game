extends Area2D
var punchtime = 0.1
var count = 0.0
onready var player = get_parent()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > punchtime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy")):
				player.health += 1
				i.take_damage(5)
				i.add_horizontal_motion(Vector2(200,15)* player.input_direction)
				#TODO
				#separate above line from general attacking
				#not every enemy should move when hit
			elif(i.is_in_group("stationary enemy")):
				i.take_damage(5)
				player.health += 1
			elif(i.is_in_group(("flying enemy"))):
				i.take_damage(5)
				i.add_horizontal_motion(Vector2(200,15)* player.input_direction)
				player.health += 1
		self.queue_free()