extends CharacterBody2D

class_name Player

@export_category("Ground Movement")
@export var groundSpeed : float
@export var attractSpeed : float
var direction : Vector2
var recordedDirection : Vector2
var facingUp = true
var facingRight = true
var isAttracting = false

@export_category("Dash Movement")
@export var dashSpeed : float
@export var dashTime : float
@export var dashCooldownTime : float
var dashTimer : float
var dashCooldownTimer : float
var isDashing = false

@export_category("Gun Mechanics")
@export var gunDistance : float
@export var lerpSpeed : float
@onready var debugPos = $GunHolder

var canShoot = false

var bulletType : PackedScene
var bulletAmount : float
var bulletSpread : float
var bulletSpeed : float
var bulletPosition : Vector2
@onready var gunSprite = $GunHolder/GunSprite
var gunHoldTrigger : bool
var gunCapacity : int
var gunCooldown : float
var reloadTime : float

var bulletsLeft : int
var gunCooldownTimer : float

var gunArray = []
 
var gunKey = 0

@export_category("animation")
@onready var sprite = $Sprite2D
@onready var animationTree = $AnimationPlayer/AnimationTree
@onready var vaccumSprite = $GunHolder/VaccumSprite

@export_category("Shop")
@onready var healthComponent = $HealthComponent
var soulCount : float

var canMove = true
var isDead = false
var deathTime = 1.0

func _ready() -> void:
	Signalbus.connect("addSoul", Callable(self, "_addSoul"))

func _physics_process(delta: float) -> void:
	if isDead:
		deathTime -= delta
		
		if deathTime <= 0.0:
			get_tree().reload_current_scene()

func _direction():
	var hori = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var vert = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	if vert < 0.0:
		facingUp = true
	elif vert > 0.0:
		facingUp = false
	
	if hori > 0.0:
		facingRight = true
	elif hori < 0.0:
		facingRight = false
	
	direction = Vector2(hori, vert)
	
	var directionMagnitude = direction.x + direction.y
	
	if directionMagnitude != 0.0:
		recordedDirection = direction

func _move():
	if not isAttracting:
		velocity = groundSpeed * direction.normalized()
	elif isAttracting:
		velocity = attractSpeed * direction.normalized()

func _input(event: InputEvent) -> void:
	if canMove:
		if event.is_action_pressed("Dash") and dashCooldownTimer <= 0.0 and not isDashing:
			isDashing = true
			$SFX/DashSFX.play()
			dashTimer = dashTime
		
		if event.is_action_pressed("CycleRight"):
			gunKey += 1
			
			if gunKey >= len(gunArray):
				gunKey = 0
			
			if len(gunArray) != 0:
				if gunArray[gunKey - 1] != null:
					gunArray[gunKey - 1]["currentBullets"] = bulletsLeft
			
			if len(gunArray) != 1 and len(gunArray) != 0:
				_gunSwitch(gunKey)
		elif event.is_action_pressed("CycleLeft"):
			gunKey -= 1
			
			if len(gunArray) != 0:
				if gunArray[gunKey + 1] != null:
					gunArray[gunKey + 1]["currentBullets"] = bulletsLeft
			
			if gunKey < 0:
				gunKey = len(gunArray) - 1 
			
			if len(gunArray) != 1 and len(gunArray) != 0:
				_gunSwitch(gunKey)
		
		if event.is_action_pressed("Consume"):
			$AttractionComponent/CollisionPolygon2D.disabled = false
			
			vaccumSprite.visible = true
			gunSprite.visible = false
			
			$SFX/VaccumSFX.playing = true
			
			isAttracting = true
		elif event.is_action_released("Consume") or isDashing:
			$AttractionComponent/CollisionPolygon2D.disabled = true
			
			$SFX/VaccumSFX.playing = false
			
			vaccumSprite.visible = false
			gunSprite.visible = true
			
			isAttracting = false

func _dash(delta):
	if direction == Vector2.ZERO:
		velocity = dashSpeed * recordedDirection.normalized()
	else:
		velocity = dashSpeed * direction.normalized()
	
	dashTimer -= delta
	
	if dashTimer <= 0.0:
		isDashing = false
		
		dashCooldownTimer = dashCooldownTime

func _dashRefresh(delta):
	if dashCooldownTimer > 0.0:
		dashCooldownTimer -= delta

func _physics():
	if canMove:
		move_and_slide()

