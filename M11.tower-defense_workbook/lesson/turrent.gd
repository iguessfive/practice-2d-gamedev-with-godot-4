@tool
class_name Turret extends Sprite2D

# create an export variable to hold weapon_scene with a setter and preload with a scene
@export var weapon_scene: PackedScene = preload("res://lesson/simple_cannon.tscn"): set = set_weapon_scene

# create a variable to hold the active weapon 
var weapon: Weapon = null

func _ready() -> void:
	texture = preload("res://turrets/turret_base.png")
	
	set_weapon_scene(weapon_scene)

# create the setter function that takes in a new_scene as parameter and returns nothing
func set_weapon_scene(new_scene: PackedScene) -> void:
	# assign the argument to the weapon_scene
	weapon_scene = new_scene
	
	# if the weapon already has a wepaon, free it
	if weapon != null:
		weapon.queue_free()

	# if the weapon_scne is not empty
	if weapon_scene != null:
		 # then, create an instance and store it in variable of weapon instance
		var weapon_instance = weapon_scene.instantiate()
		# now, check if the weapon_instance is a weapon, otherwise crash/stop run-time of game
		assert(
			weapon_instance is Weapon,
			"The weapon scene does not inherit from Weapon"
		)
		# add the instance as a child of turrent
		add_child(weapon_instance)
		# and assign the weapon instance to weapon property of turrent 
		weapon = weapon_instance
		queue_redraw()
	
	
