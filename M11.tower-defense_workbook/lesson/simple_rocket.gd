@icon("res://icons/icon_rocket.svg")
class_name Rocket extends Area2D

@export var speed:float = 600.0
@export var max_distance:float = 600.0
@export var damage:float = 20.0

var _distance_travelled:float = 0.0

func _init() -> void:
	monitorable = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _physics_process(delta: float) -> void:
	var velocity: = transform.x * speed # based on parent rotation
	var motion: = velocity * delta
	position += motion # pixels per frame
	
	_distance_travelled += motion.length()
	
	if _distance_travelled >= max_distance:
		_distance_travelled = 0
		_explode()
		
func _explode() -> void:
	queue_free()

func _on_area_entered(other_area: Area2D) -> void:
	var mob := other_area as Mob
	if mob != null:
		mob.take_damage(damage)

		_explode()
	

	
	
	
	 
