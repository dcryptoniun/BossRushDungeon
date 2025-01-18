extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * 600
	move_and_slide()

	# Play animations based on movement direction
	if direction.length() > 0:
		if direction.x < 0:
			if animated_sprite.animation != "runright":
				animated_sprite.play("runright")
		elif direction.x > 0:
			if animated_sprite.animation != "runleft":
				animated_sprite.play("runleft")
		elif direction.y < 0:
			if animated_sprite.animation != "runup":
				animated_sprite.play("runup")
		elif direction.y > 0:
			if animated_sprite.animation != "rundown":
				animated_sprite.play("rundown")
	else:
		# Player is idle; set to idle animation
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
