extends StaticBody2D


func _ready():
	pass

func _on_button_Pressed():
	set_layer_mask(1)
	set_collision_mask(1)
	get_node("AnimationPlayer").play("appear")

