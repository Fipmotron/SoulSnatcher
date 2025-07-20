extends Area2D

class_name GunInteractable

@onready var newGun := $NewGun
@onready var gunsprite := $GunSprite

func _ready() -> void:
	gunsprite.texture = newGun.gunSprite.texture

func _onInteract(area: Area2D) -> void:
	call_deferred("queue_free")
