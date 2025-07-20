extends Node

class_name Gun

@export var gunSprite : Sprite2D
@export var bullet : PackedScene
@export var bulletAmount : int
@export var launchSpeed : float
@export var shootCooldown : float
@export var spread : float
@export var ammoCapacity : int
@export var reloadTime : float
@export var holdTrigger : bool
@export var launchPosition : Vector2
var gunDictionary = {}

func _ready() -> void:
	gunDictionary = {
		"bulletType" : bullet,
		"bulletAmount" : bulletAmount,
		"bulletSpread" : spread,
		"bulletSpeed" : launchSpeed,
		"bulletPosition" : launchPosition,
		"gunSprite" : gunSprite,
		"gunType" : holdTrigger,
		"gunCapacity" : ammoCapacity,
		"gunCooldown" : shootCooldown,
		"currentBullets" : ammoCapacity,
		"reloadTime" : reloadTime,
		"reloadTimer" : 0.0
	}
