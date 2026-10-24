extends CharacterBody2D

const ACCEL = 10.0
const SPEED = 650.0
const JUMP_VELOCITY = -800.0
const GRAVITY = 2000
const FALL_GRAVITY = 3000
const SLIDE_MULT = 1.3
const DEF_SCALE = Vector2(2.35, 2.35)

@onready var coyote_timer: Timer = $coyote_timer
@onready var cam: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var anims: AnimationPlayer = $anims

var grav_dir = Vector2.DOWN
var was_on_floor = false
var jumping = false
var can_jump = true
var can_flip_grav = false
var sliding = false

func get_grav(velo: Vector2):
	if (grav_dir_is_vertical()):
		if (sign(grav_dir.x) * velo.x < 0.0):
			return GRAVITY
		return FALL_GRAVITY
	else:
		if (sign(grav_dir.y) * velo.y < 0.0):
			return GRAVITY
		return FALL_GRAVITY

func jump():
	can_flip_grav = true
	if (was_on_floor && is_on_wall()):
		can_flip_grav = false
	anims.play("jump")
	sprite.scale = Vector2(0.35 * DEF_SCALE.x, 1.6 * DEF_SCALE.y)
	velocity.y = grav_dir.y * JUMP_VELOCITY
	velocity.x = grav_dir.x * JUMP_VELOCITY
	jumping = true
	can_jump = false

func grav_dir_is_vertical():
	if (abs(grav_dir.dot(Vector2(0, -1))) == 1.0):
		return true
	return false

func _physics_process(delta: float) -> void:
	velocity = get_real_velocity()
	
	# Add the gravity.
	if is_on_floor():
		if (!was_on_floor && jumping):
			sprite.scale = Vector2(1.4 * DEF_SCALE.x, 0.3 * DEF_SCALE.y)
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
	if (Input.is_action_just_released("jump")):
		if (grav_dir_is_vertical()):
			if (sign(grav_dir.y) * velocity.y < 0.0):
				velocity.y *= 0.6
		else:
			if (sign(grav_dir.x) * velocity.x < 0.0):
				velocity.x *= 0.6
	
	# Get input direction
	var direction := Input.get_axis("left", "right")
	var gd_sign_x = sign(grav_dir.x)
	var gd_sign_y = sign(grav_dir.y)
	
	# Handle sliding.
	var on_slope = (get_floor_angle(-grav_dir) >= deg_to_rad(20.0))
	var floor_normal: Vector2 = get_floor_normal().normalized()
	var theta = floor_normal.angle_to(grav_dir)
	
	if (Input.is_action_just_pressed("slide") and is_on_floor()):
		velocity.x += gd_sign_y * direction * SPEED * SLIDE_MULT
		velocity.y += -gd_sign_x * direction * SPEED * SLIDE_MULT
	
	if (Input.is_action_pressed("slide") and is_on_floor()):
		sliding = true
		if (on_slope):
			velocity += grav_dir * GRAVITY * sign(theta) * sin(theta)
			if (grav_dir_is_vertical()):
				velocity.y = clamp(velocity.y, -SPEED * SLIDE_MULT, SPEED * SLIDE_MULT)
			else:
				velocity.x = clamp(velocity.x, -SPEED * SLIDE_MULT, SPEED * SLIDE_MULT)
	if (Input.is_action_just_released("slide") and sliding):
		sliding = false
	
	if direction:
		if (!sliding):
			if (grav_dir_is_vertical()):
				velocity.x = lerp(velocity.x, gd_sign_y * SPEED * direction, ACCEL * 1.4 * delta)
			else:
				velocity.y = lerp(velocity.y, -gd_sign_x * SPEED * direction, ACCEL * 1.4 * delta)
		else:
			if (grav_dir_is_vertical()):
				velocity.x = lerp(velocity.x, 0.0, ACCEL / 4.0 * delta)
			else:
				velocity.y = lerp(velocity.y, 0.0, ACCEL / 4.0 * delta)
	else:
		if (grav_dir_is_vertical()):
			velocity.x = lerp(velocity.x, 0.0, ACCEL * delta)
		else:
			velocity.y = lerp(velocity.y, 0.0, ACCEL * delta)

	was_on_floor = is_on_floor()
	move_and_slide()
	
	# Handle gravity shifting
	if (jumping && !was_on_floor && is_on_wall() && direction && can_flip_grav):
		var wall_normal = get_wall_normal()
		var vel_vector
		if (grav_dir_is_vertical()):
			vel_vector = Vector2(gd_sign_y * direction, 0.0)
		else:
			vel_vector = Vector2(0.0, -gd_sign_x * direction)
	
		# Switches the direction of gravity!
		if (wall_normal.dot(vel_vector) == -1.0):
			var old_grav_dir = grav_dir
			grav_dir = wall_normal * -1.0
			set_up_direction(wall_normal)
			self.global_rotation += old_grav_dir.angle_to(grav_dir)
	
	# Handle animations!
	if (is_on_floor()):
		if (direction):
			if (direction < 0.0):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			if (!sliding):
				anims.play("run")
			else:
				anims.play("slide")
		else:
			anims.play("idle")
	else:
		if (grav_dir_is_vertical()):
			if (sign(grav_dir.y) * velocity.y > 0.0):
				anims.play("fall")
		else:
			if (sign(grav_dir.x) * velocity.x > 0.0):
				anims.play("fall")

func _process(delta: float) -> void:
	sprite.scale = lerp(sprite.scale, DEF_SCALE, 10.0 * delta)

func _on_coyote_timer_timeout() -> void:
	if (!is_on_floor()):
		can_jump = false
