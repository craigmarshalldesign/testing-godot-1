class_name CombatPlayerState
extends BasePlayerState

var turn_start_pos: Vector3 = Vector3.ZERO
var is_my_turn: bool = false
var movement_left: float = 0.0
var current_target: Node = null
var is_attacking: bool = false

func enter(player: Player) -> void:
	player.anim_tree.set("parameters/movement/transition_request", "idle")
	player.velocity = Vector3.ZERO
	is_my_turn = false
	is_attacking = false

func start_turn(player: Player) -> void:
	is_my_turn = true
	is_attacking = false
	turn_start_pos = player.global_position
	# For UI feedback
	movement_left = player.stats.movement_range
	print("Player's turn! Centered at: ", turn_start_pos)
	
	# Movement Radius Feedback (Fixed at start position)
	var ring: MeshInstance3D = player.get_node_or_null("%MovementRadius")
	if ring:
		ring.visible = true
		ring.top_level = true # Prevent jitter by disconnecting from parent movement
		ring.global_position = turn_start_pos + Vector3(0, 0.1, 0)
		var s: float = player.stats.movement_range
		ring.scale = Vector3(s, 1.0, s)

func update(player: Player, delta: float) -> void:
	# Always apply gravity in combat state if not on floor
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	if not is_my_turn or is_attacking:
		player.velocity.x = 0
		player.velocity.z = 0
		if not is_attacking:
			player.anim_tree.set("parameters/movement/transition_request", "idle")
		player.move_and_slide() # Still need to move for gravity
		return

	# Movement Radius Feedback visibility check
	var ring: MeshInstance3D = player.get_node_or_null("%MovementRadius")
	var atk_ring: MeshInstance3D = player.get_node_or_null("AttackRangeIndicator")
	
	if ring and not ring.visible:
		ring.visible = true
		
	if not atk_ring:
		atk_ring = MeshInstance3D.new()
		atk_ring.name = "AttackRangeIndicator"
		var torus := TorusMesh.new()
		torus.inner_radius = 0.98
		torus.outer_radius = 1.0
		atk_ring.mesh = torus
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1, 0, 0, 0.3) # Red for attack
		mat.emission_enabled = true
		mat.emission = Color(1, 0, 0)
		mat.emission_energy_multiplier = 2.0
		atk_ring.material_override = mat
		player.add_child(atk_ring)
		
	atk_ring.visible = true
	atk_ring.position = Vector3(0, 0.15, 0) # Slightly higher than movement ring
	atk_ring.scale = Vector3(2.0, 1.0, 2.0) # Unified 2m attack range

	# Handle Jumping
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		player.velocity.y = player.JUMP_VELOCITY

	var direction := player.get_move_input()
	if direction.length() > 0.1:
		player.update_velocity_using_direction(direction, player.base_speed)
		player.turn_to(direction)
		player.anim_tree.set("parameters/movement/transition_request", "walk")
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.base_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.base_speed)
		player.anim_tree.set("parameters/movement/transition_request", "idle")
	
	player.move_and_slide()
	
	# Strict movement Radius enforcement
	var horizontal_offset := player.global_position - turn_start_pos
	horizontal_offset.y = 0
	var max_range: float = player.stats.movement_range
	if horizontal_offset.length() > max_range:
		var clamped: Vector3 = horizontal_offset.normalized() * max_range
		player.global_position.x = turn_start_pos.x + clamped.x
		player.global_position.z = turn_start_pos.z + clamped.z

	# Update targeting logic
	var new_target: Node = _get_closest_enemy_in_range(player, 6.0) # Slightly increased range for targeting
	if new_target != current_target:
		_set_target(current_target, false)
		current_target = new_target
		_set_target(current_target, true)

	# Logic for actions
	if Input.is_action_just_pressed("attack"):
		if current_target:
			var dist: float = player.global_position.distance_to(current_target.global_position)
			var target_radius: float = _get_target_radius(current_target)
			# Allow attack if we are within range + target's radius (so we touch their collision)
			var effective_range: float = 2.0 + target_radius
			
			if dist <= effective_range:
				perform_attack(player, current_target)
			else:
				print("Enemy is too far! Dist: %.2f, Range: %.2f (Radius: %.2f)" % [dist, effective_range, target_radius])
		else:
			print("No enemy targeted to attack!")
	
	if Input.is_action_just_pressed("end_turn"):
		end_player_turn(player)

func _get_target_radius(target: Node) -> float:
	var col: Node = target.get_node_or_null("CollisionShape3D")
	if col and "shape" in col and col.shape:
		if col.shape is CapsuleShape3D or col.shape is CylinderShape3D:
			return col.shape.radius
		elif col.shape is SphereShape3D:
			return col.shape.radius
		elif col.shape is BoxShape3D:
			return max(col.shape.size.x, col.shape.size.z) * 0.5
	return 0.5 # Default fallback

func _set_target(enemy: Node, active: bool) -> void:
	if is_instance_valid(enemy):
		var float_info: Node = enemy.get_node_or_null("%FloatingInfo")
		if float_info and float_info.has_method("set_targeted"):
			float_info.set_targeted(active)

func _get_closest_enemy_in_range(player: Player, max_dist: float) -> Node:
	var closest: Node = null
	# Increase scan range significantly to find large bosses that might be centered far away
	# but have edges close by.
	var min_dist: float = max_dist + 5.0
	
	for c in CombatManager.combatants:
		if c.is_in_group("enemies") and is_instance_valid(c):
			var dist_to_center: float = player.global_position.distance_to(c.global_position)
			
			# Check effective distance (center_dist - radius)
			# We want to know if the SURFACE is within max_dist
			var radius: float = _get_target_radius(c)
			var dist_to_surface: float = dist_to_center - radius
			
			if dist_to_surface < max_dist:
				# We sort by center distance for "closest" feel usually, 
				# but let's stick to center dist for sorting, just filter by surface visibility
				if dist_to_center < min_dist:
					min_dist = dist_to_center
					closest = c
	return closest


func perform_attack(player: Player, target: Node) -> void:
	is_attacking = true
	player.velocity = Vector3.ZERO
	
	# Face the target
	var dir: Vector3 = (target.global_position - player.global_position).normalized()
	player.turn_to(dir)
	
	# Explicitly set the roll animation state
	player.anim_tree.set("parameters/movement/transition_request", "land_roll")
	print("Player Attacks ", target.name)
	
	var enemy_stats: CombatantStats = target.get("stats") as CombatantStats
	if enemy_stats:
		enemy_stats.take_damage(player.stats.attack)
		print("Dealt ", player.stats.attack, " damage!")
	
	# After animation (roughly), end turn
	player.get_tree().create_timer(1.5).timeout.connect(func() -> void:
		is_attacking = false
		end_player_turn(player)
	)

func end_player_turn(player: Player) -> void:
	is_my_turn = false
	player.velocity = Vector3.ZERO # Stop movement immediately
	var ring: MeshInstance3D = player.get_node_or_null("%MovementRadius")
	if ring:
		ring.visible = false
		
	var atk_ring: MeshInstance3D = player.get_node_or_null("AttackRangeIndicator")
	if atk_ring:
		atk_ring.visible = false
		
	var combat_manager: Node = player.get_node_or_null("/root/CombatManager")
	if combat_manager:
		_set_target(current_target, false)
		current_target = null
		combat_manager.end_turn()
