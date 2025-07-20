extends State

func _enter(_host):
	pass

func _update(host, delta):
	host._direction()
	host._move()
	host._dashRefresh(delta)
	host._gunMovement(delta)
	host._gunInput()
	host._gunRefresh(delta)
	host._physics()
	host._animation()
	
	if host.isDashing:
		return 'Dash'

func _exit(_host):
	pass
