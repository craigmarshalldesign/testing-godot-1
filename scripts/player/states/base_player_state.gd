class_name BasePlayerState
extends RefCounted

#Called when we first enter this state
func enter(_player: Player) -> void:
	pass
	

# Called when we exit a state (cleans up)
func exit(_player: Player) -> void:
	pass

## Called before update is called, allowas for state changes
func pre_update(_player: Player) -> void:
	pass

#Called for every physics frame that we're in this state
func update(_player: Player, _delta: float) -> void:
	pass
