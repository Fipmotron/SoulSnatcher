extends Area2D

class_name HealthComponent

@export var parent : Node2D

@export var maxHealth : float
var health : float

var dotDamage : float
var damageOverTime : bool
var damageTime := 5.0
var damageTimer : float
var damageInterval := 0.5
var damageIntervalTimer : float

signal hit
signal death

func _ready() -> void:
	health = maxHealth
	
	hit.connect(Callable(parent, "_hit"))
	death.connect(Callable(parent, "_death"))

func _physics_process(delta: float) -> void:
	if damageTimer > 0.0:
		damageTimer -= delta
		
		damageIntervalTimer -= delta
		
		if damageIntervalTimer <= 0.0:
			damageIntervalTimer = damageInterval
			
			health -= dotDamage
			
			if health <= 0.0:
				emit_signal("death")
				
				damageTimer = 0.0

func _onEntered(area: Area2D) -> void:
	if area is HitboxComponent:
		health -= area.damage
		
		if area.applyBurn:
			damageTimer = damageTime
			
			dotDamage = area.dotDamage
		
		print(health)
		
		if health > 0.0:
			emit_signal("hit", area.knockbackForce, area.global_position, area.applyConfusion, area.applyFreeze)
		else:
			emit_signal("death")
