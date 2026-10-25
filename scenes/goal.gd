extends Node2D

var clear_time = 0.0
var tracking = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (tracking):
		clear_time += delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		tracking = false
		body.set_can_move(false)
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(body, "global_position", self.global_position, 0.4)
		await tween.finished
		await Blackout.black_out()
		ResultsScreen.reveal_stats(clear_time)
		Blackout.black_in()
