extends Node2D

signal enemy_selected(enemy_type: String)

@onready var wheel = $wheel
@onready var pointer = $pointer
# Add markers for each enemy position
@onready var mushroom_marker = $mushroom_marker # Add these as Node2D or Marker2D
@onready var goblin_marker = $goblin_marker # in your wheel scene at the
@onready var flying_eye_marker = $flying_eye_marker # center of each section

var wheel_speed = 0
var is_spinning = false
var slowing_down = false
const MAX_SPEED = 720 # Degrees per second
const SLOW_RATE = 180 # How fast it slows down

# Define sections with their markers and angles
var sections = [
	{"marker": "mushroom_marker", "enemy": "mushroom_boss", "angle": 270}, # Top (270 degrees)
	{"marker": "goblin_marker", "enemy": "goblin_boss", "angle": 150}, # Bottom left (150 degrees)
	{"marker": "flying_eye_marker", "enemy": "flying_eye", "angle": 30} # Right (30 degrees)
]

var last_selected = "" # Keep track of last selected enemy to prevent repeats

func _ready():
	# Initialize wheel position
	wheel.rotation_degrees = 0

func _process(delta):
	if is_spinning:
		# Rotate the wheel
		wheel.rotation_degrees += wheel_speed * delta
		
		if slowing_down:
			wheel_speed = max(0, wheel_speed - SLOW_RATE * delta)
			if wheel_speed == 0:
				is_spinning = false
				select_enemy()

func start_spin():
	if !is_spinning:
		is_spinning = true
		wheel_speed = MAX_SPEED
		
		# Select a random enemy that's different from the last one
		var available_sections = sections.filter(func(section): return section.enemy != last_selected)
		var target_section = available_sections[randi() % available_sections.size()]
		last_selected = target_section.enemy
		
		# Calculate target angle plus some full rotations
		var target_angle = target_section.angle
		var full_rotations = (randi() % 3 + 3) * 360 # 3-5 full rotations
		var total_angle = full_rotations + target_angle
		
		await get_tree().create_timer(2.0).timeout
		slowing_down = true
		
		# Adjust wheel_speed to reach the target angle
		wheel_speed = calculate_speed_for_target(total_angle)
		
		await get_tree().create_timer(3.0).timeout
		return true

func calculate_speed_for_target(target_angle: float) -> float:
	return MAX_SPEED * (target_angle / (360 * 3))

func select_enemy():
	# Find the closest marker to the pointer
	var closest_marker = null
	var closest_distance = INF
	
	for section in sections:
		var marker = get_node(section.marker)
		# Convert marker's position to global to compare with pointer
		var marker_pos = wheel.global_position + marker.position.rotated(wheel.rotation)
		var distance = marker_pos.distance_to(pointer.global_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_marker = section.enemy
	
	if closest_marker:
		
		emit_signal("enemy_selected", closest_marker)
