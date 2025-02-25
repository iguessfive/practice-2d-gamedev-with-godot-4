extends Control

signal health_depleted

var health: int = 5: set = set_health

@onready var _hearts_h_box_container: HBoxContainer = %HeartsHBoxContainer

func _ready() -> void:
	if Global.is_debugging:
		print_debug(health)
	
	set_health(health)
	
func set_health(new_health: int):
	# clamp the new_health between 0 anf 5
	health = clampi(new_health, 0, 5)
	
	if health == 0:
		health_depleted.emit()
	
	# updates the ui 
	for child in _hearts_h_box_container.get_children():
		child.visible = health > child.get_index()
	
	
