@tool
extends Node3D
class_name FloatingInfo

@onready var hp_bar: ProgressBar = $SubViewport/ProgressBar
@onready var damage_pos: Marker3D = $DamagePopPos

var stats_ref: CombatantStats
var is_player: bool = false
var target_arrow: MeshInstance3D = null
var active_tween: Tween = null

func setup(stats: CombatantStats) -> void:
	stats_ref = stats
	if stats_ref:
		if not stats_ref.damage_taken.is_connected(_on_damage_taken):
			stats_ref.damage_taken.connect(_on_damage_taken)
	
	_apply_styles()
	
	# Determine if we are attached to the player
	var parent: Node = get_parent()
	if parent and parent.is_in_group("player"):
		is_player = true
		# Make player HP bar smaller as requested
		scale = Vector3(0.6, 0.6, 0.6)
		# Initially hide for player until combat starts
		visible = false
	else:
		# Enemie bars are usually visible or always in combat context here
		visible = true

func _apply_styles() -> void:
	if not hp_bar: return
	
	# Create StyleBox for the fill (Green)
	var sb_fill: StyleBoxFlat = StyleBoxFlat.new()
	sb_fill.bg_color = Color.GREEN
	sb_fill.set_border_width_all(1)
	sb_fill.border_color = Color.BLACK
	hp_bar.add_theme_stylebox_override("fill", sb_fill)
	
	# Create StyleBox for the background (Red - missing health)
	var sb_bg: StyleBoxFlat = StyleBoxFlat.new()
	sb_bg.bg_color = Color.RED
	sb_bg.set_border_width_all(1)
	sb_bg.border_color = Color.BLACK
	hp_bar.add_theme_stylebox_override("background", sb_bg)

func set_combat_mode(active: bool) -> void:
	if is_player:
		visible = active
	else:
		# Enemies usually only exist near combat or we want to see their HP always?
		# User specifically mentioned player's health bar should only show during combat.
		visible = active

func set_targeted(active: bool) -> void:
	if is_player: return # Player doesn't need a target arrow above themselves
	
	if not target_arrow:
		_create_target_arrow()
	
	target_arrow.visible = active
	
	# Animate bounce if visible
	if active:
		if active_tween: active_tween.kill()
		active_tween = create_tween().set_loops()
		target_arrow.position.y = 1.0
		active_tween.tween_property(target_arrow, "position:y", 1.2, 0.4).set_trans(Tween.TRANS_SINE)
		active_tween.tween_property(target_arrow, "position:y", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	else:
		if active_tween:
			active_tween.kill()
			active_tween = null

func _create_target_arrow() -> void:
	target_arrow = MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.4, 0.4, 0.2)
	target_arrow.mesh = prism
	target_arrow.rotation.x = PI # Point down
	target_arrow.position = Vector3(0, 2.0, 0)
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.CYAN
	mat.emission_enabled = true
	mat.emission = Color.CYAN
	mat.emission_energy_multiplier = 2.0
	target_arrow.material_override = mat
	
	add_child(target_arrow)
	# Mark for tween identification
	# (Unfortunately we can't easily set meta and retrieve it cleanly in all Godot versions without custom logic)
	# So we'll just let the tweens run or use a local variable.

func _process(_delta: float) -> void:
	if stats_ref and hp_bar:
		hp_bar.max_value = stats_ref.max_health
		hp_bar.value = stats_ref.current_health

func _on_damage_taken(amount: int) -> void:
	var label: Label = Label.new()
	label.text = str(amount)
	label.modulate = Color.YELLOW # Changed to yellow for better visibility against red damage
	label.add_theme_font_size_override("font_size", 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var view: SubViewport = SubViewport.new()
	view.size = Vector2(120, 60)
	view.transparent_bg = true
	view.add_child(label)
	add_child(view)
	
	var sprite: Sprite3D = Sprite3D.new()
	sprite.texture = view.get_texture()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.position = damage_pos.position
	sprite.top_level = true # Keep it from scaling with the parent if the parent moves/scales
	sprite.global_position = damage_pos.global_position
	add_child(sprite)
	
	# Animate up and fade
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "global_position:y", sprite.global_position.y + 2.0, 1.0)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func() -> void:
		sprite.queue_free()
		view.queue_free()
	)
