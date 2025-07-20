extends State

func _enter(host):
	host.velocity = Vector2.ZERO
	
	host.chargeUpTimer = host.chargeUpTime
	
	print("STAY")

func _update(host, delta):
	host._rangeCheck()
	host._gunMechanics(delta)
	host._gunMovement()
	host._gunTimer(delta)
	host._animate()
	
	if host.runAway:
		return 'Runaway'
	elif host.runTowards:
		return 'Runtowards'

func _exit(_host):
	pass
