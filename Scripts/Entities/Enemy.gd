extends CharacterBody2D

@export var isActive := true
@export var hasGun : bool

@export var gunDistance : float
var player : Player
var playerDetected = false

@export var chargeUpTime : float
var chargeUpTimer : float

var gunCooldownTimer : float
var reloadTimer : float

var bulletsLeft : float

var canShoot = true

@export var chaseSpeed : float
@export var attackSpeed : float
@export var attackRadius : float
@export var attackTime : float
var attackTimer : float
var attackDirection : Vector2
var isAttacking : bool
var canMove = true

@export var runAwaySpeed : float
@export var runAwayRadius : float
@export var runTowardsRadius : float
@export var stopMin : float
@export var stopMax : float
var runAway = false
var runTowards = false

@export var checkRadius : float
@export var breakLineOfSight : bool
@onready var gunHolder = $GunHolder

@onready var animationTree = $AnimationPlayer/AnimationTree
@export var chaseAnimation : bool
@export var rangeAnimation : bool
@export var stationaryAnimation : bool
var isDead : bool

@onready var healthCompo = $HealthComponent

@export var waveReciver : Node2D
signal waveDeath

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	if rangeAnimation:
		$GunHolder/Sprite2D.texture = $Gun.gunSprite.texture
	
	if hasGun:
		bulletsLeft = $Gun.ammoCapacity
	
	if not isActive:
		_deActivate()
	
	waveDeath.connect(Callable(waveReciver, "_checkDeaths"))

func _physics_process(delta: float) -> void:
	var playerDirection = (player.global_position-global_position).normalized()
	
	if rangeAnimation:
		$GunHolder/Sprite2D.look_at(player.global_position)
	
	if canMove:
		move_and_slide()

func _playerCheck():
	if canMove or stationaryAnimation:
		if global_position.distance_to(player.global_position) <= checkRadius:
			$LineOfSight.target_position = player.global_position - global_position
			$CollisionMask.target_position = player.global_position - global_position
		
		if playerDetected:
			if $CollisionMask.is_colliding():
				playerDetected = false
		
		if $LineOfSight.is_colliding() and not $CollisionMask.is_colliding():
			playerDetected = true

func _rangeCheck():
	if global_position.distance_to(player.global_position) < runAwayRadius:
		runAway = true
	
	if global_position.distance_to(player.global_position) > runTowardsRadius:
		runTowards = true
	
	if global_position.distance_to(player.global_position) > stopMin and global_position.distance_to(player.global_position) < stopMax:
		runTowards = false
		runAway = false

func _gunMechanics(delta):
	if canShoot:
		if chargeUpTimer > 0.0:
			chargeUpTimer -= delta
		else:
			if gunCooldownTimer <= 0.0 and reloadTimer <= 0.0:
				if stationaryAnimation:
					animationTree.get("parameters/playback").travel("Shoot")
				
				for i in $Gun.bulletAmount:
						var bullet = $Gun.bullet.instantiate()
						$GunHolder/ShootPosition.position = $Gun.launchPosition
						bullet.global_position = $GunHolder/ShootPosition.global_position
						
						var directionVector = player.global_position-bullet.global_position
						var directionSpread = directionVector.rotated(deg_to_rad(randf_range(-$Gun.spread, $Gun.spread)))
						
						bullet.velocity = directionSpread.normalized() * $Gun.launchSpeed
						get_tree().root.add_child(bullet)
				
				gunCooldownTimer = $Gun.shootCooldown
				bulletsLeft -= 1
				
				if bulletsLeft <= 0:
					bulletsLeft = $Gun.ammoCapacity
					
					reloadTimer = $Gun.reloadTime

func _gunTimer(delta):
	if gunCooldownTimer > 0.0:
		gunCooldownTimer -= delta
	
	if reloadTimer > 0.0:
		reloadTimer -= delta

