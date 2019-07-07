extends Area2D
var grabbing = false
var grabtimer = 0.0
var grabtime = 0.2
onready var player = get_parent()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	grabtimer += delta
	if !grabbing:
		if grabtimer > grabtime:
			queue_free()
	
	if get_overlapping_bodies().size() > 0:
		for i in get_overlapping_bodies():
			if((i.is_in_group("enemy") or i.is_in_group("flying enemy"))):
				if (i.state == 2 and i.health <= i.maxhealth/2):
					print(i.state)
					if(!grabbing):
						i.add_collision_exception_with(player)
						if(!i.is_in_group("physical")):
							i.get_node("thrown").add_collision_exception_with(player)
						print(i.get_parent())
						i.get_parent().remove_child(i)
						player.add_child(i,true)
						player.heldenemy = i
						i.set_pos(Vector2(0,-25))
						i.changestate(3)
						#i.animator.play("stunned")
						print(i.get_parent())
						grabbing = true
						#do other stuff  raise enemy to over head
						player.currentlyholdingenemy = true
						queue_free()

