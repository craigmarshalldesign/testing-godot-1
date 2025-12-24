@tool
extends "res://scenes/enteties/enemies/enemy_base.gd"
class_name SkeletonWarrior

## SkeletonWarrior - Standard melee enemy with a two-handed weapon

@onready var mesh: Node3D = $skin

func _init() -> void:
	# Same stats as AntiHero
	base_health = 85
	base_attack = 50
	base_defense = 8
	base_speed = 10

func _ready() -> void:
	super._ready()

func _get_attack_animation() -> String:
	return "attack" # Maps to 2H_Melee_Attack_Chop in AnimationTree

func _get_walk_animation() -> String:
	return "walk" # Maps to Walking_A in AnimationTree

func _get_idle_animation() -> String:
	return "idle" # Maps to 2H_Melee_Idle in AnimationTree

func _get_fall_animation() -> String:
	return "fall" # Maps to Jump_Idle in AnimationTree

func _get_mesh_node() -> Node3D:
	return mesh

func _setup_enemy_visuals() -> void:
	# SkeletonWarrior uses its default appearance - no changes needed
	pass
