extends Area2D

func _on_body_entered(body):
	if "pick_bread" in body:
		body.pick_bread(self)

func rotate_vertical():
	$rope.rotation_degrees = 0

func rotate_horizontal():
	$rope.rotation_degrees = 90
