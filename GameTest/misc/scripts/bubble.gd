extends Sprite
var timer = 0.0
var textcount = 0
var charinlinecount = 0
var linecount = 0
var waiting = false
var done = false
onready var label = get_node("Label")
var text = "Not to mention we used to have the same length before we switched to hashes iirc. The timestamps were only shorter after cuckmonkey finally brought them back. Also you can always rename your images like that if you really wanted to by padding the end if they came from here or simply using a script to batch rename all images in a folder to their date modified timestamp."
onready var length = text.length()
var parent

func _ready():
	set_process(true)
	set_process_input(true)

func _process(delta):
	print(label.get_line_count())
	timer += delta
	if Input.is_action_pressed("ui_jump"):
		if waiting:
			label.set_text("")
			waiting = false
		elif done:
			queue_free()
	
	if fmod(timer,.05) < 0.02:
		if textcount < length:
#			linereturn()
#			paragraphreturn()
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
		if(label.get_line_count() > 3):
			waiting = true
func paragraphreturn():
	if linecount == 5:
		linecount = 0
		waiting = true

func die():
	parent.dead = true
	queue_free()
