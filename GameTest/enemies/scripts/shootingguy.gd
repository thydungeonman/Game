# enemy that should shoot a bullet ever time 
#shoottimer reaches shoottime

# the sprite for this node causes an error. Replace eventually

extends KinematicBody2D
export(float) var shoottimer = 0.0
export(float) var shoottime = 1.5
export(bool) var facingright = true
var health = 2
var isalive = true
var cantakedamage = true
var damagetaketimer = 0.0
var speed = Vector2(0,0)

func _ready():
	set_fixed_process(true)
	if(facingright == false):
		get_node("AnimationPlayer").play("faceleft")

func _fixed_process(delta):
	if(isalive):
		shoottimer += delta
		if(shoottimer > shoottime):
			shoottimer = 0.0
			var shot = preload("res://enemies/scenes/blast.tscn").instance()
			shot.facingright = facingright
			shot.creatornode = self
			add_child(shot)
			shot.set_fixed_process(true)
			shot.set_pos(Vector2(20,0))
			if(!facingright):
				shot.set_pos(Vector2(-20,0))
			#instantiate shot in the correct direction
			#false being left and true being right
	else:
		self.queue_free()

func take_damage(var damage):
	if(cantakedamage):
#		animator.play("stunned")
#		state = 2
		health -= damage
		if(health <= 0):
			isalive = false
			get_node("Sprite").set_opacity(0)
			set_layer_mask(2)
			set_collision_mask(2)
