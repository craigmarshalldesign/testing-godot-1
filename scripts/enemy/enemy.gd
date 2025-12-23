@tool
extends CharacterBody3D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var mesh: Node3D = $mesh
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

@export_group("Base Enemy Stats")
@export var base_health: int = 85
@export var base_attack: int = 50
@export var base_defense: int = 8
@export var base_speed: int = 10

var stats: CombatantStats # Internal resource for combat system logic

var spawn_point: Vector3
var wander_radius: float = 5.0
var wander_timer: float = 0.0
var is_moving_on_turn: bool = false
var stuck_timer: float = 0.0
var move_target_pos: Vector3 = Vector3.ZERO
var jump_cooldown: float = 0.0
var turn_start_time_ms: int = 0
var last_target_distance: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		setup_visuals()
		return
		
	add_to_group("enemies") # Ensure group membership
	spawn_point = global_position
	setup_stats()
	# Moved setup_visuals call here (it was accidentally removed or mispositioned)
	setup_visuals()

func setup_stats() -> void:
	# Create the internal stats resource if it doesn't exist
	if not stats:
		stats = CombatantStats.new()
	
	# Apply Base Stats with a +/- 3 randomization for uniqueness
	stats.max_health = base_health + randi_range(-3, 3)
	stats.current_health = stats.max_health
	stats.attack = base_attack + randi_range(-3, 3)
	stats.defense = base_defense + randi_range(-3, 3)
	stats.speed = base_speed + randi_range(-3, 3)
	
	# Keep movement_range calculated from the finalized speed
	stats.movement_range = stats.speed * 0.5
	
	if not stats.damage_taken.is_connected(_on_damage_taken):
		stats.damage_taken.connect(_on_damage_taken)

func _on_damage_taken(_amount: int) -> void:
	if stats.current_health <= 0:
		die()

func setup_visuals() -> void:
	# Make it half size
	scale = Vector3(0.5, 0.5, 0.5)
	
	# Try to find the mesh and make it red
	if mesh:
		# Fix import orientation (faces wrong way by default)
		mesh.rotation_degrees.y = 180
		_apply_red_material(mesh)
		
	# Add HP bar and setup signals
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("setup"):
		float_info.call("setup", stats)
	
	# Print stats as requested (only once in _ready)
	if not Engine.is_editor_hint() and stats:
		print("--- STATS: ", name, " ---")
		print("HP: ", stats.current_health, "/", stats.max_health)
		print("ATK: ", stats.attack, " | DEF: ", stats.defense, " | SPD: ", stats.speed)
		print("---------------------------")

func _apply_red_material(node: Node) -> void:
	if node is MeshInstance3D:
		var mat_count: int = node.get_surface_override_material_count()
		for i in range(mat_count):
			var red_mat: StandardMaterial3D = StandardMaterial3D.new()
			red_mat.albedo_color = Color.RED
			node.set_surface_override_material(i, red_mat)
	
	for child in node.get_children():
		_apply_red_material(child)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Proximity check for combat
	check_for_player_combat()

	# Logic based on state
	if is_in_group("combatant"):
		# In combat, we don't wander randomly
		var combat_manager: Node = get_node_or_null("/root/CombatManager")
		var active_combatant: Node = null
		if combat_manager: active_combatant = combat_manager.get("current_combatant")
		
		if active_combatant != self:
			velocity.x = 0
			velocity.z = 0
			# If we're on the floor and it's not our turn, don't move_and_slide
			if is_on_floor():
				velocity.y = 0
				return
		else:
			if is_moving_on_turn:
				_handle_turn_movement(delta)
			else:
				# Not moving, just sliding for gravity
				velocity.x = 0
				velocity.z = 0
	else:
		do_wander(delta)
	
	move_and_slide()

