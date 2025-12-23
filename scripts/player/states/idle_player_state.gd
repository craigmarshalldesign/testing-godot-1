class_name IdlePlayerState
extends BasePlayerState

func enter(player: Player) -> void:
	player.anim_tree.set("parameters/movement/transition_request", "idle")

func pre_update(player: Player) -> void:
	var move_input := player.get_move_input()
	
	if not player.is_on_floor():
		player.change_state_to(PlayerStates.FALL)
	elif Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
	elif move_input.length() > 0:
		player.change_state_to(PlayerStates.WALK)

func update(player: Player, _delta: float) -> void:
	var move_input := player.get_move_input()
	player.update_velocity_using_direction(move_input)
	player.move_and_slide()
	player.turn_to(move_input)
