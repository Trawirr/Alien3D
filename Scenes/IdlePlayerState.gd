class_name IdlePlayerState

extends PlayerMovementState

@export var SPEED: float = 4.0
@export var ACCELERATION: float = 0.2
@export var DECELERATION: float = 0.4

func enter(previous_state) -> void:
	ANIMATION.pause()

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
