extends Button

@export var level_name: String
@export var level_num: int
@export var level: PackedScene

@onready var label: Label = $Label
@onready var time: Label = $time

func _ready() -> void:
	label.text = level_name
	var t = GameManager.level_times[level_num]
	if (t == -1.0):
		time.text = "N/A"
	else:
		time.text = str(t)
	

func _on_pressed() -> void:
	if (level == null):
		return
	await Blackout.black_out()
	get_tree().change_scene_to_file(level.resource_path)
	await Blackout.black_in()

func _on_return_button_pressed() -> void:
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	await Blackout.black_in()
