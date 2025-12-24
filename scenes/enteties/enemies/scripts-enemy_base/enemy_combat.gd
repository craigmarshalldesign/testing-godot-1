@tool
extends "res://scenes/enteties/enemies/scripts-enemy_base/enemy_movement.gd"

# --- Exposed Stats (Edit in Inspector) ---
@export_group("Base Enemy Stats")
@export var base_health: int
@export var base_attack: int
@export var base_defense: int
@export var base_speed: int

func _init() -> void:
	# Defaults should be set by child classes (e.g. SkeletonWarrior)
	pass

@export_group("Combat Settings")
@export var attack_range: float = 2.1 ## How close to player to trigger attack
@export var attack_damage_delay: float = 0.4 ## Seconds into attack animation before damage is dealt
@export var hit_radius: float = 0.5 ## The physical size of this unit for incoming attacks

@export_group("Detection Settings")
@export var detection_range: float = 10.0 ## Distance to spot player and START combat
@export var join_combat_range: float = 15.0 ## Distance to join an EXISTING combat

# --- Internal State ---
var stats: CombatantStats
var is_moving_on_turn: bool = false
var stuck_timer: float = 0.0
var move_target_pos: Vector3 = Vector3.ZERO
var jump_cooldown: float = 0.0
var turn_start_time_ms: int = 0
var last_target_distance: float = 0.0
var combat_turn_start_pos: Vector3 = Vector3.ZERO
var is_dead: bool = false
var is_acting: bool = false

# --- Node References ---
@onready var float_info: Node3D = get_node_or_null("%FloatingInfo")
@onready var movement_radius_ring: MeshInstance3D = get_node_or_null("%MovementRadius")

# =============================================================================
# VIRTUAL FUNCTIONS - Override in child scripts
# =============================================================================

func _configure_stats() -> void:
	pass

func _get_attack_animation() -> String:
	return "attack"

func _setup_enemy_visuals() -> void:
	pass

func _get_mesh_node() -> Node3D:
	return null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		_configure_stats()
		return
	
	super._ready() # Calls EnemyMovement._ready()
	
	_setup_stats()
	_setup_enemy_visuals()
	_setup_floating_info()
	_print_stats()

func _setup_stats() -> void:
	if not stats:
		stats = CombatantStats.new()
	
	# Apply base stats with +/- 3 randomization for uniqueness
	stats.max_health = base_health + randi_range(-3, 3)
	stats.current_health = stats.max_health
	stats.attack = base_attack + randi_range(-3, 3)
	stats.defense = base_defense + randi_range(-3, 3)
	stats.speed = base_speed + randi_range(-3, 3)
	stats.movement_range = stats.speed * 0.5
	
	if not stats.damage_taken.is_connected(_on_damage_taken):
		stats.damage_taken.connect(_on_damage_taken)

func _setup_floating_info() -> void:
	if float_info and float_info.has_method("setup"):
		float_info.call("setup", stats)

func _print_stats() -> void:
	print("--- STATS: ", name, " ---")
	print("HP: ", stats.current_health, "/", stats.max_health)
	print("ATK: ", stats.attack, " | DEF: ", stats.defense, " | SPD: ", stats.speed)
	print("---------------------------")

func _on_damage_taken(_amount: int) -> void:
	if stats.current_health <= 0:
		die()

# =============================================================================
# PHYSICS OVERRIDE
# =============================================================================

func _process_movement_logic(delta: float) -> void:
	if is_dead:
		return
	
	# Check for combat initiation
	_check_for_player_combat()
	
	if is_in_group("combatant"):
		var combat_manager: Node = get_node_or_null("/root/CombatManager")
		var active_combatant: Node = null
		if combat_manager:
			active_combatant = combat_manager.get("current_combatant")
		
		if active_combatant != self:
			velocity.x = 0
			velocity.z = 0
		else:
			if is_moving_on_turn:
				_handle_turn_movement(delta)
			else:
				velocity.x = 0
				velocity.z = 0
				
		if not is_acting:
			_handle_rotation_and_animation()
	else:
		super._process_movement_logic(delta) # Do Wander

