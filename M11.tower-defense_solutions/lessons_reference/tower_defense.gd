extends Node2D

## Dictionary mapping cell coordinates to turret instances.
var _game_board := {}

@onready var _roads: TileMapLayer = %Roads
@onready var _player_hurtbox: Area2D = %PlayerHurtbox


func _ready() -> void:
	#ANCHOR:lose_health
	_player_hurtbox.area_entered.connect(
		func (_other_area: Area2D) -> void:
			PlayerUI.health -= 1
	)
	#END:lose_health
	#ANCHOR:health_depleted
	PlayerUI.health_depleted.connect(
		func() -> void:
			get_tree().reload_current_scene.call_deferred()
	)
	#END:health_depleted


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click"):
		var cell_coordinates := _roads.local_to_map((event as InputEventMouseButton).position)
		# Ensure the tile is not a road
		var cell_contents := _roads.get_cell_source_id(cell_coordinates)
		if cell_contents != -1:
			return

		if not _game_board.has(cell_coordinates):
			_place_turret(cell_coordinates)


func _place_turret(cell_coordinates: Vector2i) -> void:
	var turret_instance := Turret.new()
	add_child(turret_instance)
	turret_instance.global_position = _roads.map_to_local(cell_coordinates)

	_game_board[cell_coordinates] = turret_instance
