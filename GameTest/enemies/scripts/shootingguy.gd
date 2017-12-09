# enemy that should shoot a bullet ever time 
#shoottimer reaches shoottime
extends KinematicBody2D
var shoottimer = 0.0
var shoottime = 1
onready var facingright = !get_node("Sprite").is_flipped_h() 
var health = 5
var isalive = true

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(isalive):
		shoottimer += delta
		if(shoottimer > shoottime):
			shoottimer = 0.0
			var shot = preload("res://enemies/scenes/blast.tscn").instance()
			add_child(shot)
			shot.set_pos(Vector2(20,0))
			shot.facingright = facingright
			#instantiate shot in the correct direction
			#false being left and true being right
