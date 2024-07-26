extends Area2D

var spikes_out : bool = true

func _on_body_entered(body):
	body.death()


func _on_toggle_spikes_timeout():
	if spikes_out:
		$Sprite2D.texture = load("res://lowered_spikes.png")
		$CollisionShape2D.disabled = true
	else:
		$Sprite2D.texture = load("res://spikes.png")
		$CollisionShape2D.disabled = false

	spikes_out = not spikes_out
