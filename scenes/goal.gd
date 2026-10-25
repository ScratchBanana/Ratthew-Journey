extends Node2D

@export var level_num: int
var clear_time = 0.0
var tracking = true
@onready var pop_sfx: AudioStreamPlayer = $pop_sfx
@onready var confetti_particles: GPUParticles2D = $confetti_particles
@onready var music: AudioStreamPlayer = $music

func _ready() -> void:
	music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (tracking):
		clear_time += delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		confetti_particles.emitting = true
		pop_sfx.play()
		tracking = false
		body.set_can_move(false)
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(body, "global_position", self.global_position, 0.4)
		await tween.finished
		await Blackout.black_out()
		ResultsScreen.reveal_stats(clear_time, level_num)
		if (GameManager.level_times[level_num] == -1.0 || clear_time < GameManager.level_times[level_num]):
			GameManager.level_times[level_num] = clear_time
		Blackout.black_in()
