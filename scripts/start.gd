extends Node2D

@onready var spin_wheel = %SpinWheel
@onready var enemy_label = %Enemy_selected

func _ready() -> void:
	BgMusic.fade_in()
	spin_wheel.connect("enemy_selected", _on_enemy_selected)
	# Initialize label with default enemy
	enemy_label.text = "Selected: " + GameManager.selected_enemy.replace("_", " ").capitalize()

func _on_spin_pressed() -> void:
	BgMusic.sfx_ui()
	# Disable spin button during spin
	%Spin.disabled = true
	
	# Start the spin and wait for completion
	await spin_wheel.start_spin()
	
	# Re-enable spin button after spin completes
	%Spin.disabled = false

func _on_start_pressed() -> void:
	BgMusic.sfx_ui()
	# Only allow start if an enemy is selected
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_enemy_selected(enemy_type: String):
	# Store the selected enemy in GameManager
	GameManager.selected_enemy = enemy_type
	# Update the label with selected enemy
	enemy_label.text = "Selected: " + enemy_type.replace("_", " ").capitalize()

func _on_credit_pressed() -> void:
	BgMusic.sfx_ui()
	%creditcontainer.show()

func _on_quit_pressed() -> void:
	BgMusic.sfx_ui()
	get_tree().quit()

func _on_close_pressed() -> void:
	BgMusic.sfx_ui()
	%creditcontainer.hide()


func _on_closecontrol_pressed() -> void:
	%Control.hide()


func _on_controls_pressed() -> void:
	%Control.show()