func _gunInput():
	if not isAttracting:
		if Input.is_action_just_pressed("Shoot") and not gunHoldTrigger or Input.get_action_strength("Shoot") and gunHoldTrigger:
			if canShoot and gunCooldownTimer <= 0.0 and gunArray[gunKey]["reloadTimer"] <= 0.0:
				for i in bulletAmount:
					var bullet = bulletType.instantiate()
					$GunHolder/GunSprite/ShootPosition.position = bulletPosition
					bullet.global_position = $GunHolder/GunSprite/ShootPosition.global_position
					bullet.rotation = $GunHolder/GunSprite.rotation
					
					var directionVector = global_position-bullet.global_position
					var directionSpread = directionVector.rotated(deg_to_rad(randf_range(-bulletSpread, bulletSpread)))
					
					bullet.velocity = -directionSpread.normalized() * bulletSpeed
					get_tree().root.add_child(bullet)
				
				gunCooldownTimer = gunCooldown
				bulletsLeft -= 1
				$SFX/ShootSFX.play()
				
				if bulletsLeft <= 0:
					bulletsLeft = gunCapacity
					
					$SFX/ReloadSFX.play()
					
					gunArray[gunKey]["reloadTimer"] = reloadTime
		
		if Input.is_action_just_pressed("Reload") and bulletsLeft < gunCapacity:
			bulletsLeft = gunCapacity
			
			$SFX/ReloadSFX.play()
			
			gunArray[gunKey]["reloadTimer"] = reloadTime

func _gunRefresh(delta):
	if gunCooldownTimer > 0.0:
		gunCooldownTimer -= delta
	
	for i in gunArray:
		if i["reloadTimer"]  > 0.0:
			i["reloadTimer"] -= delta

func _gunMovement(_delta):
	if canMove:
		var trackPosition = get_global_mouse_position()
		var mouseDirection = (get_global_mouse_position() - global_position).normalized()
		
		if global_position.distance_to(get_global_mouse_position()) > gunDistance:
			trackPosition = global_position + (mouseDirection * gunDistance)
		
		debugPos.global_position = trackPosition
		gunSprite.look_at(get_global_mouse_position())
		vaccumSprite.look_at(get_global_mouse_position())
		
		if abs(gunSprite.rotation_degrees) >= 360:
			gunSprite.rotation_degrees = 0
		
		if gunSprite.rotation_degrees > 270 or gunSprite.rotation_degrees < -270:
			gunSprite.flip_v = false
		elif gunSprite.rotation_degrees > 90 or gunSprite.rotation_degrees < -90:
			gunSprite.flip_v = true
		else:
			gunSprite.flip_v = false
		
		$AttractionComponent.look_at(get_global_mouse_position())

func _gunSwitch(key):
	var gunReference = gunArray[key]
	
	bulletType = gunReference["bulletType"]
	bulletAmount = gunReference["bulletAmount"]
	bulletSpread = gunReference["bulletSpread"]
	bulletSpeed = gunReference["bulletSpeed"]
	bulletPosition = gunReference["bulletPosition"]
	gunSprite.set_texture(gunReference["gunSprite"].get_texture())
	gunCapacity = gunReference["gunCapacity"]
	gunCooldown = gunReference["gunCooldown"]
	gunHoldTrigger = gunReference["gunType"]
	reloadTime = gunReference["reloadTime"]
	bulletsLeft = gunReference["currentBullets"]

func _onInteract(area: Area2D) -> void:
	if area is GunInteractable:
		gunArray.append(area.newGun.gunDictionary)
		
		_gunSwitch(len(gunArray) - 1)
		
		if len(gunArray) == 1:
			canShoot = true

func _animation():
	animationTree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	animationTree.set("parameters/conditions/dash", isDashing and not velocity == Vector2.ZERO)
	animationTree.set("parameters/conditions/shuffle", isAttracting and not velocity == Vector2.ZERO)
	animationTree.set("parameters/conditions/walk", velocity != Vector2.ZERO and not isDashing and not isAttracting)
	animationTree.set("parameters/conditions/death", isDead)
	
	if facingRight:
		sprite.flip_h = false
	elif not facingRight:
		sprite.flip_h = true

func _addSoul(amount):
	soulCount += amount
	
	$SFX/CaptureSFX.play()

func _walkSFX():
	$SFX/WalkSFX.play()

func _hit(kbForce, kbPosition, applyConfusion, applyFreeze):
	$SFX/HitSFX.play()

func _death():
	$SFX/DeathSFX.play()
	$HealthComponent/CollisionShape2D.set_deferred("disabled", true)
	canShoot = false
	canMove = false
	isDead = true
