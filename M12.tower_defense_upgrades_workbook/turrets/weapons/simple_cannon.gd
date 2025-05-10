class_name SimpleCannon extends Weapon

@onready var _spawn_point: Marker2D = %RocketSpawnPoint

var _target: Mob = null

func _physics_process(_delta: float) -> void:
	if _target == null:
		_target = _find_closest_target()
	
	if _target != null:
		look_at(_target.global_position)


func _attack() -> void:
	var mobs_in_range := _area_2d.get_overlapping_areas()
	if mobs_in_range.is_empty():
		return

	var rocket: Node2D = preload("projectiles/simple_rocket.tscn").instantiate()
	get_tree().current_scene.add_child(rocket)
	rocket.global_transform = _spawn_point.global_transform
