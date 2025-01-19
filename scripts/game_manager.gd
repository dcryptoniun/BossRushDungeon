extends Node

var game_over = false

func _process(delta):
	if game_over:
		restart_game()

func set_game_over():
	game_over = true

func restart_game():
	game_over = false
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
