extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D # Reference to the AnimatedSprite2D node
@onready var health_bar = $ProgressBar
@onready var sfx_attack = $attack
@onready var sfx_death = $death

var last_direction = Vector2.ZERO # Tracks the last direction the player moved
var is_attacking = false # Flag to indicate if the player is attacking
const SPEED = 600
const ATTACK_DAMAGE = 25
var health = 150

func _ready():
	# Set up collision layers
	collision_layer = 2 # Player is on layer 2
	collision_mask = 1 | 4 # Collide with world (1) and enemies (4)
	
	# Add to player group for enemy targeting
	add_to_group("player")
	# Connect animation finished signal
	player_sprite.animation_finished.connect(_on_animation_finished)
	# Setup health bar
	health_bar.max_value = health
	health_bar.value = health
	health_bar.show()

func _physics_process(delta):
	# Always process movement, even when attacking
	if health > 0:
		handle_movement()
	
	# Handle attack input only if not already attacking
	if Input.is_action_just_pressed("attack") and !is_attacking and health > 0:
		attack()

func handle_movement():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	# Update last_direction if moving
	if direction.length() > 0:
		last_direction = direction
		# Play run animations only if not attacking
		if !is_attacking:
			if direction.x < 0: # Moving left
				player_sprite.play("runleft")
			elif direction.x > 0: # Moving right
				player_sprite.play("runright")
			elif direction.y < 0: # Moving up
				player_sprite.play("runup")
			elif direction.y > 0: # Moving down
				player_sprite.play("rundown")
	elif !is_attacking:
		# Set idle animation based on last direction when not attacking
		if last_direction.x < 0:
			player_sprite.play("idleleft")
		elif last_direction.x > 0:
			player_sprite.play("idleright")
		elif last_direction.y < 0:
			player_sprite.play("idletop")
		elif last_direction.y > 0:
			player_sprite.play("idle")
		else:
			player_sprite.play("idle") # Default idle animation

func attack():
	is_attacking = true
	
	# Create attack hitbox
	var attack_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	sfx_attack.play()
	
	# Set up attack area collision
	attack_area.collision_layer = 0 # No collision layer needed for area
	attack_area.collision_mask = 4 # Only detect enemies (layer 4)
	
	shape.radius = 50.0 # Attack range
	collision_shape.shape = shape
	attack_area.add_child(collision_shape)
	
	# Position the attack area in front of the player based on last direction
	var attack_offset = last_direction * 30
	attack_area.position = attack_offset
	add_child(attack_area)
	
	# Set attack animation based on last direction
	if last_direction.x < 0:
		player_sprite.play("attackleft")
	elif last_direction.x > 0:
		player_sprite.play("attackright")
	elif last_direction.y < 0:
		player_sprite.play("attackup")
	elif last_direction.y > 0:
		player_sprite.play("attackdown")
	else:
		player_sprite.play("attackdown")
	
	# Do damage check only once
	await get_tree().create_timer(0.1).timeout
	var hit_enemies = [] # Keep track of enemies we've hit
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body != self and body.has_method("take_damage") and body.collision_layer == 4 and not (body in hit_enemies):
			print("Player hits enemy for ", ATTACK_DAMAGE, " damage!")
			body.take_damage(ATTACK_DAMAGE)
			hit_enemies.append(body) # Add enemy to hit list
	
	# Remove attack hitbox
	await get_tree().create_timer(0.2).timeout
	attack_area.queue_free()

func _on_animation_finished():
	if is_attacking:
		is_attacking = false

func take_damage(amount: int):
	print("Player takes ", amount, " damage! Health: ", health, " -> ", health - amount)
	health -= amount
	health_bar.value = health
	if health <= 0:
		sfx_death.play()
		die()

func die():
	print("Player dies!")
	health = 0
	health_bar.value = 0
	is_attacking = false
	velocity = Vector2.ZERO
	player_sprite.play("idle")
	print("Game Over - Press attack to restart")
	get_node("/root/GameManager").set_game_over()
