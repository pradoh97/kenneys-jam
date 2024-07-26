extends Area2D


func _on_body_entered(body):
	if "pick_rope" in body:
		$AudioStreamPlayer2D.play()
		body.pick_rope()
	hide()
	$CollisionShape2D.set_deferred("disabled", true)


func _on_audio_stream_player_2d_finished():
	queue_free()
