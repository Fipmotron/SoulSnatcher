extends State

func _enter(_host):
	print("inactive")

func _update(host, delta):
	host._playerCheck()
	host._animate()
	
	if host.playerDetected:
		return 'Runtowards'

func _exit(_host):
	pass
