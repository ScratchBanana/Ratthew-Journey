extends Control

@onready var settings: Control = $settings
@onready var main: Control = $main

@onready var play_button: TextureButton = $main/VBoxContainer/play_button
@onready var settings_button: TextureButton = $main/VBoxContainer/settings_button
@onready var button_container: VBoxContainer = $main/VBoxContainer

@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var button_click_sfx: AudioStreamPlayer = $button_click_sfx

@onready var music: AudioStreamPlayer = $music
@onready var title_art: TextureRect = $main/title_art

var tick = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anims.play("menu_anim")
	music.play()

func _process(delta: float) -> void:
	
	title_art.rotation = deg_to_rad(0.0 + 2.0 * sin(0.5 * tick))
	tick += delta


func _on_play_button_pressed() -> void:
	button_click_sfx.play()
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")
	Blackout.black_in()

func _on_settings_button_pressed() -> void:
	button_click_sfx.play()
	open_settings()

func _on_return_button_pressed() -> void:
	button_click_sfx.play()
	close_settings()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

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
