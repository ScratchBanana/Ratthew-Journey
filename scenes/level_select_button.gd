extends Button

@export var level_name: String
@export var level_num: int
@export var level: PackedScene

@onready var label: Label = $Label
@onready var time: Label = $time
@onready var button_click_sfx: AudioStreamPlayer = $button_click_sfx

func _ready() -> void:
	label.text = level_name
	var t = GameManager.level_times[level_num]
	if (t == -1.0):
		time.text = "N/A"
	else:
		time.text = calc_display_time(t)
	

func _on_pressed() -> void:
	if (level == null):
		return
	button_click_sfx.play()
	await Blackout.black_out()
	get_tree().change_scene_to_file(level.resource_path)
	await Blackout.black_in()

func _on_return_button_pressed() -> void:
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	await Blackout.black_in()

func calc_display_time(value) -> String:
	var min = int(value) / 60
	var sec = int(value) % 60
	var m_sec = int(value * 100) % 100
	
	return "%02d:%02d:%02d" % [min, sec, m_sec]
