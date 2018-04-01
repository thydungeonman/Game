extends "res://enemies/scripts/Enemy.gd"

var shoottimer = 1.0
var shoottime = 0.0

onready var vision = get_node("Vision")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	speed = Vector2(50,0)
	health = 20
	maxhealth = 20
func _fixed_process(delta):
	shoottime += delta
	if(state != 0 and state != 2 and state != 3 and state != 4):
		if shoottime >= shoottimer:
			shoottime = 0.0
			var fireattack = preload("res://enemies/scenes/fireattack.tscn").instance()
			var playerposition = get_tree().get_root().get_node("Node2D/player").get_pos()
			fireattack.trajectory = playerposition - get_pos()
			fireattack.add_collision_exception_with(self)
			fireattack.creatornode = self
#			add_child(fireattack)
			get_parent().get_parent().add_child(fireattack)
			fireattack.set_pos(get_global_pos())
	elif(state == 3):
		shoottime += delta * 6
		if shoottime >= shoottimer:
			shoottime = 0.0
			if(vision.get_overlapping_bodies().size()> 2):
#				print(str(vision.get_overlapping_bodies()))
#				print("This is the 4th ",str(vision.get_overlapping_bodies()[0].get_groups()))
				for i in vision.get_overlapping_bodies():
					if (i.is_in_group("enemy") or i.is_in_group("flying enemy") or i.is_in_group("stationary enemy")) and !i.is_in_group("big"):
						var fireattack = preload("res://enemies/scenes/fireattack.tscn").instance()
						var playerposition = i.get_global_pos()
						fireattack.trajectory = playerposition - get_global_pos()
						fireattack.add_collision_exception_with(get_parent())
						fireattack.parentisheld = true
						fireattack.add_collision_exception_with(self)
						fireattack.add_collision_exception_with(get_tree().get_root().get_node("Node2D").get_node("platform"))
						fireattack.add_collision_exception_with(get_node("thrown"))
						get_parent().get_parent().add_child(fireattack)
						fireattack.set_pos(get_global_pos())
						
						break
#				print("position of target ",str(vision.get_overlapping_bodies()[0].get_global_pos()))
#				print("trajectory = ",str(fireattack.trajectory))

