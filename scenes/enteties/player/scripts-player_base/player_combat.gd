@tool
extends "res://scenes/enteties/player/scripts-player_base/player_movement.gd"

## PlayerCombat - Handles combat stats, turn-based movement and actions

@export_group("Player Stats")
@export var base_health: int
@export var base_attack: int
@export var base_defense: int
@export var base_speed: int

@export_group("Combat Settings")
@export var attack_range: float = 2.0
@export var attack_damage_delay: float = 0.4
@export var hit_radius: float = 0.5 ## The physical size of this unit for incoming attacks

var stats: CombatantStats
var is_dead: bool = false
var is_my_turn: bool = false
var current_target: Node3D

@onready var movement_ring: MeshInstance3D = get_node_or_null("%MovementRadius")
@onready var floating_info: Node3D = get_node_or_null("%FloatingInfo")

func _init() -> void:
	# Defaults should be set by child classes (e.g. CharacterA)
	pass

func _ready() -> void:
	if Engine.is_editor_hint():
		_configure_stats()
		return
	super._ready()
	_setup_stats()
	_setup_visuals()

func _configure_stats() -> void:
	pass

func _setup_stats() -> void:
	print("[Stats] Setting up stats for ", name, ": HP=", base_health, " Atk=", base_attack)
	stats = CombatantStats.new()
	stats.max_health = base_health
	stats.current_health = base_health
	stats.attack = base_attack
	stats.defense = base_defense
	stats.speed = base_speed
	stats.movement_range = base_speed * 0.5
	
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
	
	if anim_tree:
		anim_tree.active = false
	
	# Hide health bar / FloatingInfo
	if floating_info:
		floating_info.visible = false
	
	# Visual fall over
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", -90, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Disable collision
	if has_node("CollisionShape3D"):
		get_node("CollisionShape3D").disabled = true
	
	# Darken meshes
	_apply_dark_material(self)
	
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm and cm.has_method("on_combatant_death"):
		cm.on_combatant_death(self)
	
	# Despawn corpse after 30 seconds
	await get_tree().create_timer(30.0).timeout
	if is_dead: # Only delete if still dead (not revived)
		queue_free()

func revive() -> void:
	if not is_dead:
		# Just heal if alive
		stats.current_health = stats.max_health
		if floating_info and floating_info.has_method("update_bar"):
			floating_info.update_bar(stats.current_health, stats.max_health)
		return
		
	print(name, " is being revived!")
	is_dead = false
	stats.current_health = stats.max_health
	
	# Restore physics
	set_physics_process(true)
	if has_node("CollisionShape3D"):
		get_node("CollisionShape3D").disabled = false
	
	# Restore visuals
	if anim_tree:
		anim_tree.active = true
		anim_tree.set("parameters/movement/transition_request", "idle")
	
	# Reset rotation (undo the fall)
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Remove dark material
	_remove_dark_material(self)
	
	# Show UI
	if floating_info:
		floating_info.visible = true
		if floating_info.has_method("update_bar"):
			floating_info.update_bar(stats.current_health, stats.max_health)
	
	# Ensure turn state is clear
	is_my_turn = false
	is_attacking = false
	can_control = true # Will be managed by PartyManager

func _remove_dark_material(node: Node) -> void:
	if node is MeshInstance3D:
		# Clear overrides to restore original materials
		for i in range(node.mesh.get_surface_count()):
			node.set_surface_override_material(i, null)
			
	for child in node.get_children():
		_remove_dark_material(child)

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
	is_attacking = false
	if movement_ring:
		movement_ring.visible = false
	if floating_info and floating_info.has_method("set_combat_mode"):
		floating_info.set_combat_mode(false)

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
		
		# Use the stat-driven range
		var atk_range: float = attack_range
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
	
	# Only disable control if we are still in combat.
	# If the turn ended because combat finished, we want to keep control.
	if is_in_combat:
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
	
	# Clear target visuals
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(false)
	current_target = null
	
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm: cm.end_turn()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if is_in_combat and is_my_turn:
		_process_combat_input(delta)
	
	super._physics_process(delta)

# --- Input Handling & Targeting ---

