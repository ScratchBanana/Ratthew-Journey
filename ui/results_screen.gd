extends CanvasLayer

const AMP = 0.05
const FREQ = 2.0
const GUY_ON_POS: Vector2 = Vector2(447.0, 172.0)
const GUY_OFF_POS: Vector2 = Vector2(640.0, 172.0)

@onready var time_label: Label = $Control/Label
@onready var results_text: TextureRect = $Control/results_text
@onready var little_guy: TextureRect = $Control/little_guy
@onready var cheese: TextureRect = $Control/cheese
@onready var new_best: Label = $Control/new_best
@onready var return_button: TextureButton = $Control/return_button

@onready var impact_sfx: AudioStreamPlayer = $impact_sfx
@onready var slide_sfx: AudioStreamPlayer = $slide_sfx
@onready var mini_impact: AudioStreamPlayer = $mini_impact
@onready var whoosh_sfx: AudioStreamPlayer = $whoosh_sfx
@onready var button_click_sfx: AudioStreamPlayer = $button_click_sfx

var tick = 0.0
var tween: Tween
var can_rotate = true
var is_new_best = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	if (can_rotate):
		cheese.rotation += deg_to_rad(26.0)
	results_text.scale.x = 1.0 + AMP * sin(FREQ * tick)
	results_text.scale.y = 1.0 + AMP * cos(FREQ * tick)
	results_text.rotation = deg_to_rad(0.0 + 2.0 * cos(FREQ * tick))
	tick += delta
 
func reveal_stats(time: float, level_idx: int):
	set_win_time(time, level_idx)
	open_win_screen()
	

func set_win_time(value: float, idx: int):
	var min = int(value) / 60
	var sec = int(value) % 60
	var m_sec = int(value * 100) % 100
	
	is_new_best = false
	if (value < GameManager.level_times[idx]):
		is_new_best = true
	
	time_label.text = "TIME: %02d:%02d:%02d" % [min, sec, m_sec]


func _on_return_button_pressed() -> void:
	button_click_sfx.play()
	close_win_screen()

func open_win_screen():
	return_button.disabled = true
	return_button.modulate = Color.DARK_SLATE_GRAY
	self.visible = true
	time_label.visible = false
	results_text.visible = false
	new_best.visible = false
	little_guy.position = GUY_OFF_POS
	can_rotate = true
	cheese.rotation = 0.0
	
	whoosh_sfx.play()
	await get_tree().create_timer(1.0).timeout
	impact_sfx.play()
	setup_tween(Tween.EASE_OUT, Tween.TRANS_BACK)
	results_text.visible = true
	tween.tween_property(results_text, "scale", Vector2.ONE, 0.3).from(Vector2(4.0, 4.0))
	tween.chain().tween_property(cheese, "scale", Vector2.ONE, 0.3).from(Vector2(1.3, 1.3))
	await tween.finished
	can_rotate = false
	await get_tree().create_timer(0.6).timeout
	setup_tween(Tween.EASE_OUT, Tween.TRANS_BACK)
	mini_impact.play()
	time_label.visible = true
	tween.tween_property(time_label, "scale", Vector2.ONE, 0.1).from(Vector2(1.4, 1.4))
	await tween.finished
	if (is_new_best):
		setup_tween(Tween.EASE_OUT, Tween.TRANS_BACK)
		mini_impact.play()
		new_best.visible = true
		tween.tween_property(new_best, "scale", Vector2.ONE, 0.1).from(Vector2(1.4, 1.4))
		await tween.finished
	await get_tree().create_timer(0.6).timeout
	slide_sfx.play()
	setup_tween(Tween.EASE_OUT, Tween.TRANS_EXPO)
	tween.tween_property(little_guy, "position", GUY_ON_POS, 1.8).from(GUY_OFF_POS)
	tween.chain().tween_property(slide_sfx, "volume_db", -10.0, 0.2).from(0.0)
	await tween.finished
	slide_sfx.stop()
	return_button.modulate = Color.WHITE
	return_button.disabled = false
	

func close_win_screen():
	await Blackout.black_out()
	self.visible = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	Blackout.black_in()

func setup_tween(ease_type, trans_type):
	if (tween):
		tween.kill()
	tween = get_tree().create_tween().set_parallel(true)
