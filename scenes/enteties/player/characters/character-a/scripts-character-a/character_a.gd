@tool
extends PlayerBase

## CharacterA - First party member (Skeleton Warrior)
## Configured with SkeletonWarrior mesh and animations

func _init() -> void:
	_configure_stats()

func _setup_stats() -> void:
	_configure_stats()
	super._setup_stats()

func _configure_stats() -> void:
	base_health = 120
	base_attack = 25
	base_defense = 20
	base_speed = 30

# Animation state names (must match AnimationTree states)
func _get_attack_animation() -> String: return "attack"
func _get_walk_animation() -> String: return "walk"
func _get_idle_animation() -> String: return "idle"
func _get_fall_animation() -> String: return "fall"
