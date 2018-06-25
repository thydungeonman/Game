#new method. split dialog by punctuation then look at the length of the individual sentences. See if the next sentence can fit.
#if not then paragraph return.

extends Sprite
var timer = 0.0
var textcount = 0
var charinlinecount = 0
var linecount = 0
var waiting = false
var done = false
onready var label = get_node("Label")
var text = ""
onready var length = text.length()
var parent
onready var anim = get_node("AnimationPlayer")

func _ready():
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
	anim.play("appear")
func _fixed_process(delta):
	timer += delta
	if Input.is_action_pressed("ui_jump"):
		if waiting:
			label.set_text("")
			waiting = false
			anim.play("rest")
		elif done:
			anim.play("disappear")
	print (fmod(timer,.1))
	if (fmod(timer,.02) < 0.02) and !waiting :
		if textcount < length:
			linereturn()
			paragraphreturn()
			printtext()
		else:
			done = true

#func _process(delta):
#	timer += delta
#	if Input.is_action_pressed("ui_jump"):
#		if waiting:
#			label.set_text("")
#			waiting = false
#			anim.play("rest")
#		elif done:
#			anim.play("disappear")
#	
#	if (fmod(timer,.05) < 0.02) and !waiting :
#		if textcount < length:
#			linereturn()
#			paragraphreturn()
#			printtext()
#		else:
#			done = true


func linereturn():
	if charinlinecount > 30 and text[textcount] == " ":
		charinlinecount = 0
		linecount += 1
		textcount += 1
		label.set_text(label.get_text() + '\n')
	if text[textcount] == '\n':
		charinlinecount = 0
		linecount += 1
#	elif text[textcount] == '\n' and charinlinecount == 0 :
#		linecount -= 1

func printtext():
	if !waiting:
		label.set_text(label.get_text() + text[textcount])
		textcount += 1
		charinlinecount += 1
func paragraphreturn():
	if(text[textcount] == '\n' and linecount == 5):
		textcount += 1
	if linecount == 6:
		linecount = 0
		waiting = true
		anim.play("waitarrow")

func die():
	parent.dead = true
	queue_free()

