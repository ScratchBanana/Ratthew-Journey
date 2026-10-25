extends Control

signal proceed

@export_multiline var lines: Array[String]
@onready var text_box: RichTextLabel = $RichTextLabel
@onready var continue_label: Label = $Label
@onready var pop_sfx: AudioStreamPlayer = $pop_sfx

var can_continue = false

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_pressed("continue")):
		if (can_continue):
			proceed.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	speak()

func speak():
	for line in lines:
		continue_label.visible = false
		can_continue = false
		text_box.visible_characters = 0
		text_box.text = line
		var idx = 0
		for character in line:
			text_box.visible_characters += 1
			
			if (idx % 2 == 0):
				pop_sfx.play()
			
			if (",.?!".contains(character)):
				await get_tree().create_timer(0.15).timeout
			else:
				await get_tree().create_timer(0.05).timeout
			idx += 1
		can_continue = true
		continue_label.visible = true
		await proceed
	continue_label.visible = false
	await get_tree().create_timer(1.0).timeout
	await Blackout.black_out()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	Blackout.black_in()
