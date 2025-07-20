extends Node2D

@onready var shopHost = get_parent()
signal boughtItem

@export var sellAmount : int

@export var newhealth : float
@export var newAmmo : PackedScene
@export var sellTexture : Texture2D
@export var boughtTexture : Texture2D

@export var sellHealth : bool
@export var sellAmmo : bool
@export var sellGun : bool

var hasSold = false

var playerDetected = false
var player : Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	$Sprite2D.texture = sellTexture
	
	boughtItem.connect(Callable(self, "_boughtResponse"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Buy") and playerDetected and not hasSold:
		if sellAmount <= player.soulCount:
			if sellGun:
				player.gunArray.append($NewGun.gunDictionary)
				player._gunSwitch(len(player.gunArray) - 1)
			elif sellAmmo:
				player.bulletType = newAmmo
				player.gunArray[player.gunKey]["bulletType"] = newAmmo
			elif sellHealth:
				player.healthComponent.health += newhealth
				print(player.healthComponent.health)
			
			player.soulCount -= sellAmount
			
			$Bought.play()
			
			$Sprite2D.texture = boughtTexture
			
			hasSold = true

func _onInteraction(area: Area2D) -> void:
	playerDetected = true

func _noInteraction(area: Area2D) -> void:
	playerDetected = false
