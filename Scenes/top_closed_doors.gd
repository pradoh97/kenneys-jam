extends StaticBody2D

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

func _on_key_2_body_entered(_body):
	$AudioStreamPlayer2D.play()
	get_tree().current_scene.get_node("key2").queue_free()
	sprite_2d.texture = preload("res://open_doors.png")
	collision_shape_2d.disabled = true
	set_collision_layer_value(2, false)
