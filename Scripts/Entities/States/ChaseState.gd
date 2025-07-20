extends State

func _enter(_host):
	pass

func _update(host, delta):
	host._playerCheck()
	host._chaseMovement()
	host._attackCheck()
	host._animate()
	
	if not host.playerDetected:
		return 'Wander'
	elif host.isAttacking:
		return 'Attack'

func _exit(_host):
	pass
