extends Control

var tutorialLevel = load("res://Scenes/Debug/debug_area.tscn")
var levelTwo = load("res://Scenes/Levels/FinalLevel.tscn")

func _ready() -> void:
	if FileAccess.file_exists("user://MasterSound.save"):
		var save = FileAccess.open("user://MasterSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		$Options/Master.value = value
		save.close()
	
	if FileAccess.file_exists("user://MusicSound.save"):
		var save = FileAccess.open("user://MusicSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		$Options/Music.value = value
		save.close()
	
	if FileAccess.file_exists("user://SFXSound.save"):
		var save = FileAccess.open("user://MasterSound.save", FileAccess.READ)
		var value = save.get_var()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		$Options/SFX.value = value
		save.close()

func _onPlay() -> void:
	$Main.visible = false
	$"Level Select".visible = true

func _onOptions() -> void:
	$Main.visible = false
	$Options.visible = true

func _onQuit() -> void:
	get_tree().quit()

func _onBack() -> void:
	$Main.visible = true
	$"Level Select".visible = false
	$Options.visible = false

func _onTutorial() -> void:
	get_tree().change_scene_to_packed(tutorialLevel)

func _onLevelTwo() -> void:
	get_tree().change_scene_to_packed(levelTwo)

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
