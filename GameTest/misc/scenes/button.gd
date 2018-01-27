extends KinematicBody2D
onready var anim = get_node("AnimationPlayer")
var opened = false

signal Pressed()

func _ready():
	set_fixed_process(true)

func fixed_process(delta):
	pass

func activate():
	if opened == false:
		emit_signal("Pressed")
		opened = true