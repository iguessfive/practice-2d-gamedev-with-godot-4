@icon("res://icons/icon_mob.svg")
class_name Mob extends Area2D

const NONE = 0.0

@export var max_health:float = 100.0
@export var speed: float = 100.0
#Track the mob's health
var health:float = max_health: set = set_health

@onready var _bar_pivot: Node2D = %BarPivot #?
@onready var _health_bar: ProgressBar = %HealthBar

func _ready() -> void:
	_health_bar.max_value = max_health
	set_health(health)

func _physics_process(_delta: float) -> void:
	_bar_pivot.global_rotation = 0.0

#Update the progress bar to reflect the mob's health
func set_health(new_health):
	health = clamp(new_health, NONE, max_health)
	if _health_bar != null:
		_health_bar.value = health
	if health == NONE:
		_die()


func take_damage(amount: float) -> void:
	health -= amount
	var damage_indicator: DamageIndicator = preload("res://lesson/damage_indicator.tscn").instantiate() 
	get_tree().current_scene.add_child(damage_indicator)
	damage_indicator.global_position = global_position
	damage_indicator.display_amount(amount)

func _die():
	queue_free()
