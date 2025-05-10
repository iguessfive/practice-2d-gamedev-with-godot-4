extends Node2D

#region TESTING
@onready var mobs_in_tree = get_tree().get_nodes_in_group("mob")
@onready var homing_rocket_count = get_tree().get_nodes_in_group("rocket").size()

func _ready() -> void:
	for rocket: HomingRocket in get_tree().get_nodes_in_group("rocket"):
		rocket.target = $Mob # assign mob when
		rocket.tree_exited.connect(func():
			homing_rocket_count -= 1
		)

func _physics_process(delta: float) -> void:
	if mobs_in_tree.size() > 0:
		for mob in mobs_in_tree:
			mob.position += mob.speed * Vector2.RIGHT * delta * 2.0
			
	if homing_rocket_count == 0:
		get_tree().create_timer(0.5).timeout.connect(func():
			get_tree().reload_current_scene()
		)
#endregion
