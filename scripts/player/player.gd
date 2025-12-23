class_name Player
extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $mesh/AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
var last_lean := 0.0

@export var base_speed := 10.0
const JUMP_VELOCITY = 13.5
@onready var camera: Node3D = $CameraRig/Camera3D

## Speed that the player is considered running
var run_speed := 3.5

## Default speed used to blend animations
const BLEND_SPEED := 0.2

## The current state that our player is in
var state: BasePlayerState = PlayerStates.IDLE

@export_group("Player Combat Stats")
@export var max_health: int = 100
@export var attack: int = 15
@export var defense: int = 10
@export var speed: int = 12

var stats: CombatantStats # Internal resource for combat system logic

func _ready() -> void:
	add_to_group("player")
	_setup_stats()
	setup_visuals()
	state.enter(self)

func _setup_stats() -> void:
	stats = CombatantStats.new()
	stats.max_health = max_health
	stats.current_health = max_health
	stats.attack = attack
	stats.defense = defense
	stats.speed = speed
	# Movement range is half of speed, matching enemy logic
	stats.movement_range = speed * 0.5
	
	if not stats.damage_taken.is_connected(_on_damage_taken):
		stats.damage_taken.connect(_on_damage_taken)

func _on_damage_taken(_amount: int) -> void:
	if stats.current_health <= 0:
		die()

var is_dead: bool = false

func die() -> void:
	if is_dead: return
	is_dead = true
	
	print("Player has died!")
	
	# Stop physics processing
	set_physics_process(false)
	velocity = Vector3.ZERO
	
	# Visuals: Fall over
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", -90, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Visuals: Darken
	_apply_dark_material($mesh) # Assuming mesh is the visual container
	
	# Notify Combat Manager
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm and cm.has_method("on_combatant_death"):
		cm.on_combatant_death(self)

func _apply_dark_material(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		print("Darkening mesh: ", mesh_node.name)
		
		# Determine surface count from mesh resource
		var surface_count: int = 0
		if mesh_node.mesh:
			surface_count = mesh_node.mesh.get_surface_count()
		
		# Apply a dark material override to each surface
		for i in range(surface_count):
			var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
			dark_mat.albedo_color = Color(0.15, 0.15, 0.15) # Very dark gray
			mesh_node.set_surface_override_material(i, dark_mat)
			print("Applied dark material to surface ", i, " on ", mesh_node.name)
	
	for child in node.get_children():
		_apply_dark_material(child)


func setup_visuals() -> void:
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("setup"):
		float_info.call("setup", stats)

func enter_combat() -> void:
	change_state_to(PlayerStates.COMBAT)
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(true)

func exit_combat() -> void:
	# Return to idle or walk depending on input
	change_state_to(PlayerStates.IDLE)
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(false)

func start_turn() -> void:
	if state == PlayerStates.COMBAT:
		state.start_turn(self)

## Changes the current player state and runs correct functions
func change_state_to(next_state: BasePlayerState) -> void:
	state.exit(self)
	state = next_state
	state.enter(self)

func _physics_process(delta: float) -> void:
	state.pre_update(self)
	state.update(self, delta)


func turn_to(direction: Vector3) -> void:
	if direction.length() > 0:
		var yaw := atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, .25)
		rotation.y = yaw
		
		
## Reads directional movement input for the player, adjusts it on the camera and returns it
func get_move_input() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	return direction
	
## Returns the players current speed
func get_current_speed() -> float:
	return velocity.length()
	
## Applies velocity based on directional movement input
func update_velocity_using_direction(direction: Vector3, target_speed: float = base_speed) -> void:
	if direction:
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)
#
