extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(get_overlapping_bodies().size() > 0):
		for body in get_overlapping_bodies():
			if(body.is_in_group("player")):
				body.take_damage(1,false)
