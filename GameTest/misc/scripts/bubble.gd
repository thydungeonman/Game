extends Sprite
var timer = 0.0
var textcount = 0
var charinlinecount = 0
var linecount = 0
var waiting = false
var done = false
onready var label = get_node("Label")
export(String) var text = ""
onready var length = text.length()
func _ready():
	set_process(true)
	set_process_input(true)



func _process(delta):
	timer += delta
	if Input.is_action_pressed("ui_jump"):
		if waiting:
			label.set_text("")
			waiting = false
		elif done:
			queue_free()
	
	if fmod(timer,.05) < 0.02:
		if textcount < length:
			linereturn()
			paragraphreturn()
			printtext()
		else:
			done = true


func linereturn():
	if charinlinecount > 60  and text[textcount] == " ":
		charinlinecount = 0
		linecount += 1
		textcount += 1
		label.set_text(label.get_text() + '\n') 
	if text[textcount] == '\n':
		charinlinecount = 0
		linecount += 1

func printtext():
	if !waiting:
		label.set_text(label.get_text() + text[textcount])
		textcount += 1
		charinlinecount += 1
func paragraphreturn():
	if linecount == 5:
		linecount = 0
		waiting = true

