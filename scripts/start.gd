extends Node2D

func _ready() -> void:
	BgMusic.fade_in()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_credit_pressed() -> void:
	%creditcontainer.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_close_pressed() -> void:
	%creditcontainer.hide()
