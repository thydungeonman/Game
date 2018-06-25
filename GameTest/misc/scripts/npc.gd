extends Area2D
var dialog = "After several annoying bugs, including every noble in my civilization showing up in my fort at once, and much real-life tumult, I finally had a well-behaved, seemingly not buggy, peaceful hill dwarf settlement appear outside my fortress! It was very satisfying to see it colored in on the new world map overlay, as an indication that the game overall is entering an entirely new realm of story potential, as sparse as they'll be at first. Around 50 dwarves moved in to the new site, and they named it Reignseals. Their newly elected mayor was Lokum Bridgedrove, a historical dwarf that had ten years earlier fought a harrowing battle with a werewombat. My fortress was on a one-tile mountain in the middle of a swamp; my new neighbors sensibly founded their site eight tiles away in the nearby grassland. The sites don't send emissaries yet, so for now it just pops up a little announcement box with the name and direction so you can find it easily on your map."
var t = """Controls: 
Arrows/dpad for movement. Double tap left or right to dash. Down to duck. Space/A on controller to jump. F/B on controller to "punch". Punch while ducking to "kick". D/X on controller to deflect projectiles and charging enemies(only bats for now). S/Y on controller to grab enemies that are stunned and lower than half health to throw them. Enter/Start on controller to reload. Shoulder buttons or pageup/down to zoom in and out. This is just for testing purposes though. Escape to quit."""
var spoken = false
onready var spelabel = get_node("speechlabel")
onready var spolabel = get_node("spokenlabel")
var speech
var ref
var dead = false
func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(get_overlapping_bodies().size() > 0):
		if get_overlapping_bodies()[0].is_in_group("player"):
			if Input.is_action_pressed("ui_jump") and spoken == false:
				speech = preload("res://misc/scenes/bubble alt.tscn").instance()
				speech.parent = self
				ref =  weakref(speech)
				speech.text = dialog
				add_child(speech)
				dead = false
				spoken = true
	else:
		if(spoken):
			if(dead == false):
				speech.get_node("AnimationPlayer").play("disappear")
		spoken = false
	if(spoken == true):
		spolabel.set_text(str(speech.charinlinecount))
		spelabel.set_text(str(speech.linecount))
		#crashes at the end
