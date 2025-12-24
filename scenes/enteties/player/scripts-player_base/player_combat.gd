@tool
extends "res://scenes/enteties/player/scripts-player_base/player_movement.gd"

## PlayerCombat - Handles combat stats, turn-based movement and actions

@export_group("Player Combat Stats")
@export var max_health: int = 100
@export var attack: int = 15
@export var defense: int = 10
@export var speed: int = 12

var stats: CombatantStats
var is_dead: bool = false
var is_my_turn: bool = false
var current_target: Node3D

@onready var movement_ring: MeshInstance3D = get_node_or_null("%MovementRadius")
@onready var floating_info: Node3D = get_node_or_null("%FloatingInfo")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	super._ready()
	_setup_stats()
	_setup_visuals()

func _setup_stats() -> void:
	stats = CombatantStats.new()
	stats.max_health = max_health
	stats.current_health = max_health
	stats.attack = attack
	stats.defense = defense
	stats.speed = speed
	stats.movement_range = speed * 0.5
	
	if not stats.damage_taken.is_connected(_on_damage_taken):
		stats.damage_taken.connect(_on_damage_taken)

func _setup_visuals() -> void:
	if floating_info and floating_info.has_method("setup"):
		floating_info.call("setup", stats)

func _on_damage_taken(_amount: int) -> void:
	if stats.current_health <= 0:
		die()

func die() -> void:
	if is_dead: return
	is_dead = true
	set_physics_process(false)
	
	# Visual fall over
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", -90, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Darken meshes
	_apply_dark_material(self)
	
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm and cm.has_method("on_combatant_death"):
		cm.on_combatant_death(self)

func _apply_dark_material(node: Node) -> void:
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
			dark_mat.albedo_color = Color(0.15, 0.15, 0.15)
			node.set_surface_override_material(i, dark_mat)
	for child in node.get_children():
		_apply_dark_material(child)

# --- Combat Turn Logic ---

func enter_combat() -> void:
	is_in_combat = true
	can_control = false # Wait for our turn to move
	if floating_info and floating_info.has_method("set_combat_mode"):
		floating_info.set_combat_mode(true)

func exit_combat() -> void:
	is_in_combat = false
	is_my_turn = false
	can_control = true # Restore normal movement
	if movement_ring:
		movement_ring.visible = false
	if floating_info and floating_info.has_method("set_combat_mode"):
		floating_info.set_combat_mode(false)

	_perform_attack_sequence(current_target)

func _start_turn_visuals() -> void:
	# 1. Movement Ring
	movement_limit_center = global_position
	movement_limit_radius = stats.movement_range
	if movement_ring:
		movement_ring.visible = true
		movement_ring.top_level = true
		movement_ring.global_position = movement_limit_center + Vector3(0, 0.1, 0)
		movement_ring.scale = Vector3(stats.movement_range, 1.0, stats.movement_range)
		
	# 2. Attack Ring (Red)
	if not attack_ring:
		_create_attack_ring()
	
	if attack_ring:
		attack_ring.visible = true
		attack_ring.top_level = false # Follow the player
		attack_ring.position = Vector3(0, 0.11, 0) # Local offset
		
		var atk_range: float = 2.0
		attack_ring.scale = Vector3(atk_range, 1.0, atk_range)

var attack_ring: MeshInstance3D

func _create_attack_ring() -> void:
	attack_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.98
	torus.outer_radius = 1.0
	attack_ring.mesh = torus
	
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1, 0, 0, 0.5) # Red
	mat.emission_enabled = true
	mat.emission = Color(1, 0, 0)
	attack_ring.material_override = mat
	
	# Add to self so it moves with us
	add_child(attack_ring)

func start_turn() -> void:
	is_my_turn = true
	can_control = true
	
	_start_turn_visuals()
		
	print(name, "'s turn!")
	# Additional turn-start logic here

