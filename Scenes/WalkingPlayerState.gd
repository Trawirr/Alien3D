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

func enter() -> void:
	ANIMATION.play("walking", -1.0, 1.0)
	PLAYER._speed = PLAYER.WALK_SPEED

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
