extends Node2D

@onready var status_label = %status

func _ready():
	# Set status text based on who won
	if GameManager.player_won:
		status_label.text = "Victory!\nYou defeated the " + GameManager.selected_enemy.replace("_", " ").capitalize()
	else:
		status_label.text = "Defeat!\nYou were slain by the " + GameManager.selected_enemy.replace("_", " ").capitalize()

func _on_main_menu_pressed() -> void:
	BgMusic.sfx_ui()
	get_tree().change_scene_to_file("res://scenes/start.tscn")


func _on_restart_pressed() -> void:
	BgMusic.sfx_ui()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed() -> void:
	BgMusic.sfx_ui()
	get_tree().quit()
