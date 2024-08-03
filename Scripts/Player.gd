class_name Player extends CharacterBody3D

# movement vars
var _speed
@export var CROUCH_SPEED : float = 2.0
@export var WALK_SPEED : float = 4.0
@export var SPRINT_SPEED : float = 7.0
@export var JUMP_VELOCITY : float = 4.5
@export var ACCELERATION : float = 0.2
@export var DECELERATION : float = 0.4

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
			
func update_gravity(delta: float) -> void:
	velocity.y -= gravity * delta
	
func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#if is_on_floor():
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * _speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	#else:
		#velocity.x = lerp(velocity.x, direction.x * _speed, delta * 2.0)
		#velocity.z = lerp(velocity.z, direction.z * _speed, delta * 2.0)
	
func update_velocity() -> void:
	move_and_slide()

func _update_camera(delta: float) -> void:
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
	Global.player = self
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_movement_speed("walk")
	
	CROUCH_SHAPECAST.add_exception($".")
	
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * SENSITIVITY
		_tilt_input = -event.relative.y * SENSITIVITY

func _physics_process(delta):
	Global.debug.add_property("Movement speed", _speed, 1)
	Global.debug.add_property("Velocity", "%.2f" % velocity.length(), 2)
	
	# Camera rotation
	_update_camera(delta)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = FOV_BASE + FOV_MUL * velocity_clamped
	CAMERA.fov = lerp(CAMERA.fov, target_fov, delta * 10.0)
	
	move_and_slide()
