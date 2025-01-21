# mushroom_boss.gd
extends CharacterBody2D

@onready var mushroom = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var health_bar = $ProgressBar

var player: CharacterBody2D = null
const SPEED = 200
const ATTACK_RANGE = 50.0
const MIN_DISTANCE = 30.0
const ATTACK_DAMAGE = 15 # Different damage than goblin
var last_direction = Vector2.ZERO
var is_attacking = false
var health = 250 # Different health than goblin
var can_attack = true

func _ready():
	# Set up collision layers
	collision_layer = 4 # Enemy is on layer 4
	collision_mask = 1 | 2 # Collide with world (1) and player (2)
	
	# Get reference to the player node
	player = get_tree().get_first_node_in_group("player")
	if !player:
		push_error("Player node not found!")
		return
	
	# Setup navigation
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.avoidance_enabled = true
	
	# Connect animation finished signal
	mushroom.animation_finished.connect(_on_animation_finished)
	
	# Setup health bar
	health_bar.max_value = health
	health_bar.value = health
	health_bar.show()

func _physics_process(delta):
	if !player or health <= 0:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Always update path to player
	nav_agent.target_position = player.global_position
	
	# Check if in attack range
	if distance_to_player <= ATTACK_RANGE and can_attack and !is_attacking:
		attack()
	
	# Handle movement if not attacking
	if !is_attacking:
		var next_path_position = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_position)
		
		# If too close to player, move away slightly
		if distance_to_player < MIN_DISTANCE:
			direction = -global_position.direction_to(player.global_position)
		
		# Update velocity and move
		velocity = direction * SPEED
		move_and_slide()
		
		# Update last_direction for animation
		if direction.length() > 0:
			last_direction = direction
			
		# Update animations based on movement direction
		update_animation(direction)

func update_animation(direction: Vector2):
	if is_attacking:
		return
		
	if direction.length() > 0:
		# Play run animation
		if mushroom.animation != "run":
			mushroom.play("run")
		
		# Handle horizontal flipping
		if direction.x < 0:
			mushroom.flip_h = true
		elif direction.x > 0:
			mushroom.flip_h = false
	else:
		# Play idle animation
		if mushroom.animation != "idle":
			mushroom.play("idle")
		
		# Keep the last horizontal flip state
		if last_direction.x < 0:
			mushroom.flip_h = true
		elif last_direction.x > 0:
			mushroom.flip_h = false

func attack():
	is_attacking = true
	can_attack = false
	mushroom.play("attack")
	
	# Create attack hitbox
	var attack_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	# Set up attack area collision
	attack_area.collision_layer = 0
	attack_area.collision_mask = 2 # Only detect player (layer 2)
	
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
	await get_tree().create_timer(0.8).timeout
	can_attack = true

func _on_animation_finished():
	if mushroom.animation == "attack":
		is_attacking = false
	elif mushroom.animation == "takehit":
		if !is_attacking:
			var direction = velocity.normalized()
			update_animation(direction)

func deal_damage_to_player():
	if player and player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)

func take_damage(amount: int):
	health -= amount
	health_bar.value = health
	
	# Only play hit animation if not attacking
	if !is_attacking:
		mushroom.play("takehit")
	
	if health <= 0:
		die()

func die():
	velocity = Vector2.ZERO
	is_attacking = false
	can_attack = false
	health_bar.value = 0
	
	# Play death animation
	mushroom.play("death")
	
	# Wait for death animation
	await get_tree().create_timer(2.0).timeout
	
	# Set game over and wait a brief moment
	GameManager.set_game_over(true)
	await get_tree().create_timer(0.5).timeout
	
	# Remove the enemy
	queue_free()
