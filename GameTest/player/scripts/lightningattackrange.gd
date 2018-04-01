extends Area2D

var direction = 1
var over = false
var first = false
var number = 0
var numofenemies = 0
var zapped = false
var enemies = []

func _ready():
	if direction == -1 and first:
		set_scale(Vector2(-1,1))
	print("scale: ",get_scale())
	print("ready ",number)
	print("global position: ",str(get_global_pos()))
	set_fixed_process(true)

func _fixed_process(delta):
	
	if(over):
		if(!first):
			get_parent().over = true
		print("free ",number)
		queue_free()
	if(!zapped):
		if(get_overlapping_bodies().size() > 0):
			for enemy in get_overlapping_bodies():
				if (enemy.is_in_group("enemy") or enemy.is_in_group("flying enemy")) and enemies.count(enemy) == 0:
					enemies.append(enemy)
					numofenemies += 1
					var lightning = preload("res://player/scenes/lightningattackrange.tscn").instance()
	#				print("enemy global pos: ",str(enemy.get_global_pos()))
					lightning.number = number + 1
					lightning.direction = self.direction
					lightning.enemies = enemies
					self.add_child(lightning)
					lightning.set_global_pos(enemy.get_global_pos())
	#				var angle = get_pos().angle_to_point(enemy.get_pos())
	#				lightning.set_rot(rad2deg(angle))
					enemy.take_damage(20)
					zapped = true
					break
			if(numofenemies == 0):
				over = true
		else:
			over = true