func _handle_turn_movement(delta: float) -> void:
	if jump_cooldown > 0:
		jump_cooldown -= delta

	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player or player.is_dead:
		_end_move_and_decide()
		return
		
	var current_pos: Vector3 = global_position
	var dist_to_player: float = current_pos.distance_to(player.global_position)
	var dist_to_target: float = current_pos.distance_to(move_target_pos)
	
	# --- 1. ATTACK PRIORITY ---
	# Only attack if on the ground (prevent mid-air attacks)
	if dist_to_player <= 2.1 and is_on_floor():
		_perform_enemy_attack()
		return

	# --- 2. ARRIVAL CHECK ---
	# Generous arrival distance to prevent endless micro-adjustments
	if dist_to_target < 1.2:
		print(name, " arrived at target.")
		_end_move_and_decide()
		return

	# --- 3. RADIUS LEASH ---
	# Keep strictly within the movement radius defined at start of turn
	if current_pos.distance_to(combat_turn_start_pos) > stats.movement_range + 0.5:
		_end_move_and_decide()
		return

	# --- 4. STUCK DETECTION (PROGRESS BASED) ---
	# Give a small grace period (500ms) at start of turn before checking stuck
	if Time.get_ticks_msec() - turn_start_time_ms > 500:
		# Check progress: Are we getting closer to the target?
		var current_dist: float = current_pos.distance_to(move_target_pos)
		
		# If we haven't gotten at least 5cm closer than our previous best record...
		if current_dist >= last_target_distance - 0.05:
			stuck_timer += delta
		else:
			# We made legitimate progress! Reset timer and update record.
			stuck_timer = 0.0
			last_target_distance = current_dist
			
		# Panic Jump: If stuck for 0.4s, try jumping (helps with small ledges/lips)
		if stuck_timer > 0.4 and is_on_floor() and jump_cooldown <= 0:
			velocity.y = 10
			jump_cooldown = 0.5
			# Don't reset stuck_timer completely, so if we land and are still stuck, we end turn
			# But reduce it slightly to give the jump a chance to resolve it
			stuck_timer = 0.2
			print(name, " panic/stuck jump!")

		if stuck_timer > 1.5:
			print(name, " stuck (no progress), ending turn.")
			_end_move_and_decide()
			return

	# --- 5. MOVEMENT ---
	var next_pos: Vector3 = move_target_pos
	
	if nav_agent:
		if not nav_agent.is_target_reached():
			next_pos = nav_agent.get_next_path_position()
			
			# FALLBACK: If NavServer gives us a point we are basically already at,
			# but we aren't at the final target yet, ignore Nav and try direct line.
			if next_pos.distance_to(current_pos) < 0.5 and dist_to_target > 1.0:
				next_pos = move_target_pos
		else:
			pass

	# Direction
	var dir: Vector3 = (next_pos - current_pos).normalized()
	dir.y = 0
	
	# Safety: Avoid zero direction
	if dir.length_squared() < 0.001 and dist_to_target > 1.0:
		dir = (move_target_pos - current_pos).normalized()
		dir.y = 0
		
	dir = dir.normalized()
	
	# Repulsion (reduced distance to 0.8m to allow tighter grouping)
	var repulsion: Vector3 = Vector3.ZERO
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or other.is_dead: continue
		var diff: Vector3 = global_position - other.global_position
		if diff.length() < 0.8:
			repulsion += diff.normalized()
	
	var target_vel_x: float = (dir.x + repulsion.x) * 4.0
	var target_vel_z: float = (dir.z + repulsion.z) * 4.0
	
	# Smoothly interpolate velocity
	velocity.x = move_toward(velocity.x, target_vel_x, 60.0 * delta)
	velocity.z = move_toward(velocity.z, target_vel_z, 60.0 * delta)
	
	# Face movement (Threshold increased to 0.5)
	if velocity.length() > 0.5:
		var look_target: Vector3 = current_pos + velocity.normalized()
		look_target.y = current_pos.y
		look_at(look_target, Vector3.UP)
		anim_tree.set("parameters/movement/transition_request", "walk")
	else:
		anim_tree.set("parameters/movement/transition_request", "idle")

	# --- 6. PROACTIVE JUMPING ---
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
	# Stop horizontal movement (preserve vertical for falling)
	velocity.x = 0
	velocity.z = 0
	
	# Wait until grounded (up to 2 seconds timeout)
	var timeout: float = 2.0
	while not is_on_floor() and timeout > 0:
		await get_tree().process_frame
		timeout -= get_process_delta_time()
	
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	
	# Small delay to let physics settle, then try to attack or end
	await get_tree().create_timer(0.2).timeout
	
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= 2.2:
		_perform_enemy_attack()
	else:
		_end_enemy_turn()

func _stop_moving_and_check_attack() -> void:
	_end_move_and_decide()

func check_for_player_combat() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player: return
	if player.is_dead: return # Don't start combat with dead player
	
	var dist: float = global_position.distance_to(player.global_position)
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	if not combat_manager: return
	
	if combat_manager.is_combat_active:
		# If we are close and NOT already in combat, join!
		if not is_in_group("combatant") and dist < 15.0:
			combat_manager.join_combat(self)
	else:
		# Start new combat if very close
		if dist < 10.0:
			combat_manager.start_combat(player, self)

func do_wander(delta: float) -> void:
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
	
	if velocity.length() > 0.1:
		var look_dir: Vector2 = Vector2(velocity.z, velocity.x)
		rotation.y = lerp_angle(rotation.y, look_dir.angle(), 0.1)
		anim_tree.set("parameters/movement/transition_request", "walk")
	else:
		anim_tree.set("parameters/movement/transition_request", "idle")

func enter_combat() -> void:
	add_to_group("combatant")
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(true)

var combat_turn_start_pos: Vector3 = Vector3.ZERO

