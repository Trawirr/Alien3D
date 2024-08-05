class_name SlidingPlayerState

extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION: float = 0.2
@export var DECELERATION: float = 0.4
@export var TILT_AMOUNT: float = 0.09
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED: float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = $"../../ShapeCast3D"

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	ANIMATION.get_animation("sliding").track_set_key_value(3, 1, tilt)
	ANIMATION.get_animation("sliding").track_set_key_value(3, 2, tilt)
	
	for i in range(8):
		print("animation track ", i, ": ", ANIMATION.get_animation("sliding").track_get_path(i))

func enter(previous_state) -> void:
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation("sliding").track_set_key_value(5, 0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1.0
	ANIMATION.play("sliding", -1.0, SLIDE_ANIM_SPEED)
	
func finish():
	print("finish func")
	transition.emit("CrouchingPlayerState")
	
func update(delta):
	PLAYER.update_gravity(delta)
	#PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
