@tool
extends CharacterBody3D

# --- Movement Exports ---
@export var wander_radius: float = 5.0 ## How far enemy wanders from spawn when idle

# --- Internal State (Movement) ---
var spawn_point: Vector3
var wander_timer: float = 0.0

# --- Node References ---
@onready var anim_tree: AnimationTree = get_node_or_null("AnimationTree")
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

# =============================================================================
# VIRTUAL FUNCTIONS - Override in child scripts for custom animations
# =============================================================================

## Override to return the walk animation state name
func _get_walk_animation() -> String:
	return "walk"

## Override to return the idle animation state name
func _get_idle_animation() -> String:
	return "idle"

## Override to return the fall animation state name
func _get_fall_animation() -> String:
	return "fall"

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	add_to_group("enemies")
	spawn_point = global_position

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Play fall animation
		if anim_tree:
			anim_tree.set("parameters/movement/transition_request", _get_fall_animation())

	# Child template method for overriding behavior
	_process_movement_logic(delta)
	
	move_and_slide()

# Virtual method for child classes to override logic (Combat vs Wander)
func _process_movement_logic(delta: float) -> void:
	_do_wander(delta)

# =============================================================================
# WANDER (Out of Combat)
# =============================================================================

func _do_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0:
		var angle: float = randf() * TAU
		var distance: float = randf() * wander_radius
		var target: Vector3 = spawn_point + Vector3(cos(angle), 0, sin(angle)) * distance
		var direction: Vector3 = (target - global_position).normalized()
		velocity.x = direction.x * 2.0
		velocity.z = direction.z * 2.0
		wander_timer = randf_range(2.0, 5.0)
	
	velocity.x = move_toward(velocity.x, 0, 0.1)
	velocity.z = move_toward(velocity.z, 0, 0.1)
	
	_handle_rotation_and_animation()

func _handle_rotation_and_animation() -> void:
	if not anim_tree:
		return
	
	# Always face the direction of horizontal movement (even when jumping)
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() > 0.1:
		var target_angle: float = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 0.1)
	
	# Only change animations when on the floor (fall animation handled in _physics_process)
	if not is_on_floor():
		return
	
	if horizontal_velocity.length() > 0.1:
		anim_tree.set("parameters/movement/transition_request", _get_walk_animation())
	else:
		anim_tree.set("parameters/movement/transition_request", _get_idle_animation())
