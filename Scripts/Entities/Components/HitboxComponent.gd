extends Area2D

class_name HitboxComponent

@export var damage : float
@export var dotDamage : float
@export var knockbackForce : float

@export var applyConfusion : bool
@export var applyBurn : bool
@export var applyFreeze : bool

@export var deleteOnHit : bool


func _onBody(body: Node2D) -> void:
	if deleteOnHit:
		get_parent().queue_free()