func start_turn() -> void:
	if Engine.is_editor_hint():
		return
		
	print("Enemy Turn: ", name)
	combat_turn_start_pos = global_position
	turn_start_time_ms = Time.get_ticks_msec()
	# Initialize distance tracking with a safe high value or current distance
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
	var atk_ring: MeshInstance3D = get_node_or_null("%MovementRadius")
	if atk_ring:
		atk_ring.visible = true
		atk_ring.top_level = false
		atk_ring.position = Vector3(0, 0.1, 0)
		atk_ring.scale = Vector3(2.0, 1.0, 2.0)

	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if not player or player.is_dead:
		_end_enemy_turn()
		return
		
	# Calculate and Clamp Target
	var best_pos: Vector3 = _get_attack_slot_pos(player)
	var dist_budget: float = stats.movement_range
	
	# Clamp to movement radius
	if best_pos.distance_to(combat_turn_start_pos) > dist_budget:
		var dir_to_best: Vector3 = (best_pos - combat_turn_start_pos).normalized()
		move_target_pos = combat_turn_start_pos + dir_to_best * dist_budget
	else:
		move_target_pos = best_pos
		
	var dist_to_player: float = global_position.distance_to(player.global_position)
	
	# Clean slate
	stuck_timer = 0.0
	jump_cooldown = 0.0
	last_target_distance = global_position.distance_to(move_target_pos)
	
	if dist_to_player > 2.0:
		is_moving_on_turn = true
		if nav_agent:
			nav_agent.target_position = move_target_pos
	else:
		_perform_enemy_attack()

func _get_attack_slot_pos(player: Node) -> Vector3:
	var p_pos: Vector3 = player.global_position
	var cm: Node = get_node_or_null("/root/CombatManager")
	var my_idx: int = 0
	if cm:
		my_idx = cm.combatants.find(self)
	
	# Offset based on index to spread out around the player
	var angle: float = my_idx * 1.0
	var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * 1.8
	return p_pos + offset

func _perform_enemy_attack() -> void:
	# CRITICAL: Stop movement logic immediately to prevent infinite loop
	is_moving_on_turn = false
	velocity = Vector3.ZERO
	anim_tree.set("parameters/movement/transition_request", "idle")
	
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	
	# 1. Face player smoothly
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		var look_target: Vector3 = player.global_position
		look_target.y = global_position.y
		look_at(look_target, Vector3.UP)
	
	# 2. Wind up (Wait a moment)
	await get_tree().create_timer(0.5).timeout
	
	# CHECK: Abort if combat ended during await
	if not combat_manager or not combat_manager.is_combat_active:
		return
	
	# 3. Play Attack Animation
	anim_tree.set("parameters/movement/transition_request", "land_roll")
	print("Enemy Attacks!")
	
	# 4. Wait for impact moment
	await get_tree().create_timer(0.4).timeout
	
	# CHECK: Abort if combat ended during await
	if not combat_manager or not combat_manager.is_combat_active:
		return
	
	# 5. Deal damage
	if is_instance_valid(player):
		var player_node: Player = player as Player
		if player_node and player_node.stats and not player_node.is_dead:
			player_node.stats.take_damage(stats.attack)
			print("Enemy deals ", stats.attack, " damage to Player!")
	
	# 6. Recovery time before ending turn
	await get_tree().create_timer(1.0).timeout
	
	# CHECK: Abort if combat ended during await
	if not combat_manager or not combat_manager.is_combat_active:
		return
		
	_end_enemy_turn()

func _end_enemy_turn() -> void:
	velocity = Vector3.ZERO
	var ring: MeshInstance3D = get_node_or_null("%MovementRadius")
	if ring:
		ring.visible = false
		
	var move_ring: MeshInstance3D = get_node_or_null("MoveRangeIndicator")
	if move_ring:
		move_ring.visible = false
		
	var combat_manager: Node = get_node_or_null("/root/CombatManager")
	if combat_manager:
		combat_manager.end_turn()

func exit_combat() -> void:
	if is_dead: return
	remove_from_group("combatant")
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info and float_info.has_method("set_combat_mode"):
		float_info.set_combat_mode(false)
	
	# Reset wander state
	wander_timer = 0.0
	velocity = Vector3.ZERO

var is_dead: bool = false
func die() -> void:
	if is_dead: return
	is_dead = true
	
	print(name, " has died!")
	
	# Stop all processing/movement
	velocity = Vector3.ZERO
	set_physics_process(false)
	
	# Visuals: Fall on back (90 degrees on X)
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 90, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Visuals: Darken the mesh
	_apply_dark_material(mesh)
	
	# Physics: Disable collision
	var col := $CollisionShape3D
	if col: col.disabled = true
	
	# Combat: Remove from groups
	remove_from_group("combatant")
	remove_from_group("enemies")
	
	# Hide Floating Health Bar
	var float_info: Node = get_node_or_null("%FloatingInfo")
	if float_info: float_info.visible = false
	
	# Notify Manager
	var cm: Node = get_node_or_null("/root/CombatManager")
	if cm and cm.has_method("on_combatant_death"):
		cm.on_combatant_death(self)

func _apply_dark_material(node: Node) -> void:
	if node is MeshInstance3D:
		for i in range(node.get_surface_override_material_count()):
			var mat: Material = node.get_surface_override_material(i)
			if mat is StandardMaterial3D:
				var dark_mat: StandardMaterial3D = mat.duplicate()
				dark_mat.albedo_color = dark_mat.albedo_color.darkened(0.7)
				dark_mat.emission_enabled = false
				node.set_surface_override_material(i, dark_mat)
	
	for child in node.get_children():
		_apply_dark_material(child)
