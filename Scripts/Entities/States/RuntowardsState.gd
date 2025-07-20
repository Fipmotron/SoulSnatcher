extends State

func _enter(_host):
	print("RUN TO HIM")

func _update(host, delta):
	host._chaseMovement()
	host._rangeCheck()
	host._animate()
	
	if not host.runTowards:
		return 'Goldilocks'

func _exit(_host):
	pass
