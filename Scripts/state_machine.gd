class_name StateMachine

extends Node

@export var CURRENT_STATE: State
var states: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State: # has attached state.gd script
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")

	await owner.ready
	CURRENT_STATE.enter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug.add_property("Current state", CURRENT_STATE.name, 1)
	
func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	print("State machine / transition: ", new_state_name)
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter()
			CURRENT_STATE = new_state
	else:
		push_warning("State does not exist")
