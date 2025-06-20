@icon("res://icons/icon_weapon.svg")
class_name Weapon extends Sprite2D

@export var mob_detection_range := 400.0
@export var attack_rate:float = 1.0 # projectiles per second (not rate of fire)

var _area_2d := _create_area_2d()
var _collision_shape_2d := _create_collision_shape()
var _timer := _create_timer()

func _init() -> void:
	z_index = 10

func _ready() -> void:
	add_child(_area_2d)
	_area_2d.add_child(_collision_shape_2d)
	add_child(_timer)
	_timer.start()
	_timer.timeout.connect(_attack)

func _create_area_2d() -> Area2D:
	var area := Area2D.new()
	area.monitoring = true
	area.monitorable = false
	return area

func _create_collision_shape() -> CollisionShape2D:
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = mob_detection_range
	
	return collision_shape
	
# create time function pseudo-private
func _create_timer() -> Timer:
	var timer := Timer.new()
	timer.wait_time = 1.0 / attack_rate # if 2, then 2 per second mean one every 0.5 seconds
	return timer

func _attack() -> void:
	return
