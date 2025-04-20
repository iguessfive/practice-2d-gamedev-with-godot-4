class_name Coin extends Area2D

# tween 
var tween: Tween = null
# in ready 

func _ready() -> void:
	var random_angle: float = randf() * 2 * PI
	var jump_distance: float = 40 + randf() * 40
	var target_global_position := Vector2.from_angle(random_angle) * jump_distance + global_position
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", target_global_position, 0.5)
	
func animate_to_ui() -> void:
	# animate the coin going to ui target location and update count at end
	if tween != null:
		tween.kill()
		
	var target_position = PlayerUI.get_coin_ui_position()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, 0.7)
	tween.finished.connect(func() -> void:
		PlayerUI.coins += 10
		queue_free()
	)
