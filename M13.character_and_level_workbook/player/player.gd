class_name Player extends CharacterBody2D

enum State { # possible states (mode system) - use with match (switch) statements
	GROUND,
	JUMP,
	DOUBLE_JUMP,
	FALL,
}

const  MAX_JUMPS = 2

@export var acceleration := 700.0 # low - 700.0 - high
@export var deceleration := 1400.0 # low - 1400.0 - high
@export var max_speed := 120.0
@export var air_acceleration := 500.0
@export var max_fall_speed := 250.0 

@export_category("jump")
@export var jump_height := 50.0
@export var jump_time_to_peak := 0.37
@export var jump_time_to_decend := 0.2
@export var jump_horizontal_distance := 80.0 # influenced by max_speed & heignt 
@export var jump_cut_divider := 15.0 # start speed when jump released not at max
@export var coyote_wait_time := 0.1

@export_category("Double Jump")
@export_range(10.0, 200.0) var double_jump_height := 30.0
@export_range(0.1, 1.5) var double_jump_time_to_peak := 0.3
@export_range(0.1, 1.5) var double_jump_time_to_descent := 0.25

var current_state: State = State.GROUND
var direction_x := 0.0 # input direction at any time
var current_gravity := 0.0
var jump_count: int = 0

@onready var jump_speed: float = calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity: float = calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity: float = calculate_fall_gravity(jump_height, jump_time_to_decend)
@onready var jump_horizontal_speed: float = calculate_jump_horizontal_speed(jump_horizontal_distance, jump_time_to_peak, jump_time_to_decend)
@onready var double_jump_speed := calculate_jump_speed(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_gravity := calculate_jump_gravity(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_fall_gravity := calculate_fall_gravity(double_jump_height, double_jump_time_to_descent)

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var coyote_timer := Timer.new()

func  _ready() -> void:
	_transition_to_state(current_state)
	
	coyote_timer.wait_time = coyote_wait_time
	coyote_timer.one_shot = true
	add_child(coyote_timer)

func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("move_left", "move_right"))
	
	match current_state:
		State.GROUND:
			process_ground_state(delta)
		State.JUMP:
			if direction_x != 0:
				# move to max speed considering air movement limitations
				velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
				velocity.x = clampf(velocity.x, -max_speed, max_speed)
				# updating visuals
				animated_sprite.flip_h = direction_x < 0.0
			
			if Input.is_action_just_released("jump"):
				# if high velocity in the vertical y direction, so closer to ground, cut speed
				# otherwise closer to top then y velocity is near zero, continue
				var jump_cut_speed := jump_speed / jump_cut_divider
				if velocity.y < 0.0 and velocity.y < jump_cut_speed:
					velocity.y = jump_cut_speed
				
			if velocity.y >= 0.0: # just before moving down change to fall
				_transition_to_state(State.FALL)
			elif Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
				_transition_to_state(State.DOUBLE_JUMP)
		State.DOUBLE_JUMP:
			if direction_x != 0:
				# move to max speed considering air movement limitations
				velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
				velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
				# updating visuals
				animated_sprite.flip_h = direction_x < 0.0
			
			if velocity.y >= 0.0: # just before moving down change to fall
				_transition_to_state(State.FALL)
		State.FALL:
			if direction_x != 0:
				# move to max speed considering air movement limitations
				velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
				velocity.x = clampf(velocity.x, -max_speed, max_speed)
				# updating visuals
				animated_sprite.flip_h = direction_x < 0.0
		
			if is_on_floor():
				_transition_to_state(State.GROUND)
			if Input.is_action_just_pressed("jump"):
				if not coyote_timer.is_stopped():
					_transition_to_state(State.JUMP)
				elif jump_count < MAX_JUMPS:
					_transition_to_state(State.DOUBLE_JUMP)

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
		_transition_to_state(State.JUMP)
	elif not is_on_floor():
		_transition_to_state(State.FALL)
		
func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return -2.0 * height / time_to_peak

func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func calculate_fall_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func calculate_jump_horizontal_speed(distance: float, time_to_peak: float, time_to_decent) -> float:
	return distance / (time_to_peak + time_to_decent)

func _transition_to_state(new_state: State) -> void:
	var previous_state: State = current_state
	current_state = new_state
	# store old state for clean up
	# pass in new state
	$StateLabel.text = State.keys()[current_state] #DEBUG
	
	match previous_state:
		State.JUMP:
			coyote_timer.stop()
	
	match current_state:
		State.JUMP:
			velocity.y = jump_speed
			current_gravity = jump_gravity
			velocity.x = sign(velocity.x) * jump_horizontal_speed
			animated_sprite.play("jump")
			jump_count = 1
		State.GROUND:
			animated_sprite.play("idle")
			if previous_state == State.FALL:
				jump_count = 0
		State.FALL:
			current_gravity = double_jump_fall_gravity if jump_count == MAX_JUMPS else fall_gravity
			
			if previous_state == State.GROUND:
				coyote_timer.start()
		State.DOUBLE_JUMP:
			velocity.y = double_jump_speed
			current_gravity = double_jump_gravity
			velocity.x = sign(velocity.x) * jump_horizontal_speed
			animated_sprite.play("jump")
			jump_count = MAX_JUMPS
			
			
			
