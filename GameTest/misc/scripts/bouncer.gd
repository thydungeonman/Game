extends StaticBody2D


func _ready():
	pass


func bounce(var player):
	player.add_vertical_force()