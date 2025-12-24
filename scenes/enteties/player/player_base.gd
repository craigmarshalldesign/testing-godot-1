@tool
extends "res://scenes/enteties/player/scripts-player_base/player_combat.gd"
class_name PlayerBase

## PlayerBase - Facade script for the player party system characters.
## Inherit from this to create specific character classes (Warrior, Mage, etc.)

func _ready() -> void:
	super._ready()
	add_to_group("player")

func _get_mesh_node() -> Node3D:
	return get_node_or_null("skin")

func _setup_visuals() -> void:
	super._setup_visuals()
	# Child classes can add class-specific visual setup here