func end_turn() -> void:
	is_my_turn = false
	can_control = false
	
	# Stop all movement immediately
	velocity = Vector3.ZERO
	if anim_tree:
		anim_tree.set("parameters/movement/transition_request", "idle")
	
	# Disable limit
	movement_limit_radius = -1.0
	
	if movement_ring:
		movement_ring.visible = false
	if attack_ring:
		attack_ring.visible = false
	
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm: cm.end_turn()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if is_in_combat and is_my_turn:
		_process_combat_input(delta)
	
	super._physics_process(delta)

# --- Input Handling ---

func _unhandled_input(event: InputEvent) -> void:
	if not is_in_combat or not is_my_turn:
		return
		
	if event.is_action_pressed("ui_focus_next"): # Tab
		cycle_target()
	elif event.is_action_pressed("attack"): # Use the "attack" action (e.g. R / Joystick Button 1)
		attack_target()
	elif event.is_action_pressed("end_turn"): # Use the "end_turn" action (e.g. Esc / Joystick Button 3)
		end_turn()

func cycle_target() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies") # Assuming enemies are in this group
	# Filter for alive enemies in combat
	var valid_targets: Array[Node] = []
	for e in enemies:
		if e.is_in_group("combatant") and not e.get("is_dead"):
			valid_targets.append(e)
			
	if valid_targets.is_empty():
		return
		
	# Find current index
	var index: int = valid_targets.find(current_target)
	if index == -1:
		index = 0
	else:
		index = (index + 1) % valid_targets.size()
		
	_set_new_target(valid_targets[index])

func _set_new_target(new_target: Node3D) -> void:
	# Disable old target indicator
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(false)
		
	current_target = new_target
	print("Targeted: ", current_target.name)
	
	# Enable new target indicator
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(true)

func attack_target() -> void:
	if is_attacking:
		return
		
	if not current_target:
		cycle_target() # Auto-target if none
		if not current_target:
			print("No target to attack!")
			return

	var dist: float = global_position.distance_to(current_target.global_position)
	# Strict attack range check (matching the visual ring)
	var required_range: float = 2.0
	
	if dist > required_range:
		print("Target too far! Move closer (Range: ", required_range, "m)")
		return
		
	_perform_attack_sequence(current_target)

var is_attacking: bool = false

func _perform_attack_sequence(target: Node3D) -> void:
	is_attacking = true
	can_control = false
	velocity = Vector3.ZERO
	
	print("Attacking ", target.name)
	
	# Rotate towards target
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	
	# Play animation
	if anim_tree:
		anim_tree.set("parameters/movement/transition_request", _get_attack_animation())
		
	# Wait for impact (adjust based on animation)
	await get_tree().create_timer(0.4).timeout
	
	# Deal damage
	if is_instance_valid(target) and target.has_method("get") and not target.get("is_dead"):
		# Try to get stats directly or use take_damage
		# Most combatants have a 'stats' property
		var t_stats: CombatantStats = target.get("stats")
		if t_stats and t_stats.has_method("take_damage"):
			t_stats.take_damage(stats.attack)
			print(name, " dealt ", stats.attack, " damage to ", target.name)
		elif target.has_method("take_damage"):
			target.take_damage(stats.attack)
			
	# Recovery time
	await get_tree().create_timer(0.6).timeout
	
	is_attacking = false
	end_turn()

# Override base movement animation logic to prevent overwriting attack animation
func _handle_rotation_and_animation(delta: float) -> void:
	if is_attacking:
		return # Do not change animation while attacking
	super._handle_rotation_and_animation(delta)

func _process_combat_input(_delta: float) -> void:
	# Keep movement from exploration for now, but ensure we don't move when attacking
	_update_raycast_targeting()

func _update_raycast_targeting() -> void:
	if is_attacking: return
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera: return
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	# Or center of screen if mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_pos = get_viewport().get_visible_rect().size / 2.0
		
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 100.0
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true # Optional, depending on enemy collision setup
	query.collide_with_bodies = true
	# Exclude self
	query.exclude = [self.get_rid()]
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var collider: Node = result["collider"]
		if collider.is_in_group("enemies") and collider.is_in_group("combatant"):
			if current_target != collider:
				_set_new_target(collider)

func _get_attack_animation() -> String: return "attack"
