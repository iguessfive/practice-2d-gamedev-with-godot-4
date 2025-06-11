class_name Player extends CharacterBody2D

enum States { # possible states (mode system) - use with match (switch) statements
	GROUND,
	JUMP, 
	FALL,
}

@export var acceleration := 700.0 # low - 700.0 - high
@export var deceleration := 1400.0 # low - 1400.0 - high
@export var max_speed := 120.0
@export var air_acceleration := 500.0
@export var max_fall_speed := 250.0

@export_category("jump")
@export var jump_height := 70.0 
@export var jump_time_to_peak := 0.37
@export var jump_time_to_decend := 0.3

var current_state: States = States.GROUND
var direction_x := 0.0 # input direction at any time
var current_gravity := 0.0

@onready var jump_speed: float = calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity: float = calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity: float = calculate_fall_gravity(jump_height, jump_time_to_decend)

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

func  _ready() -> void:
	_transition_to_state(current_state)

func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("move_left", "move_right"))
	
	match current_state:
		States.GROUND:
			process_ground_state(delta)
		States.JUMP:
			if direction_x != 0:
				# move to max speed considering air movement limitations
				velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
				velocity.x = clampf(velocity.x, -max_speed, max_speed)
				# updating visuals
				animated_sprite.flip_h = direction_x < 0.0
			
			if velocity.y >= -20.0: # just before moving down change to fall
				_transition_to_state(States.FALL)
		
		States.FALL:
			if direction_x != 0:
				# move to max speed considering air movement limitations
				velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
				velocity.x = clampf(velocity.x, -max_speed, max_speed)
				# updating visuals
				animated_sprite.flip_h = direction_x < 0.0
			
			if is_on_floor():
				_transition_to_state(States.GROUND)
	
	velocity.y += current_gravity * delta # apply every frame, always acting
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()

func process_ground_state(delta: float) -> void:	
	var is_moving := absf(direction_x) > 0
	if is_moving: # always true for any left or right movement
		#velocity.x = move_toward(velocity.x, max_speed * direction_x, acceleration * delta)
		velocity.x += direction_x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		
		# flip animation based on direction
		animated_sprite.flip_h = direction_x < 0 # going left
		# add run animation when moving
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		# add idle animation when at rest
		animated_sprite.play("idle")
		
	# chain state changes into one block, one state at a time.
	if Input.is_action_just_pressed("jump"):
		_transition_to_state(States.JUMP)
	elif not is_on_floor():
		_transition_to_state(States.FALL)
		
func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return -2.0 * height / time_to_peak

func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func calculate_fall_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func _transition_to_state(new_state: States) -> void:
	var previous_state: States = current_state
	current_state = new_state
	# store old state for clean up
	# pass in new state
	$StateLabel.text = States.keys()[current_state] #DEBUG
	
	match previous_state:
		pass
	
	match current_state:
		States.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			animated_sprite.play("jump")
			# go up in the y direction by the jump speed
			# play jump animation
		States.GROUND:
			animated_sprite.play("idle")
		States.FALL:
			current_gravity = fall_gravity
			animated_sprite.play("fall")