func _unhandled_input(event: InputEvent) -> void:
	if not is_in_combat or not is_my_turn:
		return
		
	if event.is_action_pressed("ui_focus_next"): # Tab
		cycle_target()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("target_left"):
		_select_target_directional(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("target_right"):
		_select_target_directional(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("attack"):
		attack_target()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("end_turn"):
		end_turn()
		get_viewport().set_input_as_handled()

# Original cycle_target (deprecated or fallback)
func cycle_target() -> void:
	# Default to "Right" cycle behavior
	_select_target_directional(1)

func _select_target_directional(direction: int) -> void:
	# 1. Gather Valid Targets (Enemies in 12m)
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var valid_targets: Array[Node3D] = []
	
	for e in enemies:
		if e.is_in_group("combatant") and not e.get("is_dead"):
			var dist: float = global_position.distance_to(e.global_position)
			if dist <= 12.0:
				valid_targets.append(e)
	
	if valid_targets.is_empty():
		return

	# 2. Sort targets by Screen X position (Left to Right)
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera: return
	
	valid_targets.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		var pos_a: Vector2 = camera.unproject_position(a.global_position)
		var pos_b: Vector2 = camera.unproject_position(b.global_position)
		return pos_a.x < pos_b.x
	)
	
	# 3. Select Target
	if not current_target or current_target not in valid_targets:
		# If no target or target is invalid/out of range, pick the one closest to screen center (or closest distance)
		# For "snappiness", user asked to pick "closest" initially.
		_select_nearest_target(valid_targets)
	else:
		# Cycle index
		var index: int = valid_targets.find(current_target)
		var new_index: int = (index + direction) % valid_targets.size()
		if new_index < 0:
			new_index = valid_targets.size() - 1
		
		_set_new_target(valid_targets[new_index])

func _select_nearest_target(candidates: Array[Node3D]) -> void:
	if candidates.is_empty(): return
	
	var closest: Node3D = candidates[0]
	var min_dist: float = global_position.distance_to(closest.global_position)
	
	for i in range(1, candidates.size()):
		var d: float = global_position.distance_to(candidates[i].global_position)
		if d < min_dist:
			closest = candidates[i]
			min_dist = d
			
	_set_new_target(closest)

func _set_new_target(new_target: Node3D) -> void:
	# Disable old target indicator
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(false)
		
	current_target = new_target
	
	if current_target:
		print("Targeted: ", current_target.name)
		# Enable new target indicator
		if current_target.has_method("set_targeted"):
			current_target.set_targeted(true)
	else:
		print("Target cleared.")

func attack_target() -> void:
	if is_attacking:
		return
		
	if not current_target:
		# Try to auto-select nearest if trying to attack with no target
		_select_target_directional(1)
		if not current_target:
			print("No target to attack!")
			return

	var dist: float = global_position.distance_to(current_target.global_position)
	
	# Subtract target's hit radius if it exists for "Edge-to-Edge" distance
	var safe_dist: float = dist
	if current_target.get("hit_radius"):
		safe_dist -= current_target.get("hit_radius")
	elif current_target.has_method("get_hit_radius"): # Optional getter support
		safe_dist -= current_target.get_hit_radius()
	
	# Strict attack range check
	if safe_dist > attack_range:
		print("Target too far! Move closer (Dist: ", snapped(safe_dist, 0.1), "m, Range: ", attack_range, "m)")
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

func _process_combat_input(delta: float) -> void:
	# Keep movement from exploration for now, but ensure we don't move when attacking
	_check_target_range_break()
	_update_movement_targeting(delta)
	_update_raycast_targeting()

func _check_target_range_break() -> void:
	if not current_target:
		return
	var dist: float = global_position.distance_to(current_target.global_position)
	if dist > 12.0:
		_set_new_target(null)

func _update_movement_targeting(_delta: float) -> void:
	if is_attacking: return
	
	# Only target if moving significantly
	if velocity.length() < 1.0:
		return
		
	var move_dir: Vector3 = velocity.normalized()
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	
	var best_candidate: Node3D = null
	var best_dot: float = 0.5 # Minimum 45-60 degree cone
	
	for e in enemies:
		if e.is_in_group("combatant") and not e.get("is_dead"):
			var dist: float = global_position.distance_to(e.global_position)
			if dist <= 12.0:
				var dir_to_e: Vector3 = (e.global_position - global_position).normalized()
				var dot: float = move_dir.dot(dir_to_e)
				
				# Priority score: Dot product mostly, but distance matters slightly
				# We want "walking towards", so Dot is king.
				if dot > best_dot:
					best_candidate = e
					best_dot = dot
	
	# Soft lock: Only switch if we found a better candidate that is NOT the current target
	if best_candidate and best_candidate != current_target:
		_set_new_target(best_candidate)

var _last_mouse_pos: Vector2 = Vector2.ZERO

func _update_raycast_targeting() -> void:
	if is_attacking: return
	
	# Only raycast if mouse has MOVED significantly to prevent overriding controller input
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	if mouse_pos.distance_squared_to(_last_mouse_pos) < 4.0: # Tiny threshold
		return
	_last_mouse_pos = mouse_pos
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera: return
	
	# Or center of screen if mouse is captured (ignore move check if captured)
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
