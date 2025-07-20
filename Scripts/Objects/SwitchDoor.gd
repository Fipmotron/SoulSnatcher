extends StaticBody2D

@export var switchThreshold := 0

var switchesOn := 0

func _switchOn():
	switchesOn += 1
	
	if switchesOn >= switchThreshold:
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("open")

func _switchOff():
	switchesOn -= 1
	
	if switchesOn >= switchThreshold:
		$CollisionShape2D.set_deferred("disabled", false)
		$AnimationPlayer.play("close")
