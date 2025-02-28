extends Node2D

@onready var _player_hurt_box: Area2D = %PlayerHurtBox

func _ready() -> void:
	_player_hurt_box.area_entered.connect(
		func(_other_area: Area2D) -> void:
			PlayerUI.health -= 1
	)
	
	PlayerUI.health_depleted.connect(func():
		# difference between reload_current_scene() and reload_current_scene.call() ?
		get_tree().reload_current_scene.call_deferred()
		PlayerUI.health = 5
	)

	
