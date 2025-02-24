class_name MobSpawner extends Node2D

@export var mob_packed_scene: PackedScene = preload("res://lesson/mob.tscn")
@export var mobs_count: int = 10
@export var spawn_interval: float = 1.0

var _remaining_mobs: int = mobs_count
var _timer: Timer = Timer.new()

@onready var _path: Path2D = get_node("MobPath2D")

func _ready() -> void:
	add_child(_timer)
	_timer.timeout.connect(spawn_mob)
	_timer.wait_time = spawn_interval
	_timer.start()

func spawn_mob():
	var mob_path_follow := MobPathFollow.new()
	_path.add_child(mob_path_follow)
	
	var mob: Mob = mob_packed_scene.instantiate()
	mob_path_follow.add_child(mob)
	mob_path_follow.set_mob(mob)
	
	_remaining_mobs -= 1
	if _remaining_mobs == 0:
		_timer.stop()
	
