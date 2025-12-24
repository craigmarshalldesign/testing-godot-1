@tool
extends PlayerBase

## CharacterB - Second party member (Skeleton Mage)
## Configured with SkeletonMage mesh and animations

func _init() -> void:
	_configure_stats()

func _setup_stats() -> void:
	_configure_stats()
	super._setup_stats()

func _configure_stats() -> void:
	base_health = 40
	base_attack = 70
	base_defense = 8
	base_speed = 36

# Animation state names (must match AnimationTree states)
func _get_attack_animation() -> String: return "attack"
func _get_walk_animation() -> String: return "walk"
func _get_idle_animation() -> String: return "idle"
func _get_fall_animation() -> String: return "fall"
