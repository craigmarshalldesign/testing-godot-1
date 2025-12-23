class_name LandPlayerState
extends BasePlayerState

var land_timer := 0.0
var landing_duration := 0.8
var is_rolling := false

func enter(player: Player) -> void:
	# Decide animation based on movement input
	var move_input := player.get_move_input()
	
	if move_input.length() > 0.1 and PlayerStates.FALL.fall_distance > 3.0:
		player.anim_tree.set("parameters/movement/transition_request", "land_roll")
		landing_duration = 0.8 # Roll length
		is_rolling = true
	else:
		player.anim_tree.set("parameters/movement/transition_request", "land_soft")
		landing_duration = 0.6 # Short soft land
		is_rolling = false
	
	# Reset timer
	land_timer = 0.0
	
	# Play landing sound
	var footstepper := player.get_node("footsteps")
	if footstepper and footstepper.has_method("play_footsteps"):
		footstepper.play_footsteps()

func update(player: Player, delta: float) -> void:
	land_timer += delta
	var move_input := player.get_move_input()
	
	if is_rolling:
		# Keep moving in the direction we were holding
		player.update_velocity_using_direction(move_input, player.base_speed)
	else:
		# Allow normal movement during soft land
		player.update_velocity_using_direction(move_input, player.base_speed)
		
	player.move_and_slide()
	player.turn_to(move_input)

func pre_update(player: Player) -> void:
	var move_input := player.get_move_input()
	
	# If we are soft landing but start moving, skip to walk immediately
	if not is_rolling and move_input.length() > 0.1:
		player.change_state_to(PlayerStates.WALK)
		return

	# After the animation duration, go back to normal states
	if land_timer >= landing_duration:
		if move_input.length() > 0.1:
			if player.get_current_speed() > player.run_speed:
				player.change_state_to(PlayerStates.RUN)
			else:
				player.change_state_to(PlayerStates.WALK)
		else:
			player.change_state_to(PlayerStates.IDLE)
	
	# Can still jump out of a landing!
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.change_state_to(PlayerStates.JUMP)
