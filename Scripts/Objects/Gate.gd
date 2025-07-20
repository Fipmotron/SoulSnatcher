extends StaticBody2D

func _open():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("open")
	$EnemyClear.play()

func _closed():
	$CollisionShape2D.set_deferred("disabled", false)
	$AnimationPlayer.play("close")
	$GateClose.play()
