extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("r"):
		var scene : PackedScene = load("res://Scenes/level1.tscn")
		get_tree().change_scene_to_packed(scene)
