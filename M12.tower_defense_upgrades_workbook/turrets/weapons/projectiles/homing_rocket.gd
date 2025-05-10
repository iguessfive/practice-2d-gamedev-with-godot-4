class_name HomingRocket extends Rocket

var steering_force: float = 6.0
var target: Mob = null
var velocity := Vector2.ZERO # define custom velocity value and increment, storing old velocity here to compare to change

var _last_known_position: Vector2 # store the position the mob last was before exiting

@onready var _smoke_trail_particles: GPUParticles2D = %SmokeTrailParticles
@onready var _missile_flame: Sprite2D = %MissileFlame
@onready var _homing_missile: Sprite2D = %HomingMissile

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:

	if target != null:
		_last_known_position = target.global_position
	
	var direction_to_target: Vector2 = global_position.direction_to(_last_known_position)
	
	var desired_velocity := direction_to_target * speed
	var steering_vector := desired_velocity - velocity
	velocity += steering_vector * steering_force * delta
	position += desired_velocity * delta # change in position over time 
	
	rotation = direction_to_target.angle()
		
	_traveled_distance += speed * delta
	if (
		 _traveled_distance > max_distance
		or global_position.distance_to(_last_known_position) < 5.0 
	):
		_explode()

func _explode() -> void:
	var explosion := preload("res://turrets/weapons/explosion/explosion.tscn").instantiate()
	explosion.damage = damage
	get_tree().current_scene.add_child.call_deferred(explosion)
	explosion.global_position = global_position
	
	set_physics_process(false)
	set_deferred("monitoring", false)
	_smoke_trail_particles.emitting = false
	_missile_flame.hide()
	_homing_missile.hide()
	
	get_tree().create_timer(0.5).timeout.connect(queue_free)
	print(global_position.distance_to(_last_known_position))

func _on_area_entered(other_area: Area2D) -> void:
	if other_area is Mob:
		_explode()

	
	
	
