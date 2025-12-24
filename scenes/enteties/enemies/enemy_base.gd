@tool
extends "res://scenes/enteties/enemies/scripts-enemy_base/enemy_combat.gd"
class_name EnemyBase

## Base class for all enemies. Extend this and override virtual functions for specific behaviors.
## Now using modular script inheritance: EnemyMovement -> EnemyCombat -> EnemyBase

# This file now acts mainly as the entry point/Facade for the enemy type.
# Most logic has been moved to scripts-enemy_base/enemy_movement.gd and enemy_combat.gd

# =============================================================================
# VIRTUAL FUNCTIONS - Override in child scripts
# =============================================================================

## Override to return the animation name for this enemy's attack
func _get_attack_animation() -> String:
	return "attack"

## Override to apply enemy-specific visual setup (materials, scale, etc.)
func _setup_enemy_visuals() -> void:
	pass

## Override to get the mesh node for this enemy (used for death darkening)
func _get_mesh_node() -> Node3D:
	return null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super._ready() # Calls EnemyCombat._ready() -> EnemyMovement._ready()
