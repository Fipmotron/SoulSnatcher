extends State

func _enter(host):
	host.velocity = Vector2.ZERO

func _update(host, delta):
	host._dash(delta)
	host._gunRefresh(delta)
	host._physics()
	host._animation()
	
	if not host.isDashing:
		return 'Ground'

func _exit(_host):
	pass