func _gunMovement():
	var trackPosition = player.global_position
	var playerDirection = (player.global_position - global_position).normalized()
	
	if global_position.distance_to(player.global_position) > gunDistance:
		trackPosition = global_position + (playerDirection * gunDistance)
	
	gunHolder.global_position = trackPosition

func _chaseMovement():
	var chaseDirection = (player.global_position - global_position).normalized()
	
	velocity = chaseDirection * chaseSpeed

func _runMovement():
	var runDirection = (player.global_position - global_position).normalized()
	
	velocity = -runDirection * runAwaySpeed

func _attackCheck():
	if global_position.distance_to(player.global_position) <= attackRadius:
		print("ATTACK")
		
		chargeUpTimer = chargeUpTime
		attackTimer = attackTime
		isAttacking = true

func _attackMechanics(delta):
	if chargeUpTimer > 0.0:
		chargeUpTimer -= delta
		attackDirection = player.global_position - global_position
	elif chargeUpTimer <= 0.0:
		$HitboxComponent/CollisionShape2D.disabled = false
		velocity = attackDirection.normalized() * attackSpeed
		attackTimer -= delta
		
		if attackTimer <= 0.0:
			isAttacking = false

func _hit(knockbackForce, knockbackPosition, applyConfusion, applyFreeze):
	$EnemyHit.play()

func _death():
	canShoot = false
	canMove = false
	playerDetected = false
	isDead = true
	
	emit_signal("waveDeath")
	
	velocity = Vector2.ZERO
	
	if not rangeAnimation:
		$GunHolder/Polygon2D.visible = false
	elif rangeAnimation:
		$GunHolder/Sprite2D.visible = false
	
	$HealthComponent.set_deferred("monitoring", false)
	
	$EnemySoul.isActive = true
	$EnemySoul.visible = true

func _onPlayerDetect(area: Area2D) -> void:
	if $LineOfSight.is_colliding() and not $CollisionMask.is_colliding():
		playerDetected = true
		
		chargeUpTimer = chargeUpTime

func _noPlayerDetect(area: Area2D) -> void:
	if not breakLineOfSight:
		playerDetected = false

func _animate():
	if isActive:
		if chaseAnimation:
			animationTree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
			animationTree.set("parameters/conditions/attack", isAttacking)
			animationTree.set("parameters/conditions/noAttack", not isAttacking)
			animationTree.set("parameters/conditions/run", velocity != Vector2.ZERO)
			animationTree.set("parameters/conditions/death", isDead)
			
			if velocity.x > 0.0:
				$Sprite2D.flip_h = false
			elif velocity.x < 0.0:
				$Sprite2D.flip_h = true
		
		if rangeAnimation:
			animationTree.set("parameters/conditions/active", playerDetected)
			animationTree.set("parameters/conditions/walk", runAway or runTowards)
			animationTree.set("parameters/conditions/shoot", not runAway and not runTowards)
			animationTree.set("parameters/conditions/death", isDead)
			
			if not isDead:
				if runAway or runTowards:
					if velocity.x > 0.0:
						$Sprite2D.flip_h = false
					elif velocity.x < 0.0:
						$Sprite2D.flip_h = true
				else:
					var playerDirection = (player.global_position-global_position).normalized()
					
					if playerDirection.x > 0.0:
						$Sprite2D.flip_h = false
					elif playerDirection.x < 0.0:
						$Sprite2D.flip_h = true
					
		
		if stationaryAnimation:
			animationTree.set("parameters/conditions/death", isDead)
			animationTree.set("parameters/conditions/inactive", not playerDetected)
			animationTree.set("parameters/conditions/lock", playerDetected)

func _deActivate():
	canMove = false
	canShoot = false
	isActive = false
	healthCompo.monitoring = false
	visible = false

func _activate():
	canMove = true
	canShoot = true
	isActive = true
	healthCompo.monitoring = true
	visible = true

func _hitboxDeactive():
	$HitboxComponent/CollisionShape2D.disabled = true
