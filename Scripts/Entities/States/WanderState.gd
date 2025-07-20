extends State

func _enter(_host):
	pass

func _update(host, delta):
	host._playerCheck()
	host._animate()
	
	if host.playerDetected:
		return 'Chase'

func _exit(_host):
	pass
