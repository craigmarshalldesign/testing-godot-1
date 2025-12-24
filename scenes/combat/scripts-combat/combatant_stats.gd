class_name CombatantStats
extends Resource

@export_group("Base Stats")
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 15
@export var defense: int = 10
@export var speed: int = 12

@export_group("Combat State")
@export var can_move: bool = true
@export var movement_range: float = 5.0 # How many meters they can move in a turn

signal damage_taken(amount: int)

func take_damage(amount: int) -> void:
	var damage: int = max(1, amount - defense)
	current_health -= damage
	damage_taken.emit(damage)
	if current_health < 0:
		current_health = 0

func reset_turn() -> void:
	can_move = true
