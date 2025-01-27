class_name DamageIndicator extends Node2D

@onready var _label: Label = %Label


func _ready() -> void:
	position.x = randf_range(-32.0, 32.0)


func display_amount(amount: float) -> void:
	_label.text = str(amount)
