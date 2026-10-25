extends CanvasLayer

@onready var anims: AnimationPlayer = $AnimationPlayer

func black_in():
	anims.play("black_out")

func black_out():
	anims.play("black_in")
	await anims.animation_finished
