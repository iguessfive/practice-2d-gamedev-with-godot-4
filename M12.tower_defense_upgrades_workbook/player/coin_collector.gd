extends Area2D

func _ready() -> void:
	area_entered.connect(func(other_area: Area2D) -> void:
		if other_area is Coin:
			(other_area as Coin).animate_to_ui()
		
		# when on item increase scale to make a hovering like effect
		)
		

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()
