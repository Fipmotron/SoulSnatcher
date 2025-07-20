extends Area2D

@export var isOn := false
var inRange := false

signal switchOn
signal switchOff

func _ready() -> void:
	switchOn.connect(Callable(get_parent(), "_switchOn"))
	switchOff.connect(Callable(get_parent(), "_switchOff"))
	
	if isOn:
		$AnimationPlayer.play("On")
	else:
		$AnimationPlayer.play("Off")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Buy") and inRange:
		print("Change")
		if isOn:
			isOn = false
			emit_signal("switchOff")
			$AnimationPlayer.play("Off")
		elif not isOn:
			isOn = true
			emit_signal("switchOn")
			$AnimationPlayer.play("On")

func _onEnter(area : Area2D):
	inRange = true

func _onExit(area : Area2D):
	inRange = false
