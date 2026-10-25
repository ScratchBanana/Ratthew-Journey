extends Control

@onready var settings: Control = $settings
@onready var main: Control = $main

@onready var play_button: TextureButton = $main/VBoxContainer/play_button
@onready var settings_button: TextureButton = $main/VBoxContainer/settings_button
@onready var button_container: VBoxContainer = $main/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	Blackout.black_in()

func _on_settings_button_pressed() -> void:
	open_settings()

func _on_return_button_pressed() -> void:
	close_settings()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func open_settings():
	var tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	
	tween.tween_property(main, "position:x", -640, 1.0)
	tween.tween_property(settings, "position:x", 0, 1.0)

func close_settings():
	var tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	
	tween.tween_property(main, "position:x", 0, 1.0)
	tween.tween_property(settings, "position:x", 640, 1.0)