# =============================================================================
# COMBAT INTEGRATION
# =============================================================================

var current_combat_target: Node3D = null

const TargetingSystemComp = preload("res://scenes/combat/scripts-combat/targeting_system.gd")

func _check_for_player_combat() -> void:
	# Use TargetingSystem to check detection
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var best_target: Node3D = TargetingSystemComp.find_closest_target(self, players)
	
	if not best_target:
		return
	
	var dist: float = global_position.distance_to(best_target.global_position)
	
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	if not combat_manager:
		return
	
	if combat_manager.is_combat_active:
		if not is_in_group("combatant") and dist < join_combat_range:
			combat_manager.join_combat(self)
	else:
		if dist < detection_range:
			combat_manager.start_combat(best_target, self)


func enter_combat() -> void:
	add_to_group("combatant")
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(true)

func set_targeted(active: bool) -> void:
	if float_info and float_info.has_method("set_targeted"):
		float_info.set_targeted(active)


func exit_combat() -> void:
	if is_dead:
		return
	remove_from_group("combatant")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(false)
	
	current_combat_target = null
	# Reset movement vars
	wander_timer = 0.0
	velocity = Vector3.ZERO

func start_turn() -> void:
	if Engine.is_editor_hint():
		return
	
	print("Enemy Turn: ", name)
	combat_turn_start_pos = global_position
	turn_start_time_ms = Time.get_ticks_msec()
	last_target_distance = 9999.0
	
	# Movement Range Indicator
	var move_ring: MeshInstance3D = get_node_or_null("MoveRangeIndicator")
	if not move_ring:
		move_ring = MeshInstance3D.new()
		move_ring.name = "MoveRangeIndicator"
		var torus := TorusMesh.new()
		torus.inner_radius = 0.98
		torus.outer_radius = 1.0
		move_ring.mesh = torus
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1, 0.5, 0, 0.3)
		mat.emission_enabled = true
		mat.emission = Color(1, 0.5, 0)
		move_ring.material_override = mat
		add_child(move_ring)
	
	move_ring.visible = true
	move_ring.top_level = true
	move_ring.global_position = combat_turn_start_pos + Vector3(0, 0.05, 0)
	var ms: float = stats.movement_range
	move_ring.scale = Vector3(ms, 1.0, ms)
	
	# Attack Range Indicator
	if movement_radius_ring:
		movement_radius_ring.visible = true
		movement_radius_ring.top_level = false
		movement_radius_ring.position = Vector3(0, 0.1, 0)
		movement_radius_ring.scale = Vector3(attack_range, 1.0, attack_range)
	
	# --- TARGETING LOGIC ---
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	current_combat_target = TargetingSystemComp.find_best_target(self, players)
	
	if not current_combat_target:
		print(name, " has no valid targets. Ending turn.")
		_end_enemy_turn()
		return
		
	print(name, " targets ", current_combat_target.name)
	
	# Calculate and clamp target
	var best_pos: Vector3 = _get_attack_slot_pos(current_combat_target)
	var dist_budget: float = stats.movement_range
	
	if best_pos.distance_to(combat_turn_start_pos) > dist_budget:
		var dir_to_best: Vector3 = (best_pos - combat_turn_start_pos).normalized()
		move_target_pos = combat_turn_start_pos + dir_to_best * dist_budget
	else:
		move_target_pos = best_pos
	
	var dist_to_player: float = global_position.distance_to(current_combat_target.global_position)
	
	stuck_timer = 0.0
	jump_cooldown = 0.0
	last_target_distance = global_position.distance_to(move_target_pos)
	
	if dist_to_player > attack_range:
		is_moving_on_turn = true
		if nav_agent:
			nav_agent.target_position = move_target_pos
	else:
		_perform_enemy_attack()

