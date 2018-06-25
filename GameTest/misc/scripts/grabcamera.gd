extends Camera2D

var player
onready var area = get_node("Area2D")
var bodies
var playerisgone = true

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if(area.get_overlapping_bodies().size() > 0):
		bodies = area.get_overlapping_bodies()
		for n in bodies:
			if(n.is_in_group("player")):
				player = n
				make_current()
				playerisgone = false
				break
			else:
				playerisgone = true
	else:
		playerisgone = true
	if(playerisgone and player != null):
		player.get_node("Camera2D").make_current()
