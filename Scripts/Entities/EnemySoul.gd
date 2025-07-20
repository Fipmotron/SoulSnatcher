extends CharacterBody2D

@export var isActive : bool

@export var pullTime : float
var startPullTime : float

@export var pullSpeed : float
@export var pullSpread : float

@export var pullawaySpeed : float
@export var pullawayDistance : float
var player : Player

var isAttracted = false

@export var soulAmount : float

func _ready() -> void:
	startPullTime = pullTime
	
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if isActive:
		if isAttracted:
			_attractMovement(delta)
		elif global_position.distance_to(player.global_position) <= pullawayDistance:
			_pullAwayMovement()
		
		if pullTime <= 0.0:
			Signalbus.emit_signal("addSoul", soulAmount)
			call_deferred("queue_free")
	
	move_and_slide()

func _pullAwayMovement():
	var pullDirection = global_position - player.global_position 
	var exPlayerVelocity = player.velocity.clampf(-player.groundSpeed, player.groundSpeed)
	
	velocity = pullDirection.normalized() * pullawaySpeed + exPlayerVelocity

func _attractMovement(delta):
	var pullVector = global_position - player.global_position
	var pullDirection = pullVector.rotated(deg_to_rad(randf_range(-pullSpread, pullSpread)))
	
	var speedDivider = remap(pullTime, 0, startPullTime, 0.5, 1)
	var killMultiplier = remap(global_position.distance_to(player.global_position), 50, 200, 4, 1)
	
	pullTime -= delta * killMultiplier
	
	velocity = pullDirection.normalized() * pullSpeed * speedDivider

func _onAttract(area: Area2D) -> void:
	isAttracted = true

func _offAttraction(area: Area2D) -> void:
	isAttracted = false
