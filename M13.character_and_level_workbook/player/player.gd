class_name Player extends CharacterBody2D

enum State { # possible states (mode system) - use with match (switch) statements
	GROUND,
	JUMP,
	DOUBLE_JUMP,
	FALL,
	WALL_JUMP,
	WALL_SLIDE,
	PUSH,
	PULL,
}

const  MAX_JUMPS = 2

@export var acceleration := 700.0 # low - 700.0 - high
@export var deceleration := 1400.0 # low - 1400.0 - high
@export var max_speed := 120.0
@export var air_acceleration := 500.0
@export var max_fall_speed := 250.0 

@export_category("jump")
@export var jump_height := 50
@export var jump_time_to_peak := 0.37
@export var jump_time_to_descent := 0.3
@export var jump_horizontal_distance := 80.0 # influenced by max_speed & heignt 
@export var jump_cut_divider := 15.0 # start speed when jump released not at max
@export var coyote_wait_time := 0.1
@export var input_buffering_wait_time := 0.1

@export_category("Double Jump")
@export_range(10.0, 200.0) var double_jump_height := 30.0
@export_range(0.1, 1.5) var double_jump_time_to_peak := 0.3
@export_range(0.1, 1.5) var double_jump_time_to_descent := 0.25

@export_category("Wall Jump")
@export_range(10.0, 100.0) var wall_jump_height := 40.0
@export_range(80.0, 200.0) var wall_jump_horizontal_distance := 120.0
@export var wall_slide_speed := 50.0
@export var wall_slide_friction := 300.0
@export_range(0.05, 0.3) var wall_slide_grace_time := 0.1

var current_state: State = State.GROUND
var direction_x := 0.0 # input direction at any time
var current_gravity := 0.0
var jump_count: int = 0
var wall_slide_grace_timer := 0.0

@onready var jump_speed: float = calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity: float = calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity: float = calculate_fall_gravity(jump_height, jump_time_to_descent)
@onready var jump_horizontal_speed: float = calculate_jump_horizontal_speed(
	jump_horizontal_distance, jump_time_to_peak, jump_time_to_descent
)

