class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED: float = 2.5
@export var ACCELERATION: float = 0.25
@export var DECELERATION: float = 0.5
@export_range(1, 6, 0.1) var CROUCH_SPEED: float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = $"../../ShapeCast3D"

var RELEASED: bool = false

func uncrouch() -> void:
	if !CROUCH_SHAPECAST.is_colliding() and !Input.is_action_just_pressed("crouch"):
		ANIMATION.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit("IdlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch()

func enter(previous_state) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("crouch", -1.0, CROUCH_SPEED)
	else:
		ANIMATION.current_animation = "crouching"
		ANIMATION.seek(1.0, true)
	
func exit() -> void:
	RELEASED = false
	
func update(delta) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
	elif !Input.is_action_pressed("crouch") and !RELEASED:
		RELEASED = true
		uncrouch()
