extends CharacterBody2D

@export var acceleration := 700.0 # low - 700.0  - high
@export var deceleration := 1400.0 # low - 1400.0 - high
@export var max_speed := 120.0
@export var jump_gravity := 1200.0 # 1200.0

@onready var _animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction_x := signf(Input.get_axis("move_left", "move_right"))
	
	if absf(direction_x) > 0: # always true for any left or right movement
		#velocity.x = move_toward(velocity.x, max_speed * direction_x, acceleration * delta)
		velocity.x += direction_x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		
		# flip animation based on direction
		_animated_sprite.flip_h = direction_x < 0 # going left
		# add run animation when moving
		_animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		# add idle animation when at rest
		_animated_sprite.play("idle")
	
	velocity.y += jump_gravity * delta # apply every frame, always acting
	
	move_and_slide()
