extends StaticBody2D


func _ready():
	pass


func bounce(var bouncee):
	bouncee.add_outside_force(-500)