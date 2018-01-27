extends Area2D
var disappearing = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if get_overlapping_bodies().size() > 0:
		for i in get_overlapping_bodies():
			if i.is_in_group("player"):
				if disappearing == false:
					get_node("AnimationPlayer").play("disappear")
					disappearing = true
