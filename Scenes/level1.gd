extends Node2D

var breadcrumbs_path : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	breadcrumbs_path = $breadcrumbs_path
	$AudioStreamPlayer.play()
	update_rope($CharacterBody2D.rope)
	$DirectionalLight2D.visible = true

func update_rope(new_quantity : int):
	$CharacterBody2D/UI/HBoxContainer/rope_amount.text = str(new_quantity)

func drop_crumbs(crumb):
	$breadcrumbs_path.add_child(crumb)

func _on_room_entry_body_entered(_body):
	var tween = create_tween()
	tween.tween_property($fake_roof,"modulate", Color("#ffffff10"), 0.7)

func _on_room_exit_body_entered(_body):
	var tween = create_tween()
	tween.tween_property($fake_roof,"modulate", Color("#ffffffff"), 0.7)

func _on_victory_body_entered(body):
	body.victory()

func stop_music():
	$AudioStreamPlayer.stop()
