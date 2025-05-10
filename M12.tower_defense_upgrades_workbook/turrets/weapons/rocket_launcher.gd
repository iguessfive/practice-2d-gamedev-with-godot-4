class_name RocketLauncher extends Weapon

var _target: Mob = null

@onready var _marker_2d: Marker2D = %Marker2D

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if _target == null:
		_target = _find_closest_target()
	
	if _target != null:
		look_at(_target.global_position)

func _attack() -> void:
	if _target == null:
		return
		
	var homing_rocket = preload("res://turrets/weapons/projectiles/homing_rocket.tscn").instantiate()
	get_tree().current_scene.add_child(homing_rocket)
	homing_rocket.global_transform = _marker_2d.global_transform # global
	
	homing_rocket.target = _target
	homing_rocket.damage = stats.damage
	return
