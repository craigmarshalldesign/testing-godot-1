@tool
extends PlayerBase

## CharacterA - First party member (Skeleton Warrior)
## Configured with SkeletonWarrior mesh and animations

func _init() -> void:
	max_health = 100
	attack = 15
	defense = 10
	speed = 12

# Animation state names (must match AnimationTree states)
func _get_attack_animation() -> String: return "attack"
func _get_walk_animation() -> String: return "walk"
func _get_idle_animation() -> String: return "idle"
func _get_fall_animation() -> String: return "fall"
