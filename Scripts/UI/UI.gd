extends CanvasLayer

var mainMenu = load("res://Scenes/Transitions/MainMenu.tscn")
var isPaused := false
var player : Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	$Player/HealthBar.max_value = player.healthComponent.maxHealth
	$Player/HealthBar.value = player.healthComponent.maxHealth
	
	if FileAccess.file_exists("user://MasterSound.save"):
		var save = FileAccess.open("user://MasterSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		$PauseMenu/Panel/Options/Master.value = value
		save.close()
	
	if FileAccess.file_exists("user://MusicSound.save"):
		var save = FileAccess.open("user://MusicSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		$PauseMenu/Panel/Options/Music.value = value
		save.close()
	
	if FileAccess.file_exists("user://SFXSound.save"):
		var save = FileAccess.open("user://MasterSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		$PauseMenu/Panel/Options/SFX.value = value
		save.close()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if isPaused:
			isPaused = false
			get_tree().paused = false
			$PauseMenu.visible = false
			$Player.visible = true
		elif not isPaused:
			isPaused = true
			get_tree().paused = true
			$PauseMenu.visible = true
			$Player.visible = false

func _physics_process(delta: float) -> void:
	$Player/HealthBar.value = player.healthComponent.health
	var bulletsLeft = str(player.bulletsLeft)
	var magCapacity = str(player.gunCapacity)
	$Player/MagazineCapacity.text = bulletsLeft + "/" + magCapacity 
	$Player/SoulAmount.text = str(player.soulCount)

func _onResume() -> void:
	isPaused = false
	get_tree().paused = false
	$PauseMenu.visible = false
	$Player.visible = true

func _onRestart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _onOptions() -> void:
	$PauseMenu/Panel/Main.visible = false
	$PauseMenu/Panel/Options.visible = true

func _onExit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(mainMenu)

func _onBack() -> void:
	$PauseMenu/Panel/Main.visible = true
	$PauseMenu/Panel/Options.visible = false

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
	var save = FileAccess.open("user://MasterSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	
	var save = FileAccess.open("user://MusicSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	
	var save = FileAccess.open("user://SFXSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()


func _on_end_level_area_entered(area: Area2D) -> void:
	$PauseMenu.visible = false
	$Player.visible = false
	$Levelend.visible = true
