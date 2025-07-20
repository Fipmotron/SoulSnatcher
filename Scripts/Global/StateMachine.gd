extends Node

@onready var host := get_parent()

var states : Dictionary = {}

var currentState := ""

func _ready() -> void:
	var firstState = ""
	
	for child in get_children():
		if child is State:
			if len(states) == 0:
				firstState = child.name
			
			states[child.name] = child
	
	if len(states) != 0:
		currentState = firstState

func _physics_process(delta: float) -> void:
	var stateName = states[currentState]._update(host, delta)
	
	if stateName != null:
		_changeState(stateName)

func _changeState(newState):
	if newState == currentState:
		return
	
	states[currentState]._exit(host)
	currentState = newState
	states[currentState]._enter(host)
