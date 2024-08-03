class_name SprintingPlayerState

extends State

@export var ANIMATION: AnimationPlayer
@export var TOP_ANIM_SPEED: float = 4.0

func set_animation_speed(speed):
	print(speed, " | ", 0.0, " | ", Global.player.SPRINT_SPEED, " | ", 0.0, " | ", 1.0)
	var alpha = remap(speed, 0.0, Global.player.SPRINT_SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
	print("sprinting animation speed: ", ANIMATION.speed_scale, ", alpha: ", alpha)

func _input(event) -> void:
	if event.is_action_released("sprint"):
		transition.emit("WalkingPlayerState")

func enter() -> void:
	ANIMATION.play("sprinting", 0.5, 1.0)
	Global.player._speed = Global.player.SPRINT_SPEED

func update(delta):
	set_animation_speed(Global.player.velocity.length())
