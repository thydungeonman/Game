extends Area2D
var first = false

func _ready():
	var lightning = preload("res://player/scenes/lightningattackrange.tscn").instance()
	self.add_child(lightning)
	set_fixed_process(true)

func _fixed_process(delta):
	pass
	