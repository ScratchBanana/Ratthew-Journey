extends TextureButton

@onready var button_click_sfx: AudioStreamPlayer = $"../../button_click_sfx"

func _on_pressed() -> void:
	button_click_sfx.play()
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	Blackout.black_in()
