extends CharacterBody2D

const ACCEL = 10.0
const SPEED = 600.0
const JUMP_VELOCITY = -700.0
const GRAVITY = 2000
const FALL_GRAVITY = 3000

@onready var coyote_timer: Timer = $coyote_timer
@onready var cam: Camera2D = $Camera2D

var grav_dir = Vector2.DOWN
var was_on_floor = false
var jumping = false
var can_jump = true
var can_flip_grav = false
var sliding = false

func get_grav(velo: Vector2):
	if (velo.y < 0.0):
		return GRAVITY
	return FALL_GRAVITY

func jump():
	velocity.y = JUMP_VELOCITY
	jumping = true
	can_jump = false
	can_flip_grav = true

func _physics_process(delta: float) -> void:
	velocity = get_real_velocity()
	
	# Add the gravity.
	if is_on_floor():
		can_flip_grav = false
		can_jump = true
		jumping = false
	else:
		velocity += grav_dir * get_grav(velocity) * delta
		if (was_on_floor and !jumping):
			coyote_timer.start()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif (can_jump):
			jump()
	if (Input.is_action_just_released("jump") and velocity.y < 0.0):
		velocity.y *= 0.5
	
	# Get input direction
	var direction := Input.get_axis("left", "right")
	
	# Handle sliding.
	var on_slope = (get_floor_angle(-grav_dir) >= deg_to_rad(20))
	var floor_normal: Vector2 = get_floor_normal().normalized()
	var theta = floor_normal.angle_to(grav_dir)
	if (Input.is_action_just_pressed("slide") and is_on_floor()):
		velocity.x += direction * SPEED * 1.5
	
	if (Input.is_action_pressed("slide") and is_on_floor()):
		sliding = true
		if (on_slope):
			velocity += grav_dir * GRAVITY * sign(theta) * sin(theta)
			velocity.x = clamp(velocity.x, -SPEED * 1.5, SPEED * 1.5)
	if (Input.is_action_just_released("slide") and sliding):
		sliding = false
	
	if direction:
		if (!sliding):
			velocity.x = lerp(velocity.x, SPEED * direction, ACCEL * 1.2 * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, ACCEL / 4.0 * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCEL * delta)

	was_on_floor = is_on_floor()
	move_and_slide()

func _on_coyote_timer_timeout() -> void:
	if (!is_on_floor()):
		can_jump = false
