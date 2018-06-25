extends Area2D
var kicktime = .4
var count = 0.0
onready var player = get_parent()
var hitsomething = false

func _ready():
	set_fixed_process(true)
	if player.input_direction == -1:
		set_scale(Vector2(-1,1))
		get_node("Sprite").set_flip_h(true)

func _fixed_process(delta):
	count += delta
	if(count > kicktime):
		self.queue_free()
	if(self.get_overlapping_bodies().size() > 1):
		for i in get_overlapping_bodies():
			if(i.is_in_group("enemy") or i.is_in_group("stationary enemy")):
				i.take_damage(2)
				i.add_horizontal_motion(Vector2(200,10) * player.input_direction)
				hitsomething = true
			elif(i.is_in_group("flying enemy")):
				i.take_damage(3)
				i.add_horizontal_motion(Vector2(200,10) * player.input_direction)
				hitsomething = true
			elif(i.is_in_group("eliteenemy") and i.state == 2):
				i.take_damage(3)
				i.add_horizontal_motion(Vector2(200,10)* player.input_direction)
				hitsomething = true
		if(hitsomething):
			player.clear_motions()
			player.GravityFront(.2)
			player.add_vertical_motion(Vector2(-230,-10))
			player.add_horizontal_motion(Vector2(100 * player.input_direction * -1, 3 * player.input_direction * -1))
		self.queue_free()