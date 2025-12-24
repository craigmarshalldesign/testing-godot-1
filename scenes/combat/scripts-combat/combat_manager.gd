extends Node

signal combat_started
signal combat_ended
signal game_over
signal turn_changed(new_combatant: Node)

var is_combat_active: bool = false
var combatants: Array[Node] = []
var turn_index: int = 0
var current_combatant: Node = null
const ENEMY_LINK_RANGE: float = 20.0 ## Range from fight center to pull other enemies in initially

func start_combat(player: Node, initial_enemy: Node) -> void:
	if is_combat_active:
		return
	
	is_combat_active = true
	combatants.clear()
	
	# Check if player has a PartyManager parent
	var party_manager: PartyManager = _find_party_manager(player)
	
	if party_manager:
		# Add all party members to combat
		party_manager.enter_combat()
		var all_party: Array[Node3D] = party_manager.get_all_characters()
		for member in all_party:
			combatants.append(member)
		print("Added ", all_party.size(), " party members to combat")
	else:
		# Single player mode
		combatants.append(player)
	
	# Add initial enemy
	combatants.append(initial_enemy)
	
	# Find other nearby enemies (within 20m of the fight center)
	var fight_center: Vector3 = (player.global_position + initial_enemy.global_position) * 0.5
	var all_enemies: Array = player.get_tree().get_nodes_in_group("enemies")
	for enemy: Node in all_enemies:
		if enemy == initial_enemy:
			continue
		if enemy.global_position.distance_to(fight_center) < ENEMY_LINK_RANGE:
			combatants.append(enemy)
	
	# Sort by speed stat (highest first)
	combatants.sort_custom(func(a: Node, b: Node) -> bool: return a.stats.speed > b.stats.speed)
	
	turn_index = 0
	current_combatant = combatants[0]
	
	# Tell everyone to enter combat mode (party members already notified via party_manager)
	for c: Node in combatants:
		if c.has_method("enter_combat") and not c.is_in_group("player"):
			c.enter_combat()
	
	emit_signal("combat_started")
	print("Combat started with ", combatants.size(), " combatants!")
	
	print("--- TURN ORDER ---")
	for i in range(combatants.size()):
		var c: Node = combatants[i]
		var spd: int = 0
		if c.get("stats"): spd = c.stats.speed
		print(i, ": ", c.name, " (Spd: ", spd, ")")
	print("------------------")
	
	_start_turn()

func _find_party_manager(player: Node) -> PartyManager:
	var parent: Node = player.get_parent()
	while parent:
		if parent is PartyManager:
			return parent as PartyManager
		parent = parent.get_parent()
	return null

func _start_turn() -> void:
	# Check if combatants list is empty or invalid
	if combatants.is_empty():
		end_combat()
		return

	# Wrap index just in case
	if turn_index >= combatants.size():
		turn_index = 0
		
	current_combatant = combatants[turn_index]
	emit_signal("turn_changed", current_combatant)
	
	# Switch camera to current combatant if they're a party member
	_update_camera_for_turn(current_combatant)
	
	if current_combatant.has_method("start_turn"):
		current_combatant.start_turn()

func _update_camera_for_turn(combatant: Node) -> void:
	# Only update camera if it's a player character's turn
	if not combatant.is_in_group("player"):
		return
		
	# Find party manager from any party member
	var party_manager: PartyManager = _find_party_manager(combatant)
	if party_manager:
		party_manager.set_camera_target(combatant as Node3D)

func join_combat(new_combatant: Node) -> void:
	if not is_combat_active or new_combatant in combatants:
		return
		
	print(new_combatant.name, " joined the battle!")
	combatants.append(new_combatant)
	
	if new_combatant.has_method("setup_visuals"):
		new_combatant.setup_visuals()
	
	# Sort to maintain speed-based turn order
	combatants.sort_custom(func(a: Node, b: Node) -> bool: return (a.get("stats") as CombatantStats).speed > (b.get("stats") as CombatantStats).speed)
	
	# Re-find our turn index so the order doesn't jump
	if is_instance_valid(current_combatant):
		turn_index = combatants.find(current_combatant)
	
	if new_combatant.has_method("enter_combat"):
		new_combatant.enter_combat()
		
	# Update UI
	emit_signal("turn_changed", current_combatant)

func end_turn() -> void:
	if not is_combat_active: return
	if combatants.is_empty(): return
	turn_index = (turn_index + 1) % combatants.size()
	# Defer starting the next turn to next frame.
	# This prevents the current InputEvent from triggering actions for the NEXT character
	# if the control switch happens synchronously.
	call_deferred("_start_turn")

func on_combatant_death(combatant: Node) -> void:
	var idx: int = combatants.find(combatant)
	if idx != -1:
		print("Combatant ", combatant.name, " has died. Removing from index ", idx)
		combatants.remove_at(idx)
		
		# If the dead combatant was at or before our current turn index,
		# we need to adjust the index so we don't skip anyone.
		if idx < turn_index:
			turn_index -= 1
		elif idx == turn_index:
			# If it died on its own turn, the index now points to the NEXT person (who shifted left)
			# So we don't increment.
			# But we need to ensure the index is valid.
			if turn_index >= combatants.size():
				turn_index = 0
		
		# Check victory (returns true if game is ending)
		if _check_victory_condition_met():
			return
		
		# If combat is still active and it was the dead combatant's turn, we need to force the next turn immediately
		# BUT only if this function wasn't called from within an existing turn flow that will handle it?
		# Actually, safely we can just let the current turn owner finish their logic.
		# If the CURRENT turn owner died (idx == turn_index before removal), then WE must start the new turn.
		# Note: logic above adjusted turn_index to point to the 'next' person.
		
		# However, if an Enemy killed the Player, it is the Enemy's turn.
		# idx (Player) != turn_index (Enemy).
		# So we do NOTHING here. The Enemy will finish attack and call end_turn().
		pass
	else:
		print("ERROR: Combatant ", combatant.name, " died but was not found in combatants list!")

func _check_victory_condition_met() -> bool:
	if not is_combat_active: return true # Already ending
	
	var enemies_left: int = 0
	var players_left: int = 0
	
	for c: Node in combatants:
		if is_instance_valid(c):
			if c.is_in_group("player"):
				players_left += 1
			else:
				enemies_left += 1
	
	if enemies_left == 0:
		print("Victory! All enemies defeated.")
		end_combat(true) # Victory = true
		return true
	elif players_left == 0:
		print("Game Over! All players defeated.")
		# Stop further combat logic immediately
		is_combat_active = false
		_trigger_game_over_sequence()
		return true
		
	return false

func _trigger_game_over_sequence() -> void:
	print("Triggering game over sequence...")
	# Wait for death animation
	await get_tree().create_timer(1.0).timeout
	print("Emitting game_over signal")
	emit_signal("game_over")
	# Small delay to ensure UI processes the signal before we clear combatants
	await get_tree().create_timer(0.1).timeout
	end_combat(false) # Victory = false

func end_combat(victory: bool = false) -> void:
	is_combat_active = false
	
	# Find and notify party manager
	for c: Node in combatants:
		if c.is_in_group("player"):
			var pm: PartyManager = _find_party_manager(c)
			if pm:
				pm.exit_combat(victory)
				break
	
	for c: Node in combatants:
		if is_instance_valid(c) and c.has_method("exit_combat") and not c.is_in_group("player"):
			c.exit_combat()
	combatants.clear()
	emit_signal("combat_ended")
