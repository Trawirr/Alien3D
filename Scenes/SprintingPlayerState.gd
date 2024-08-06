class_name SprintingPlayerState

extends PlayerMovementState

@export var SPEED: float = 7.0
@export var ACCELERATION: float = 0.2
@export var DECELERATION: float = 0.4
@export var TOP_ANIM_SPEED: float = 4.0

func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, PLAYER.SPRINT_SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func enter(previous_state) -> void:
	ANIMATION.play("sprinting", 0.5, 1.0)
	PLAYER._speed = PLAYER.SPRINT_SPEED
	
func exit() -> void:
	ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())
	
	if Input.is_action_just_released("sprint") or PLAYER.velocity.length() == 0.0:
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 6.0 and PLAYER.is_on_floor():
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
