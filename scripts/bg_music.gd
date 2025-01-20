extends AudioStreamPlayer

func _ready():
	# Set up music to loop
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep playing during pause
	autoplay = true
	
	# Make sure volume is at a good level
	volume_db = -50 # Adjust this value as needed
	
	# Start playing if not already playing
	if !playing:
		play()

func _process(delta):
	# Ensure music keeps playing and loops
	if !playing:
		play()

# Function to fade out music
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 1.0)
	await tween.finished
	stop()

# Function to fade in music
func fade_in():
	volume_db = -80
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -40, 1.0)

# Function to handle scene transition
func transition_to_scene(scene_path: String):
	await fade_out()
	get_tree().change_scene_to_file(scene_path)
	fade_in()
	
