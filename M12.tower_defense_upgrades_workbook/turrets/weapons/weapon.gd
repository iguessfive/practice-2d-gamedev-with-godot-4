## Base class for weapons. It provides functions and nodes that weapons can use.
## Different weapons will act differently, so you need to extend this class to
## create a functional weapon. For example, not all weapons will shoot bullets,
## target and rotate toward mobs in the same way, or deal damage. A weapon may
## slow down mobs, apply status effects, or boost surrounding turrets.
##
## That's why this class doesn't provide default behavior or variables to track
## a current target.
#ANCHOR:class_name
@icon("res://icons/icon_weapon.svg")
class_name Weapon extends Sprite2D
#END:class_name

const PHYSICS_LAYER_MOBS = 2

var stats := WeaponStats.new(): set = _set_stats

var _area_2d := _create_area_2d()
var _collision_shape_2d := _create_collision_shape_2d()
var _timer := _create_timer()

func _set_stats(new_stats: WeaponStats) -> void:
	# if the stats are empty
	# then chek is the stat changed signal is connected
	# if so then disconnet the the `update from stats` function
	
	# assign stats to passed in argument new_stats
	# check if stats is not empty
	# connect the stats changed to command func
	
	if stats != null:
		if stats.changed.is_connected(_update_from_stats):
			stats.changed.disconnect(_update_from_stats)
	
	stats = new_stats
	if stats != null: # checking if the resource exsits
		stats.changed.connect(_update_from_stats)
		
	
func _update_from_stats() -> void:
	# update the nodes based on data 
	# assign attack rate to timer wait time
	_timer.wait_time = 1.0 / stats.attack_rate
	# collision shape radius to mob detection range
	(_collision_shape_2d.shape as CircleShape2D).radius = stats.mob_detection_radius

func _ready() -> void:
	#ANCHOR:add_area
	add_child(_area_2d)
	#END:add_area
	#ANCHOR:add_collision_shape
	_area_2d.add_child(_collision_shape_2d)
	#END:add_collision_shape

	#ANCHOR:add_timer
	add_child(_timer)
	_timer.start()
	#END:add_timer
	#ANCHOR:connect_timer
	_timer.timeout.connect(_attack)
	#END:connect_timer

	#ANCHOR:z_index
	z_index = 10
	#END:z_index
	
	_set_stats(stats)
	_update_from_stats() # called only when changed, so needed at start

func _create_area_2d() -> Area2D:
	var area := Area2D.new()
	area.monitoring = true
	area.monitorable = false
	return area

func _create_collision_shape_2d() -> CollisionShape2D:
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = stats.mob_detection_radius
	return collision_shape


func _create_timer() -> Timer:
	var timer := Timer.new()
	timer.wait_time = 1.0 / stats.attack_rate
	return timer


## Virtual method. Called when it's time to attack.
func _attack() -> void:
	return


func _find_closest_target()-> Mob:
	var targets = _area_2d.get_overlapping_areas()
	
	var closest_target: Mob = null
	var smallest_distance = INF
	
	for target: Area2D in targets:
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target < smallest_distance:
			closest_target = target as Mob
			smallest_distance = distance_to_target
	
	return closest_target
	


func _rotate_toward_target(target: Mob) -> void:
	var target_angle := global_position.angle_to_point(target.global_position)
	rotation = rotate_toward(
		rotation,
		target_angle,
		stats.max_rotation_speed * get_physics_process_delta_time()
	)
