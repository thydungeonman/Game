extends Area2D
var kicktime = 0.1
var count = 0.0
onready var player = get_parent()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > kicktime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy") or i.is_in_group("stationary enemy")):
				i.take_damage(1)
				i.add_horizontal_motion(Vector2(50,1) * player.input_direction)
			elif(i.is_in_group("flying enemy")):
				i.take_damage(2)
				i.add_horizontal_motion(Vector2(50,1) * player.input_direction)
			elif(i.is_in_group("eliteenemy") and i.state == 2):
				i.take_damage(2)
				i.add_horizontal_motion(Vector2(50,1)* player.input_direction)
		self.queue_free()