extends Node2D

signal enemy_selected(enemy_type: String)

@onready var wheel = $wheel
@onready var pointer = $pointer

var wheel_speed = 0
var is_spinning = false
var slowing_down = false
const MAX_SPEED = 720  # Degrees per second
const SLOW_RATE = 180  # How fast it slows down
var options = ["goblin_boss", "flying_eye", "mushroom_boss"]  # Your enemy options

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

func spin():
	if !is_spinning:
		is_spinning = true
		wheel_speed = MAX_SPEED
		await get_tree().create_timer(2.0).timeout  # Spin at max speed for 2 seconds
		slowing_down = true

func select_enemy():
	# Calculate which enemy is selected based on final angle
	var final_angle = fmod(wheel.rotation_degrees, 360)
	if final_angle < 0:
		final_angle += 360
	var section_size = 360.0 / options.size()
	var selected_index = int(final_angle / section_size)
	var selected_enemy = options[selected_index]
	emit_signal("enemy_selected", selected_enemy)
