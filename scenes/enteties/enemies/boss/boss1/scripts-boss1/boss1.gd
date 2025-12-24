@tool
extends "res://scenes/enteties/enemies/enemy_base.gd"
class_name Boss1

## Boss1 - Large enemy with powerful attacks and high HP

@onready var mesh: Node3D = $skin


func _init() -> void:
	# Set default stats for Boss1
	base_health = 300
	base_attack = 80
	base_defense = 20
	base_speed = 30
	attack_range = 4.0
	attack_damage_delay = 0.6

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
