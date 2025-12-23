class_name WalkPlayerState
extends BasePlayerState


func enter(player: Player) -> void:
	player.anim_tree.set("parameters/movement/transition_request", "walk")
	

func update(player: Player, _delta: float) -> void:
	var direction := player.get_move_input()
	player.update_velocity_using_direction(direction)
	player.move_and_slide()
	player.turn_to(direction)
	
	var current_speed := player.get_current_speed()
	var walk_speed := lerpf(0.5, 1.75, current_speed / player.run_speed)
	player.anim_tree.set("parameters/walk_speed/scale", walk_speed)

func pre_update(player: Player) -> void:
	var current_speed := player.get_current_speed()
	
	if not player.is_on_floor():
		player.change_state_to(PlayerStates.FALL)
	elif current_speed > player.run_speed:
		player.change_state_to(PlayerStates.RUN)
	elif current_speed == 0.0:
		player.change_state_to(PlayerStates.IDLE)
	elif Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
