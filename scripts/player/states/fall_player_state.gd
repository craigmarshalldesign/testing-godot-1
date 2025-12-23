class_name FallPlayerState
extends BasePlayerState

var fall_time := 0.0
var starting_y := 0.0
var fall_distance := 0.0

func enter(player: Player) -> void:
	fall_time = 0.0
	starting_y = player.global_position.y
	player.anim_tree.set("parameters/movement/transition_request", "fall")
	
func update(player: Player, delta: float) -> void:
	fall_time += delta
	fall_distance = starting_y - player.global_position.y
	var direction := player.get_move_input()
	
	player.velocity += player.get_gravity() * delta
	player.update_velocity_using_direction(direction, player.base_speed * 1)
	player.move_and_slide()
	player.turn_to(direction)

func pre_update(player: Player) -> void:
	if player.is_on_floor():
		if fall_time > 0.4:
			player.change_state_to(PlayerStates.LAND)
			return
			
		var current_speed := player.get_current_speed()
		if current_speed > player.run_speed:
			player.change_state_to(PlayerStates.RUN)
		elif current_speed > 0:
			player.change_state_to(PlayerStates.WALK)
		else:
			player.change_state_to(PlayerStates.IDLE)
