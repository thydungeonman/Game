extends Area2D
var count = 0
var maxcount = 30
var lastlaser = null
var nextlaser = null
var firetimer = 0
var firetime = .000001
var firedlaser = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	firetimer += delta
	if(firetimer > firetime and firedlaser == false):
		firedlaser = true
		Fire()
		

func Fire():
	if(count == maxcount):
		Stop()
		return
	if(get_overlapping_bodies().size() < 10 and count < maxcount):
		print(str(get_overlapping_areas().size()))
		for area in get_overlapping_areas():
			if area.is_in_group("deflect"):
				Stop()
				return
		for body in range(get_overlapping_bodies().size()):
			if(get_overlapping_bodies()[body].is_in_group("player")):
				get_overlapping_bodies()[body].take_damage(5)
			if(get_overlapping_bodies()[body].is_in_group("wall")):
				Stop()
				return
		count += 1
		var nextlaser = preload("res://enemies/scenes/laser.tscn").instance()
		add_child(nextlaser)
		nextlaser.lastlaser = self
		nextlaser.set_pos(Vector2(0,-10))
		nextlaser.count = count

func Stop():
	if(lastlaser != null):
		lastlaser.Stop()
	get_node("AnimationPlayer").play("die")

func Die():
	queue_free()
		