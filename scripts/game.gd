extends Node2D

@onready var pause_menu = $PauseMenu # Add a PauseMenu node in your game scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load and spawn the selected enemy
	var enemy_scene = load("res://scenes/" + GameManager.selected_enemy + ".tscn")
	var enemy_instance = enemy_scene.instantiate()
	
	# Set enemy position to spawn point
	var spawn_point = $EnemySpawnPoint # Add this node in your game scene
	enemy_instance.global_position = spawn_point.global_position
	
	# Add enemy to scene
	add_child(enemy_instance)
	
	# Set up pause menu
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.hide()

func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused
	BgMusic.sfx_ui()

func _on_resume_pressed() -> void:
	_toggle_pause()
