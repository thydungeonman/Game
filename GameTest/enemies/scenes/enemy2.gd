extends "res://enemies/scripts/Enemy.gd"

var shoottimer = 1.0
var shoottime = 0.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	speed = Vector2(5,0)
	health = 20

func _fixed_process(delta):
	shoottime += delta
	if shoottime >= shoottimer:
		shoottime = 0.0
		var fireattack = preload("res://enemies/scenes/fireattack.tscn").instance()
		var playerposition = get_parent().get_node("player").get_pos()
		fireattack.trajectory = playerposition - get_pos()
		add_child(fireattack)

