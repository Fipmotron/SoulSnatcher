extends Area2D

@export var delayTime : float

@onready var waves = $Waves
var waveArray : Array
var waveNum := 0

@onready var gates = $Gates

var hasStarted = false

func _ready() -> void:
	for wave in waves.get_children():
		waveArray.append(wave)

func _checkDeaths():
	var continueWave = false
	
	var wave = waveArray[waveNum]
	
	for enemy in wave.get_children():
		if not enemy.isDead:
			continueWave = true
	
	if not continueWave:
		waveNum += 1
		
		if not waveNum > len(waveArray) - 1:
			_summonWave()
		else:
			_endWaves()

func _summonWave():
	var wave = waveArray[waveNum]
	
	for enemy in wave.get_children():
		await get_tree().create_timer(delayTime)
		enemy._activate() 

func _endWaves():
	for gate in gates.get_children():
			gate._open()

func _roomEntered(area: Area2D) -> void:
	if not hasStarted:
		for gate in gates.get_children():
			gate._closed()
		
		_summonWave()
		hasStarted = true