func _get_attack_slot_pos(target: Node3D) -> Vector3:
	var p_pos: Vector3 = target.global_position
	var cm: Node = get_node_or_null("/root/CombatManager")
	var my_idx: int = 0
	if cm:
		my_idx = cm.combatants.find(self)
	
	# Using index to fan out attackers so they don't clip inside each other
	var angle: float = my_idx * 1.5
	var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * (attack_range - 0.5)
	
	# If offset pushes us into a wall, might need raycast check here but keeping simple for now
	return p_pos + offset

# =============================================================================
# TURN MOVEMENT LOGIC
# =============================================================================

func _handle_turn_movement(delta: float) -> void:
	if jump_cooldown > 0:
		jump_cooldown -= delta
	
	# Re-validate target just in case
	if not is_instance_valid(current_combat_target) or current_combat_target.get("is_dead"):
		_end_move_and_decide()
		return
	
	var current_pos: Vector3 = global_position
	var dist_to_player: float = current_pos.distance_to(current_combat_target.global_position)
	var dist_to_target: float = current_pos.distance_to(move_target_pos)
	
	# 1. ATTACK PRIORITY - Only if on ground
	if dist_to_player <= attack_range and is_on_floor():
		_perform_enemy_attack()
		return
	
	# 2. ARRIVAL CHECK
	if dist_to_target < 1.2:
		print(name, " arrived at target.")
		_end_move_and_decide()
		return
	
	# 3. RADIUS LEASH
	if current_pos.distance_to(combat_turn_start_pos) > stats.movement_range + 0.5:
		_end_move_and_decide()
		return
	
	# 4. STUCK DETECTION
	if Time.get_ticks_msec() - turn_start_time_ms > 500:
		var current_dist: float = current_pos.distance_to(move_target_pos)
		
		if current_dist >= last_target_distance - 0.05:
			stuck_timer += delta
		else:
			stuck_timer = 0.0
			last_target_distance = current_dist
		
		if stuck_timer > 0.4 and is_on_floor() and jump_cooldown <= 0:
			velocity.y = 10
			jump_cooldown = 0.5
			stuck_timer = 0.2
			print(name, " panic/stuck jump!")
		
		if stuck_timer > 1.5:
			print(name, " stuck (no progress), ending turn.")
			_end_move_and_decide()
			return
	
	# 5. MOVEMENT
	var next_pos: Vector3 = move_target_pos
	
	if nav_agent:
		if not nav_agent.is_target_reached():
			next_pos = nav_agent.get_next_path_position()
			# Simple smoothing near goal
			if next_pos.distance_to(current_pos) < 0.5 and dist_to_target > 1.0:
				next_pos = move_target_pos
	
	var dir: Vector3 = (next_pos - current_pos).normalized()
	dir.y = 0
	
	if dir.length_squared() < 0.001 and dist_to_target > 1.0:
		dir = (move_target_pos - current_pos).normalized()
		dir.y = 0
	
	dir = dir.normalized()
	
	# Repulsion
	var repulsion: Vector3 = Vector3.ZERO
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or other.get("is_dead"):
			continue
		var diff: Vector3 = global_position - other.global_position
		if diff.length() < 0.8:
			repulsion += diff.normalized()
	
	var target_vel_x: float = (dir.x + repulsion.x) * 4.0
	var target_vel_z: float = (dir.z + repulsion.z) * 4.0
	
	velocity.x = move_toward(velocity.x, target_vel_x, 60.0 * delta)
	velocity.z = move_toward(velocity.z, target_vel_z, 60.0 * delta)
	
	# 6. PROACTIVE JUMPING
	# Using 0.5 as generic jump threshold
	if is_on_floor() and jump_cooldown <= 0:
		if is_on_wall():
			velocity.y = 10
			jump_cooldown = 0.5
			stuck_timer = 0.0
			print(name, " wall jump!")
		elif next_pos.y > current_pos.y + 0.5:
			velocity.y = 10
			jump_cooldown = 0.5

