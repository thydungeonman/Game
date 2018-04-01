extends Label
var timer = 0.0
var textcount = 0
var charinlinecount = 0
var linecount = 0
var waiting = false
onready var text = get_node("backlabel").get_text()
onready var length = get_node("backlabel").get_text().length()
var thing = "hello"
func _ready():
	set_process(true)
	set_process_input(true)



func _process(delta):
	timer += delta
	if Input.is_action_pressed("ui_jump"):
		if waiting:
			set_text("")
			waiting = false
	
	print(fmod(timer,.05))
	if fmod(timer,.05) < 0.02:
		if textcount < length:
			paragraphreturn()
			linereturn()
			printtext()


func linereturn():
	if charinlinecount > 60  and text[textcount] == " ":
		charinlinecount = 0
		set_text(get_text() + '\n') 
		linecount += 1
func printtext():
	if !waiting:
		set_text(get_text() + text[textcount])
		textcount += 1
		charinlinecount += 1
func paragraphreturn():
	if linecount == 3:
		linecount = 0
		waiting = true

