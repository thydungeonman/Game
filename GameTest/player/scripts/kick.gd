extends Area2D
var kicktime = 0.1
var count = 0.0

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	count += delta
	if(count > kicktime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 0):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy")):
				i.take_damage(1)