@onready var double_jump_speed := calculate_jump_speed(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_gravity := calculate_jump_gravity(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_fall_gravity := calculate_fall_gravity(
	double_jump_height, double_jump_time_to_descent
)

@onready var wall_jump_speed := calculate_jump_speed(wall_jump_height, jump_time_to_peak)
@onready var wall_jump_horizontal_speed := calculate_jump_horizontal_speed(
	wall_jump_horizontal_distance, jump_time_to_peak, jump_time_to_descent
)

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var coyote_timer := Timer.new()
@onready var input_buffering_timer := Timer.new()
@onready var wall_raycast_right := RayCast2D.new()
@onready var wall_raycast_left := RayCast2D.new()

func  _ready() -> void:
	_transition_to_state(current_state)
	
	coyote_timer.wait_time = coyote_wait_time
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	
	input_buffering_timer.wait_time = input_buffering_wait_time
	input_buffering_timer.one_shot = true
	add_child(input_buffering_timer)
	
	# wall jump raycast
	wall_raycast_left.target_position = Vector2.LEFT * 10
	wall_raycast_right.target_position = Vector2.RIGHT * 10
	add_child(wall_raycast_left)
	add_child(wall_raycast_right)

func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("move_left", "move_right"))
	
	match current_state:
		State.GROUND:
			process_ground_state(delta)
		State.JUMP:
			process_jump_state(delta)
		State.DOUBLE_JUMP:
			process_double_jump_state(delta)
		State.FALL:
			process_fall_state(delta)
		State.WALL_JUMP:
			process_wall_jump_state(delta)
		State.WALL_SLIDE:
			process_wall_slide_state(delta)
		State.PUSH:
			process_push_state(delta)
		State.PULL:
			process_pull_state(delta)
	
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

func process_jump_state(delta: float) -> void:
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
	
	if is_against_wall() and direction_x == get_wall_direction():
		_transition_to_state(State.WALL_SLIDE)
	elif velocity.y >= 0.0: # just before moving down change to fall
		_transition_to_state(State.FALL)
	elif Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		_transition_to_state(State.DOUBLE_JUMP)

func process_fall_state(delta: float) -> void:
	if direction_x != 0:
		# move to max speed considering air movement limitations
		velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		# updating visuals
		animated_sprite.flip_h = direction_x < 0.0
		
	if is_against_wall() and direction_x == get_wall_direction():
		_transition_to_state(State.WALL_SLIDE)
	elif is_on_floor():
		_transition_to_state(State.GROUND)
	elif Input.is_action_just_pressed("jump"):
		if not coyote_timer.is_stopped():
			_transition_to_state(State.JUMP)
		elif jump_count < MAX_JUMPS:
			_transition_to_state(State.DOUBLE_JUMP)
	
func process_double_jump_state(delta: float) -> void:
	if direction_x != 0:
		# move to max speed considering air movement limitations
		velocity.x += direction_x * air_acceleration * delta # change in velocity — acceleration!
		velocity.x = clampf(velocity.x, -jump_horizontal_speed, jump_horizontal_speed)
		# updating visuals
		animated_sprite.flip_h = direction_x < 0.0
	
	if velocity.y >= 0.0: # just before moving down change to fall
		_transition_to_state(State.FALL)
		
func process_wall_jump_state(delta: float) -> void:
	if direction_x != 0.0:
		velocity.x += direction_x * air_acceleration * delta # add incrementally
		velocity.x = clamp(velocity.x, -wall_jump_horizontal_speed, wall_jump_horizontal_speed)
		animated_sprite.flip_h = direction_x < 0.0
	
	if Input.is_action_just_released("jump"):
		var jump_cut_speed := wall_jump_speed / jump_cut_divider
		if velocity.y < 0.0 and velocity.y < jump_cut_speed:
			velocity.y = jump_cut_speed

	if velocity.y >= 0.0:
		_transition_to_state(State.FALL)

func process_wall_slide_state(delta: float) -> void:
	if velocity.y > 0.0:
		velocity.y = move_toward(velocity.y, 0.0, wall_slide_friction * delta)
		velocity.y = clampf(velocity.y, 0.0, wall_slide_speed)
	else:
		velocity.y = move_toward(velocity.y, 0.0, wall_slide_friction * delta)
	
	if is_on_floor():
		_transition_to_state(State.GROUND)
	elif Input.is_action_just_pressed("jump"):
		_transition_to_state(State.WALL_JUMP)
	elif not (is_against_wall() and signf(direction_x) == get_wall_direction()):
		if wall_slide_grace_timer <= 0.0:
			wall_slide_grace_timer = wall_slide_grace_time
		wall_slide_grace_timer -= delta
		if wall_slide_grace_timer <= 0.0:
			_transition_to_state(State.FALL)
	else:
		wall_slide_grace_timer = 0.0

func process_pull_state(_delta: float) -> void:
	pass
	
func process_push_state(_delta: float) -> void:
	pass

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
		State.WALL_JUMP:
			velocity.y = wall_jump_speed
			current_gravity = jump_gravity
			velocity.x = -1.0 * get_wall_direction() * wall_jump_horizontal_speed
			animated_sprite.flip_h = velocity.x < 0.0
			animated_sprite.play("jump")
		State.WALL_SLIDE:
			current_gravity = fall_gravity
			animated_sprite.play("fall")
			animated_sprite.flip_h = get_wall_direction() < 0.0
			wall_slide_grace_timer = 0

func is_against_wall() -> bool:
	return wall_raycast_left.is_colliding() or wall_raycast_right.is_colliding()
	
func get_wall_direction() -> float:
	if wall_raycast_left.is_colliding():
		return -1.0
	elif wall_raycast_right.is_colliding():
		return 1.0
	else:
		return 0.0

func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return -2.0 * height / time_to_peak

func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func calculate_fall_gravity(height: float, time_to_peak: float) -> float:
	return 2.0 * height / pow(time_to_peak, 2)

func calculate_jump_horizontal_speed(distance: float, time_to_peak: float, time_to_decent) -> float:
	return distance / (time_to_peak + time_to_decent)
