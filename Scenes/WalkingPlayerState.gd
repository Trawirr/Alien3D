class_name WalkingPlayerState

extends State

@export var ANIMATION: AnimationPlayer
@export var TOP_ANIM_SPEED: float = 2.0

func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, Global.player.WALK_SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event):
	if event.is_action_pressed("sprint") and Global.player.is_on_floor():
		transition.emit("SprintingPlayerState")

func enter() -> void:
	ANIMATION.play("walking", -1.0, 1.0)
	Global.player._speed = Global.player.WALK_SPEED

func update(delta):
	set_animation_speed(Global.player.velocity.length())
	if Global.player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
