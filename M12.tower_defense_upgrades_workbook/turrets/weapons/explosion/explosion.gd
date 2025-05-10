extends Area2D

var damage: float = 1.0

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	_animated_sprite_2d.play("explode")
	_animated_sprite_2d.animation_finished.connect(queue_free)
	
	await get_tree().physics_frame
	
	for area in get_overlapping_areas():
		if area is Mob:
			area.take_damage(damage)
