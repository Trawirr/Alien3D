extends CharacterBody3D

# movement vars
var _speed
@export var CROUCH_SPEED : float = 2.0
@export var WALK_SPEED : float = 5.0
@export var SPRINT_SPEED : float = 12.0
@export var JUMP_VELOCITY : float = 4.5
@export var _is_crouching : bool = false
@export_range(5, 10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0

# mouse movement
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input: float
var _player_rotation: Vector3
var _camera_rotation: Vector3
@export var TILT_LOWER_LIMIT = deg_to_rad(-90)
@export var TILT_UPPER_LIMIT = deg_to_rad(90)
@export var SENSITIVITY = 0.5;

# bob vars
const BOB_FREQUENCY = 2.0
const BOB_AMPLITUDE = 0.08
var t_bob = 0.0

# FOV
const FOV_BASE = 75.0
const FOV_MUL = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = 9.8

@export var CAMERA_CONTROLLER : Node3D # = $CameraController
@export var CAMERA : Camera3D # = $CameraController/Camera
@export var ANIMATION_PLAYER : AnimationPlayer # = $AnimationPlayer
@export var CROUCH_SHAPECAST : ShapeCast3D

func set_movement_speed(state : String):
	match state:
		"walk":
			_speed = WALK_SPEED
		"crouch":
			_speed = CROUCH_SPEED
		"sprint":
			_speed = SPRINT_SPEED

func toggle_crouch():
	if !_is_crouching:
		ANIMATION_PLAYER.play("crouch", -1, CROUCH_ANIMATION_SPEED)
	elif CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATION_PLAYER.play("crouch", -1, -CROUCH_ANIMATION_SPEED, true)

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_movement_speed("walk")
	
	CROUCH_SHAPECAST.add_exception($".")
	
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("crouch") and is_on_floor():
		toggle_crouch()
	if event.is_action_released("crouch") and is_on_floor():
		toggle_crouch()
	
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * SENSITIVITY
		_tilt_input = -event.relative.y * SENSITIVITY

func _physics_process(delta):
	Global.debug.add_property("Movement speed", _speed, 1)
	
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		#print("gravity: ", velocity.y, ", delta: ", delta)
		
	# Camera rotation
	_update_camera(delta)
		
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and !_is_crouching:
		print("jump")
		velocity.y = JUMP_VELOCITY
		
	# Handle sprint
	
	if Input.is_action_pressed("sprint") and is_on_floor():
		set_movement_speed("sprint")
	else:
		set_movement_speed("walk")
		
	# Get the input direction and handle the movement/acceleration
	# As good practice, you should replace UI actions with custom gameplay actions
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#print("direciton: ", direction)
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * _speed
			velocity.z = direction.z * _speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * _speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * _speed, delta * 2.0)
		
	# head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	CAMERA.transform.origin = _headbob(t_bob)
	#print(t_bob, " ", CAMERA.transform.origin)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = FOV_BASE + FOV_MUL * velocity_clamped
	CAMERA.fov = lerp(CAMERA.fov, target_fov, delta * 10.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos

func _on_animation_player_animation_started(anim_name):
	if anim_name == "crouch":
		_is_crouching = !_is_crouching
		if _is_crouching:
			set_movement_speed("crouch")
		else:
			set_movement_speed("walk")
