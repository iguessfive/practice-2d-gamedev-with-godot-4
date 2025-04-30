@tool
class_name Turret extends Sprite2D

@export var weapon_scene: PackedScene = preload("weapons/simple_cannon.tscn"): set = set_weapon_scene

var weapon: Weapon = null
var level := 1

func _ready() -> void:
	set_weapon_scene(weapon_scene)
	texture = preload("res://turrets/turret_base.png")


func set_weapon_scene(new_scene: PackedScene) -> void:
	weapon_scene = new_scene

	#ANCHOR: remove_weapon
	if weapon != null:
		weapon.queue_free()
		#END: remove_weapon

	#ANCHOR: add_weapon
	if weapon_scene != null:
		var weapon_instance := weapon_scene.instantiate()
		assert(
			weapon_instance is Weapon,
			"The weapon scene must inherit from Weapon."
		)
		add_child(weapon_instance)
		weapon = weapon_instance
		#END: add_weapon

const DAMAGE_UPGRADE = preload("upgrades/damage_upgrade.tres")
const FIRE_RATE_UPGRADE = preload("upgrades/fire_rate_upgrade.tres")
const RANGE_UPGRADE = preload("upgrades/range_upgrade.tres")

func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("left_mouse_click") and
		get_global_mouse_position().distance_to(global_position) < 60.0
	):
		DAMAGE_UPGRADE.apply_to_turret(self)
		print("Applied damage upgrade. New damage: ", weapon.stats.damage)
		FIRE_RATE_UPGRADE.apply_to_turret(self)
		print("Applied fire rate upgrade. New rate: ", weapon.stats.attack_rate)
		RANGE_UPGRADE.apply_to_turret(self)
		print("Applied range upgrade. New radius: ", weapon.stats.mob_detection_radius)
