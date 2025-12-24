@tool
extends PlayerBase

## CharacterB - Second party member (Skeleton Mage)
## Configured with SkeletonMage mesh and animations

func _init() -> void:
	max_health = 80
	attack = 20
	defense = 8
	speed = 14

# Animation state names (must match AnimationTree states)
func _get_attack_animation() -> String: return "attack"
func _get_walk_animation() -> String: return "walk"
func _get_idle_animation() -> String: return "idle"
func _get_fall_animation() -> String: return "fall"
