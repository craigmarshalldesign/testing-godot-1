@tool
extends "res://scenes/enteties/enemies/enemy_base.gd"
class_name Boss1

## Boss1 - Large enemy with powerful attacks and high HP

@onready var mesh: Node3D = $skin


func _init() -> void:
	_configure_stats()

func _setup_stats() -> void:
	_configure_stats()
	super._setup_stats()

func _configure_stats() -> void:
	# Set default stats for Boss1
	base_health = 180
	base_attack = 40
	base_defense = 20
	base_speed = 28
	attack_range = 4.0
	attack_damage_delay = 0.6
	hit_radius = 1.5 # Large hitbox for easier targeting

func _ready() -> void:
	super._ready()

func _get_attack_animation() -> String:
	return "attack" # State name in AnimationTree (maps to 2H_Melee_Attack_Chop)

func _get_walk_animation() -> String:
	return "walk" # This maps to "Walking_A" in the AnimationTree

func _get_idle_animation() -> String:
	return "idle" # This maps to "2H_Melee_Idle" in the AnimationTree

func _get_fall_animation() -> String:
	return "fall" # Maps to Jump_Idle in AnimationTree (now added)

func _get_mesh_node() -> Node3D:
	return mesh

func _setup_enemy_visuals() -> void:
	# Boss1-specific visual setup
	# Mesh rotation is now handled in the scene file (boss1.tscn)
	pass
