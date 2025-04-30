extends Node2D

## Dictionary mapping cell coordinates to turret instances.
var _game_board: Dictionary[Vector2i, Turret] = {}

@onready var _roads: TileMapLayer = %Roads
@onready var _player_hurtbox: Area2D = %PlayerHurtbox


func _ready() -> void:
	PlayerUI.coins = 10000
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
			PlayerUI.health = 5
	)
	#END:health_depleted
	
	for current_child: Node in get_children():
		if current_child is MobSpawner:
			var path: PackedVector2Array = _roads.find_path_to_target(current_child, _player_hurtbox)
			current_child.initialise_path(path)


func _unhandled_input(event: InputEvent) -> void:
	#ANCHOR: check_coordinates
	if event.is_action_pressed("left_mouse_click"):
		var cell_coordinates := _roads.local_to_map(get_global_mouse_position())
		#END: check_coordinates

		#ANCHOR: check_valid_cells
		#ANCHOR: M02B_L07_cell_contents
		var cell_contents := _roads.get_cell_source_id(cell_coordinates)
		var is_road_tile := cell_contents != -1
		#END: M02B_L07_cell_contents
		#ANCHOR: M02B_L07_is_road_tile
		if is_road_tile:
			return
			
		if not _game_board.has(cell_coordinates):
			_request_new_turret(cell_coordinates)
		else:
			_request_turret_upgrade(cell_coordinates)
			#END: M02B_L07_is_road_tile
		#END: check_valid_cells

func _request_turret_upgrade(cell_coordinates: Vector2i) -> void:
	pass
	# get turrent at cell coordiante from game board and store in variable
	var turrent = _game_board[cell_coordinates]
	# get the upgrade object from database for turrent and pass turrent level store in varaiable
	var upgrade = UpgradeDatabase.get_upgrades_for_weapon(turrent.weapon, turrent.level)
	# if upgrade is not empty and player has enough coins for upgrade 
	if upgrade != null and PlayerUI.coins >= upgrade.cost:
		# subtract upgrade cost from coins
		PlayerUI.coins -= upgrade.cost
		# and apply upgrade and pass the turrent to method 
		upgrade.apply_to_turret(turrent)
	
	_spawn_stars(turrent.global_position)


func _request_new_turret(cell_coordinates: Vector2i) -> void:
	pass
	# create a const of turret cost at 200
	const TURRET_COST = 200
	# check is the player does not have enough coins return
	if PlayerUI.coins < TURRET_COST:
		return
	# player has enough coins, subtract the turret cost for turret
	PlayerUI.coins -= TURRET_COST
	# create a turret instance and store in variable
	var turret_instance := Turret.new()
	# add it to scene tree by adding it to this node
	add_child(turret_instance)
	# assign the global position of turret to grid of the _road tilemaps by using passed in cell coord
	turret_instance.global_position = _roads.map_to_local(cell_coordinates)
	# store the position is taken on game board by pair cell coord with turrent instance
	_game_board[cell_coordinates] = turret_instance
	_spawn_stars(turret_instance.global_position)
	
func _spawn_stars(target_global_position: Vector2) -> void:
	pass
	# instance the particle effect and store in variable
	var stars = preload("res://turrets/upgrades/star_particles.tscn").instantiate()
	# add to node
	add_child(stars)
	# set global position to parameter passed in 
	stars.global_position = target_global_position
	# when particle is finished free the instance
	stars.finished.connect(stars.queue_free)
	# ?? restart 
	stars.restart()
	
