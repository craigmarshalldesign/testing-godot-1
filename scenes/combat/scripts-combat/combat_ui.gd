extends CanvasLayer

@onready var turn_label: Label = %TurnLabel
@onready var end_turn_button: Button = %EndTurnButton
@onready var stats_list: VBoxContainer = %StatsList

@onready var target_container: Control = %TargetContainer
@onready var target_name_label: Label = %TargetName
@onready var target_hp_bar: ProgressBar = %TargetHPBar
@onready var target_hp_label: Label = %TargetHPLabel

var stat_entries: Dictionary = {} # Node -> HBoxContainer

func _ready() -> void:
	visible = false
	CombatManager.combat_started.connect(_on_combat_started)
	CombatManager.combat_ended.connect(_on_combat_ended)
	CombatManager.turn_changed.connect(_on_turn_changed)
	if CombatManager.has_signal("game_over"):
		CombatManager.game_over.connect(_on_game_over)
		
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_pressed)
	
	_style_target_bar()
	
	# Add Game Over UI
	_setup_game_over_ui()

func _style_target_bar() -> void:
	# Style Target HP Bar (Green fill, Red background)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = Color.GREEN
	target_hp_bar.add_theme_stylebox_override("fill", sb_fill)
	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = Color.RED
	target_hp_bar.add_theme_stylebox_override("background", sb_bg)
	
	target_container.visible = false

func _on_combat_started() -> void:
	visible = true
	is_game_over = false # Reset state
	if game_over_container: game_over_container.visible = false
	# Show combat UI elements
	turn_label.visible = true
	if end_turn_button: end_turn_button.visible = true
	stats_list.visible = true
	update_stats_display()

func _on_combat_ended() -> void:
	if is_game_over:
		return # Don't hide UI if it's game over
		
	visible = false
	for entry_to_free: HBoxContainer in stat_entries.values():
		if is_instance_valid(entry_to_free):
			entry_to_free.queue_free()
	stat_entries.clear()

func _on_game_over() -> void:
	print("CombatUI: Received game_over signal!")
	is_game_over = true
	show_game_over()


func _on_turn_changed(_combatant: Node) -> void:
	if is_game_over: return
	
	var active_combatant: Node = CombatManager.current_combatant
	if not active_combatant: return
	
	if active_combatant.is_in_group("player"):
		turn_label.text = "YOUR TURN"
		turn_label.modulate = Color.CYAN
		if end_turn_button:
			end_turn_button.disabled = false
	else:
		turn_label.text = "ENEMY TURN"
		turn_label.modulate = Color.ORANGE_RED
		if end_turn_button:
			end_turn_button.disabled = true

func _process(_delta: float) -> void:
	if not visible or is_game_over:
		return
		
	update_stats_display()
	update_target_display()

func update_target_display() -> void:
	# Get the current player turn holder, or any active player
	var player: Node = null
	var active: Node = CombatManager.current_combatant
	if active and active.is_in_group("player"):
		player = active
	else:
		player = get_tree().get_first_node_in_group("player")
	
	if not player:
		target_container.visible = false
		return
		
	var target: Node = null
	
	# Priority 1: If it's an enemy's turn, show them as the "target" (the one acting)
	if active and not active.is_in_group("player"):
		target = active
	
	# Priority 2: If it's player's turn, show the player's selected target
	if not target and player.has_method("get") and player.get("current_target"):
		target = player.get("current_target")
	
	# UI Update
	if not target or not is_instance_valid(target):
		target_container.visible = false
		return
	
	target_container.visible = true
	target_name_label.text = target.name
	var target_stats: CombatantStats = target.get("stats") as CombatantStats
	if target_stats:
		target_hp_bar.max_value = target_stats.max_health
		target_hp_bar.value = target_stats.current_health
		target_hp_label.text = "%d/%d" % [target_stats.current_health, target_stats.max_health]

