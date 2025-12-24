@tool
extends CharacterBody3D

## PlayerMovement - Handles physics, gravity, and exploration movement

@export_group("Movement Settings")
@export var base_speed: float = 10.0
@export var jump_velocity: float = 13.5
@export var rotation_speed: float = 12.0

@onready var anim_tree: AnimationTree = get_node_or_null("AnimationTree")

# Internal state
var is_in_combat: bool = false
var can_control: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	# Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# State-specific movement logic
	_process_movement_input(delta)
	
	move_and_slide()
	
	# Apply Movement Limits (if active)
	if movement_limit_radius > 0:
		var dist: float = global_position.distance_to(movement_limit_center)
		if dist > movement_limit_radius:
			var dir: Vector3 = (global_position - movement_limit_center).normalized()
			global_position = movement_limit_center + dir * movement_limit_radius
			# Stop velocity if moving outward
			# Simple way: just zero velocity to prevent sliding further
			velocity = Vector3.ZERO
	
	# Handle visuals
	_handle_rotation_and_animation(delta)

# Movement limiting
var movement_limit_center: Vector3 = Vector3.ZERO
var movement_limit_radius: float = -1.0


func _process_movement_input(_delta: float) -> void:
	# In combat, only move if it's our turn; otherwise normal exploration
	if not can_control:
		return
		
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	var direction := Vector3.ZERO
	if camera:
		direction = (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y))
		direction.y = 0
		direction = direction.normalized() * input_dir.length()
	
	if direction:
		velocity.x = direction.x * base_speed
		velocity.z = direction.z * base_speed
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed)
		velocity.z = move_toward(velocity.z, 0, base_speed)
	
	# Jump handling
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _handle_rotation_and_animation(_delta: float) -> void:
	if not anim_tree:
		return
		
	# Handle Rotation based on movement
	var horizontal_vel: Vector3 = Vector3(velocity.x, 0, velocity.z)
	if horizontal_vel.length() > 0.1:
		var target_angle: float = atan2(-velocity.x, -velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * _delta)
	
	# Handle Animations
	if not is_on_floor():
		anim_tree.set("parameters/movement/transition_request", _get_fall_animation())
	elif horizontal_vel.length() > 0.1:
		anim_tree.set("parameters/movement/transition_request", _get_walk_animation())
	else:
		anim_tree.set("parameters/movement/transition_request", _get_idle_animation())

# Virtual methods for animation states
func _get_idle_animation() -> String: return "idle"
func _get_walk_animation() -> String: return "walk"
func _get_fall_animation() -> String: return "fall"
