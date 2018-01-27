extends KinematicBody2D
onready var anim = get_node("AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_button_Pressed():
	anim.play("opening")
