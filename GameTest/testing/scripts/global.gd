extends Node

var health = 0
var currentscene = null

func _ready():
	var root = get_tree().get_root()
	currentscene = root.get_child(root.get_child_count() -1)


func GoToScene(path):
	call_deferred("DefferedGoToScene",path)

func DefferedGoToScene(path):
	currentscene.free()
	var s = ResourceLoader.load(path)
	currentscene = s.instance()
	get_tree().get_root().add_child(currentscene)
	get_tree().set_current_scene(currentscene)