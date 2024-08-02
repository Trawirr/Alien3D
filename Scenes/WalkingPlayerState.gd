class_name WalkingPlayerState

extends State

func update(delta):
	print("walking update")
	if Global.player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
