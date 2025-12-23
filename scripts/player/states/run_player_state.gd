class_name RunPlayerState
extends BasePlayerState


func enter(player: Player) -> void:
	player.anim_tree.set("parameters/movement/transition_request", "run")

func update(player: Player, _delta: float) -> void:
	var direction := player.get_move_input()
	player.update_velocity_using_direction(direction)
	player.move_and_slide()
	player.turn_to(direction)
	
	var lean := direction.dot(player.global_basis.x)
	player.last_lean = lerpf(player.last_lean, lean, 0.3)
	player.anim_tree.set("parameters/run_lean/add_amount", player.last_lean)

func pre_update(player: Player) -> void:
	var current_speed := player.get_current_speed()
	
	if not player.is_on_floor():
		player.change_state_to(PlayerStates.FALL)
	elif current_speed <= player.run_speed and current_speed > 0:
		player.change_state_to(PlayerStates.WALK)
	elif current_speed == 0:
		player.change_state_to(PlayerStates.IDLE)
	elif Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
