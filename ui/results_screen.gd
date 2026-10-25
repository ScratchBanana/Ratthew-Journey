extends CanvasLayer

@onready var time_label: Label = $Control/MarginContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
 
func reveal_stats(time: float):
	set_win_time(time)
	open_win_screen()
	

func set_win_time(value: float):
	var min = int(value) / 60
	var sec = int(value) % 60
	time_label.text = "TIME: %02d:%02d" % [min, sec]


func _on_return_button_pressed() -> void:
	close_win_screen()

func open_win_screen():
	self.visible = true

func close_win_screen():
	await Blackout.black_out()
	self.visible = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	Blackout.black_in()
