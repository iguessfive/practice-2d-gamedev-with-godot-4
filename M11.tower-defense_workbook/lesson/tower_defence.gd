extends Node2D

# adding turrents to game based on mouse clickes 

var _game_board: Dictionary = {}

@onready var _player_hurt_box: Area2D = %PlayerHurtBox
@onready var _roads: TileMapLayer = %Roads

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
	
	_place_turret(Vector2i(1, 1))
	_place_turret(Vector2i(2, 3))
	_place_turret(Vector2i(4, 2))
	print(_game_board)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click"):
		var cell_coordinate = _roads.local_to_map(get_global_mouse_position())
		if (
			not _game_board.has(cell_coordinate)
			and _roads.get_cell_source_id(cell_coordinate) == -1
		):
			_place_turret(cell_coordinate)

# function to add turrents to game board
func  _place_turret(cell_coordinates: Vector2i) -> void:
	var turrent_instance = Turret.new()
	add_child(turrent_instance)
	turrent_instance.global_position = _roads.map_to_local(cell_coordinates)
	
	_game_board[cell_coordinates] = turrent_instance
