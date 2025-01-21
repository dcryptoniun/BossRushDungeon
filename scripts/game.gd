extends Node2D


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
