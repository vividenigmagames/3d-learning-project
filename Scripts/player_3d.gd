extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var move_speed := 20.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 40.0
@export var push_force := 80.0


var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

#Camera Variables
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
#Sprite Variable
@onready var _skin: SophiaSkin = %SophiaSkin
#Audio Stream Variables
@onready var playerWalkingAudioStream = %AudioStreamPlayer_Steps
@onready var playerJumpingAudioStream = %AudioStreamPlayer_Jump

#Func for camera movement using left click and cancel using esc
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#Func for allowing mouse sensitivity to respond accordingly
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	#Camera moverment and control to stop it from over rotating
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	#Variables for helping inputs always adjust to player direction, hitting w will always move player forward no matter which direction they are facing
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	#Defines move direction
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0 #helps offset downwards angle of camera, otherwise player would try and run down into the floor
	move_direction = move_direction.normalized()
	
	
	
	#Physics for moving character and setting up y offset for jumping code
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	move_and_slide()
	
	#Code for making player jump
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
		playerJumpingAudioStream.play()
	
	#Adds character model roation and smooths it out
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta) #lerp angle performs calculation for angles
	
	#Calling state machine for player
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()
		
	

	
