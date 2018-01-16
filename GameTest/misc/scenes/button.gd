extends KinematicBody2D
onready var anim = get_node("AnimationPlayer")
var opened = false


func _ready():
	set_fixed_process(true)

func fixed_process(delta):
	pass

func opendoor():
	if opened == false:
		get_parent().get_node("door").open()
		opened = true