func update_stats_display() -> void:
	var current_combatants: Array[Node] = CombatManager.combatants
	
	# Cleanup entries
	var entry_keys_to_check: Array = stat_entries.keys()
	for key_node: Node in entry_keys_to_check:
		if not is_instance_valid(key_node) or key_node not in current_combatants:
			var hbox_to_cleanup: HBoxContainer = stat_entries[key_node] as HBoxContainer
			if is_instance_valid(hbox_to_cleanup):
				hbox_to_cleanup.queue_free()
			stat_entries.erase(key_node)
	
	# Add or Update entries (Focus ONLY on Player)
	for combatant_item: Node in current_combatants:
		if not is_instance_valid(combatant_item): continue
		if not combatant_item.is_in_group("player"): continue # Only show player in sidebar
		
		if not stat_entries.has(combatant_item):
			var new_hbox: HBoxContainer = HBoxContainer.new()
			new_hbox.custom_minimum_size.y = 30
			
			var new_name_label: Label = Label.new()
			new_name_label.text = combatant_item.name
			new_name_label.custom_minimum_size.x = 100
			
			var new_progress: ProgressBar = ProgressBar.new()
			new_progress.custom_minimum_size = Vector2(100, 20)
			new_progress.show_percentage = false
			
			var new_hp_label: Label = Label.new()
			new_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			new_hp_label.custom_minimum_size.x = 60
			
			new_hbox.add_child(new_name_label)
			new_hbox.add_child(new_progress)
			new_hbox.add_child(new_hp_label)
			stats_list.add_child(new_hbox)
			stat_entries[combatant_item] = new_hbox
			
			# Style the progress bar
			var sb_fill: StyleBoxFlat = StyleBoxFlat.new()
			sb_fill.bg_color = Color.GREEN
			new_progress.add_theme_stylebox_override("fill", sb_fill)
			var sb_bg: StyleBoxFlat = StyleBoxFlat.new()
			sb_bg.bg_color = Color.RED
			new_progress.add_theme_stylebox_override("background", sb_bg)
			
			if combatant_item.is_in_group("player"):
				new_name_label.modulate = Color.CYAN
			else:
				new_name_label.modulate = Color.ORANGE_RED
		
		# Update values
		var entry_hbox: HBoxContainer = stat_entries[combatant_item] as HBoxContainer
		var entry_progress: ProgressBar = entry_hbox.get_child(1) as ProgressBar
		var entry_hp_label: Label = entry_hbox.get_child(2) as Label
		
		var stats_res: CombatantStats = combatant_item.get("stats") as CombatantStats
		if stats_res:
			entry_progress.max_value = float(stats_res.max_health)
			entry_progress.value = float(stats_res.current_health)
			entry_hp_label.text = "%d/%d" % [stats_res.current_health, stats_res.max_health]

func _setup_game_over_ui() -> void:
	# Create a full-screen container for centering
	game_over_container = Control.new()
	game_over_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_container.visible = false
	add_child(game_over_container)
	
	# Dark overlay background
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.7) # Dark semi-transparent
	game_over_container.add_child(overlay)
	
	# Center container for text
	var center_box: VBoxContainer = VBoxContainer.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	center_box.position = Vector2(-200, -100) # Offset to center the box content
	game_over_container.add_child(center_box)
	
	# Main "GAME OVER" text
	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.label_settings = LabelSettings.new()
	game_over_label.label_settings.font_size = 96
	game_over_label.label_settings.font_color = Color(0.9, 0.1, 0.1) # Deep red
	game_over_label.label_settings.outline_size = 6
	game_over_label.label_settings.outline_color = Color.BLACK
	game_over_label.label_settings.shadow_size = 4
	game_over_label.label_settings.shadow_color = Color(0, 0, 0, 0.8)
	game_over_label.label_settings.shadow_offset = Vector2(3, 3)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.custom_minimum_size = Vector2(400, 100)
	center_box.add_child(game_over_label)
	
	# Spacer
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	center_box.add_child(spacer)
	
	# Restart prompt text
	restart_label = Label.new()
	restart_label.text = "Press A / Space to Restart"
	restart_label.label_settings = LabelSettings.new()
	restart_label.label_settings.font_size = 28
	restart_label.label_settings.font_color = Color(0.9, 0.9, 0.9) # Light gray
	restart_label.label_settings.outline_size = 2
	restart_label.label_settings.outline_color = Color.BLACK
	restart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	restart_label.custom_minimum_size = Vector2(400, 40)
	center_box.add_child(restart_label)

func show_game_over() -> void:
	print("CombatUI: show_game_over called")
	game_over_container.visible = true
	visible = true # Ensure the canvas layer is visible even if combat ended
	
	# Hide combat UI elements to prevent "stuck" look
	turn_label.visible = false
	if end_turn_button: end_turn_button.visible = false
	stats_list.visible = false
	target_container.visible = false
	
	# Animate the Game Over text with a scale pop
	var tween: Tween = create_tween()
	game_over_label.scale = Vector2(0.5, 0.5)
	game_over_label.modulate.a = 0
	tween.tween_property(game_over_label, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(game_over_label, "modulate:a", 1.0, 0.3)
	
	# Fade in restart label after main text
	restart_label.modulate.a = 0
	tween.tween_property(restart_label, "modulate:a", 1.0, 0.5).set_delay(0.3)
	
	# Pulse animation for restart prompt
	var pulse_tween: Tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(restart_label, "modulate:a", 0.5, 0.8).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(restart_label, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
	
	print("CombatUI: Game Over UI should now be visible")

var is_game_over: bool = false
var game_over_container: Control
var game_over_label: Label
var restart_label: Label

func _input(event: InputEvent) -> void:
	if is_game_over:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump"):
			print("CombatUI: Restart triggered!")
			get_tree().reload_current_scene()


func _on_end_turn_pressed() -> void:
	# Call end_turn on the current combatant if it's a player
	var current: Node = CombatManager.current_combatant
	if current and current.is_in_group("player") and current.has_method("end_turn"):
		current.end_turn()
