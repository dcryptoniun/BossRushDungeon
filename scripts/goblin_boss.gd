extends CharacterBody2D

@onready var game_manager: Node = get_node("/root/GameManager")
@onready var goblin = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var path_timer = $Timer
@onready var health_bar = $ProgressBar

var player: CharacterBody2D = null
const SPEED = 300
const ATTACK_RANGE = 50.0
const ATTACK_DAMAGE = 10
var last_direction = Vector2.ZERO
var is_attacking = false
var health = 100
var can_attack = true

func _ready():
	# Get reference to the player node
	player = get_tree().get_first_node_in_group("player")
	if !player:
		push_error("Player node not found! Make sure player is in group 'player'")
		return
		
	# Setup navigation timer
	path_timer.wait_time = 0.1 # Update path every 0.1 seconds
	path_timer.timeout.connect(_update_path_to_player)
	path_timer.start()
	
	# Setup navigation
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	# Connect animation finished signal
	goblin.animation_finished.connect(_on_animation_finished)
	
	# Setup health bar
	health_bar.max_value = health
	health_bar.value = health
	health_bar.show()

func _physics_process(delta):
	if !player or health <= 0:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if in attack range
	if distance_to_player <= ATTACK_RANGE and can_attack and !is_attacking:
		attack()
	elif !is_attacking:
		if nav_agent.is_navigation_finished():
			return
			
		var next_path_position = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_position)
		
		# Update velocity and move
		velocity = direction * SPEED
		move_and_slide()
		
		# Update last_direction for animation
		if direction.length() > 0:
			last_direction = direction
			
		# Update animations based on movement direction
		update_animation(direction)

func _update_path_to_player():
	if player:
		nav_agent.target_position = player.global_position

func update_animation(direction: Vector2):
	if direction.length() > 0:
		# Play run animation
		goblin.play("run")
		
		# Handle horizontal flipping
		if direction.x < 0:
			goblin.flip_h = true
		elif direction.x > 0:
			goblin.flip_h = false
	else:
		# Play idle animation
		goblin.play("idle")
		
		# Keep the last horizontal flip state
		if last_direction.x < 0:
			goblin.flip_h = true
		elif last_direction.x > 0:
			goblin.flip_h = false

func attack():
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	goblin.play("attack")
	
	# Create attack hitbox
	var attack_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	shape.radius = ATTACK_RANGE
	collision_shape.shape = shape
	attack_area.add_child(collision_shape)
	add_child(attack_area)
	
	# Wait a tiny bit for physics to update
	await get_tree().create_timer(0.1).timeout
	
	# Check for player hit
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body == player:
			deal_damage_to_player()
	
	# Remove attack hitbox after a short delay
	await get_tree().create_timer(0.2).timeout
	attack_area.queue_free()
	
	# Add attack cooldown
	await get_tree().create_timer(1.0).timeout
	can_attack = true

func _on_animation_finished():
	if is_attacking and goblin.animation == "attack":
		is_attacking = false

func deal_damage_to_player():
	if player and player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)

func take_damage(amount: int):
	goblin.play("takehit")
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	# Stop all movement and actions
	velocity = Vector2.ZERO
	is_attacking = false
	can_attack = false
	health_bar.value = 0
	
	# Play idle animation and wait briefly
	goblin.play("death")
	print("Goblin Boss defeated - Press attack to restart")
	
	# Wait a moment before freeing
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
	# Set game over state
	get_node("/root/GameManager").set_game_over()
	
	
