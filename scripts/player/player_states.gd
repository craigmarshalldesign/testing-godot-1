extends Node

var IDLE := load("res://scripts/player/states/idle_player_state.gd").new() as BasePlayerState
var WALK := load("res://scripts/player/states/walk_player_state.gd").new() as BasePlayerState
var RUN := load("res://scripts/player/states/run_player_state.gd").new() as BasePlayerState
var JUMP := load("res://scripts/player/states/jump_player_state.gd").new() as BasePlayerState
var FALL := load("res://scripts/player/states/fall_player_state.gd").new() as BasePlayerState
var LAND := load("res://scripts/player/states/land_player_state.gd").new() as BasePlayerState
var COMBAT := load("res://scripts/player/states/combat_player_state.gd").new() as BasePlayerState
