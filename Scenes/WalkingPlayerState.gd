class_name WalkingPlayerState

extends PlayerMovementState

@export var SPEED: float = 4.0
@export var ACCELERATION: float = 0.2
@export var DECELERATION: float = 0.4
@export var TOP_ANIM_SPEED: float = 2.0

func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, PLAYER.WALK_SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event):
	if event.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")

func enter(previous_state) -> void:
	ANIMATION.play("walking", -1.0, 1.0)
	PLAYER._speed = PLAYER.WALK_SPEED
	
func exit() -> void:
	ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
