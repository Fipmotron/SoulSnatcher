extends State

func _enter(_host):
	pass

func _update(host, delta):
	host._playerCheck()
	host._gunMovement()
	host._gunMechanics(delta)
	host._gunTimer(delta)
	host._animate()
	
	if not host.playerDetected:
		return 'Stationary'

func _exit(_host):
	pass
