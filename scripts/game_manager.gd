extends Node

var game_over = false
var selected_enemy = "flying_eye" # default enemy
var player_won = false # New variable to track who won

func _process(delta):
	if game_over:
		restart_game()

func set_game_over(did_player_win: bool = false):
	game_over = true
	player_won = did_player_win

func restart_game():
	game_over = false
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
