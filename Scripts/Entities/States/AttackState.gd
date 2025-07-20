extends State

func _enter(host):
	host.velocity = Vector2.ZERO

func _update(host, delta):
	host._playerCheck()
	host._attackMechanics(delta)
	host._animate()
	
	if not host.playerDetected:
		return 'Wander'
	elif not host.isAttacking:
		return 'Chase'

func _exit(host):
	host._hitboxDeactive()
	print("LEAVE")