func _end_move_and_decide() -> void:
	is_moving_on_turn = false
	velocity.x = 0
	velocity.z = 0
	
	var timeout: float = 2.0
	while not is_on_floor() and timeout > 0:
		await get_tree().process_frame
		timeout -= get_process_delta_time()
	
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	
	await get_tree().create_timer(0.2).timeout
	
	if not is_instance_valid(current_combat_target) or current_combat_target.get("is_dead"):
		_end_enemy_turn()
		return
		
	if global_position.distance_to(current_combat_target.global_position) <= attack_range + 0.5:
		_perform_enemy_attack()
	else:
		_end_enemy_turn()

# =============================================================================
# ATTACK
# =============================================================================

func _perform_enemy_attack() -> void:
	is_moving_on_turn = false
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	
	# Face player
	is_acting = true
	if is_instance_valid(current_combat_target):
		var look_target: Vector3 = current_combat_target.global_position
		var dir: Vector3 = (look_target - global_position).normalized()
		# Face the player
		var target_angle: float = atan2(dir.x, dir.z)
		rotation.y = target_angle
	
	# Wind up
	await get_tree().create_timer(0.5).timeout
	
	if not combat_manager or not combat_manager.is_combat_active:
		return
	
	# Play attack animation
	var attack_anim: String = _get_attack_animation()
	anim_tree.set("parameters/movement/transition_request", attack_anim)
	print(name, " attacks with: ", attack_anim)
	
	# Wait for impact
	await get_tree().create_timer(attack_damage_delay).timeout
	
	if not combat_manager or not combat_manager.is_combat_active:
		return
	
	# Deal damage
	if is_instance_valid(current_combat_target):
		var player_stats: CombatantStats = current_combat_target.get("stats")
		if player_stats and not current_combat_target.get("is_dead"):
			player_stats.take_damage(stats.attack)
			print(name, " deals ", stats.attack, " damage to ", current_combat_target.name)
	
	# Recovery
	await get_tree().create_timer(1.0).timeout
	
	is_acting = false
	
	if not combat_manager or not combat_manager.is_combat_active:
		return
	
	_end_enemy_turn()

func _end_enemy_turn() -> void:
	velocity = Vector3.ZERO
	
	if movement_radius_ring:
		movement_radius_ring.visible = false
	
	var move_ring: MeshInstance3D = get_node_or_null("MoveRangeIndicator")
	if move_ring:
		move_ring.visible = false
	
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	if combat_manager:
		combat_manager.end_turn()

# =============================================================================
# DEATH
# =============================================================================

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	print(name, " has died!")
	
	velocity = Vector3.ZERO
	set_physics_process(false)
	
	if anim_tree:
		anim_tree.active = false
	
	# Fall over animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 90, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Darken mesh
	var mesh_node: Node3D = _get_mesh_node()
	if mesh_node:
		_apply_dark_material(mesh_node)
	
	# Disable collision
	var col: CollisionShape3D = get_node_or_null("CollisionShape3D")
	if col:
		col.disabled = true
	
	# Remove from groups
	remove_from_group("combatant")
	remove_from_group("enemies")
	
	# Hide health bar
	if float_info:
		float_info.visible = false
	
	# Notify manager
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm and cm.has_method("on_combatant_death"):
		cm.on_combatant_death(self)
	
	# Despawn corpse after 30 seconds
	await get_tree().create_timer(30.0).timeout
	queue_free()

func _apply_dark_material(node: Node) -> void:
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
			dark_mat.albedo_color = Color(0.15, 0.15, 0.15)
			# Copy emission if needed or just disable it
			dark_mat.emission_enabled = false
			node.set_surface_override_material(i, dark_mat)
	
	for child in node.get_children():
		_apply_dark_material(child)
