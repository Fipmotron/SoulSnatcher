extends State

func _enter(_host):
	print("RUNAWAY")

func _update(host, delta):
	host._runMovement()
	host._rangeCheck()
	host._animate()
	
	if not host.runAway:
		return 'Goldilocks'

func _exit(_host):
	pass
