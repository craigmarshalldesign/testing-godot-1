extends Node3D
class_name PartyManager

## PartyManager - Manages the player party, active character, and character switching
## Add your character scenes as children of this node in the editor.
## Works in two modes:
## - Exploration: Only active character visible, LB/RB switches
## - Combat: All characters visible and positioned, each gets their turn

signal active_character_changed(new_character: Node3D)
signal party_entered_combat
signal party_exited_combat

var characters: Array[Node3D] = []
var active_index: int = 0
var active_character: Node3D
var is_in_combat: bool = false

@onready var party_camera: PartyCamera = get_node_or_null("PartyCamera")

func _ready() -> void:
	# Defer initialization to ensure children have run their _ready() and joined groups
	call_deferred("_initialize_party")

func _initialize_party() -> void:
	# Find all children in the "player" group
	for child in get_children():
		if child.is_in_group("player"):
			characters.append(child)
	
	if characters.size() == 0:
		push_warning("PartyManager: No characters found in 'player' group!")
		return
	
	# Set initial active character
	active_character = characters[0]
	active_index = 0
	
	# Enable first character, disable all others
	for i in range(characters.size()):
		var character: Node3D = characters[i]
		if i == 0:
			_enable_character(character)
		else:
			_disable_character(character)
	
	_update_camera_target()
	print("Party initialized with ", characters.size(), " members. Active: ", active_character.name)

func _enable_character(character: Node3D) -> void:
	character.visible = true
	character.process_mode = Node.PROCESS_MODE_INHERIT
	# Enable collision
	if character is CharacterBody3D:
		(character as CharacterBody3D).collision_layer = 1
		(character as CharacterBody3D).collision_mask = 5

func _disable_character(character: Node3D) -> void:
	character.visible = false
	character.process_mode = Node.PROCESS_MODE_DISABLED
	# Disable collision so inactive characters don't interfere
	if character is CharacterBody3D:
		(character as CharacterBody3D).collision_layer = 0
		(character as CharacterBody3D).collision_mask = 0

func _input(event: InputEvent) -> void:
	# Only allow switching in exploration mode
	if is_in_combat:
		return
	
	if event.is_action_pressed("switch_character_left"):
		switch_character(-1)
	elif event.is_action_pressed("switch_character_right"):
		switch_character(1)

func switch_character(direction: int) -> void:
	if characters.size() <= 1:
		return
	
	# Remember position before switching
	var old_pos: Vector3 = active_character.global_position if active_character else Vector3.ZERO
	
	# Disable current character
	if active_character:
		_disable_character(active_character)
	
	# Switch index
	active_index = (active_index + direction) % characters.size()
	if active_index < 0:
		active_index = characters.size() - 1
	
	# Enable new character at same position
	active_character = characters[active_index]
	active_character.global_position = old_pos
	_enable_character(active_character)
	
	_update_camera_target()
	emit_signal("active_character_changed", active_character)
	print("Switched to: ", active_character.name)

func _update_camera_target() -> void:
	if party_camera:
		party_camera.set_target(active_character)

func set_camera_target(target: Node3D) -> void:
	if party_camera:
		party_camera.set_target(target)

func get_all_characters() -> Array[Node3D]:
	return characters

func get_active_character() -> Node3D:
	return active_character

# --- Combat Mode ---

func enter_combat() -> void:
	if is_in_combat:
		return
	
	is_in_combat = true
	emit_signal("party_entered_combat")
	
	# Position all characters near the active one in a circle
	var center: Vector3 = active_character.global_position
	# Orient formation based on active character's rotation
	var base_rotation: float = active_character.rotation.y
	
	# Dynamic radius: Increase for larger parties to prevent overlap
	var base_radius: float = 2.0
	var radius: float = base_radius + max(0, characters.size() - 4) * 0.5
	
	var angle_step: float = TAU / max(characters.size(), 1)
	
	for i in range(characters.size()):
		var character: Node3D = characters[i]
		
		# Enable all characters
		_enable_character(character)
		
		# Position in a circle around the combat center
		if i != active_index:
			# Distribute, but start from "behind" (-Z is forward, so +Z is back) or just distribute evenly
			var angle: float = base_rotation + (angle_step * i)
			# Create circle offset
			var offset: Vector3 = Vector3(sin(angle), 0, cos(angle)) * radius
			character.global_position = center + offset
			
			# Face outwards or same direction?
			# Face same direction as leader initially for better orientation
			character.rotation.y = base_rotation
		
		# Tell character to enter combat
		if character.has_method("enter_combat"):
			character.enter_combat()
			
		# Reset velocity to stop any residual movement
		if character is CharacterBody3D:
			character.velocity = Vector3.ZERO

	
	print("Party entered combat. All ", characters.size(), " members now visible.")

func exit_combat(restore_party: bool = false) -> void:
	if not is_in_combat:
		return
	
	is_in_combat = false
	emit_signal("party_exited_combat")
	
	# Hide all but active character
	for i in range(characters.size()):
		var character: Node3D = characters[i]
		
		# Optional: Revive and Heal if requested (Victory)
		if restore_party:
			if character.has_method("revive"):
				character.revive()
		
		# Tell character to exit combat first
		if character.has_method("exit_combat"):
			character.exit_combat()
		
		# Enable active, disable others
		if i == active_index:
			_enable_character(character)
		else:
			_disable_character(character)
	
	# Return camera to active character
	_update_camera_target()
	print("Party exited combat. Only ", active_character.name, " visible now.")
