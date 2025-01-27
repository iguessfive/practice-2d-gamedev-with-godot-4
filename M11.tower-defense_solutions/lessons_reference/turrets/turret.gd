@tool
class_name Turret extends Node2D

## The weapon to instantiate on the turret. Changing this property replaces the current weapon.
@export var weapon_scene: PackedScene = preload("weapons/simple_cannon.tscn"): set = set_weapon_scene
## The image to display for the turret.
@export var texture: Texture = preload("res://turrets/turret_base.png"): set = set_texture

## The weapon instance attached to the turret.
var weapon: Weapon = null

var _sprite_2d := Sprite2D.new()


func _ready() -> void:
	add_child(_sprite_2d)
	set_weapon_scene(weapon_scene)
	set_texture(texture)
	set_physics_process(not Engine.is_editor_hint())


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if weapon_scene == null:
		warnings.append("The turret has no weapon scene set. The turret will not be able to attack.")
	if texture == null:
		warnings.append("The turret has no texture set. The base of the turret will not be visible.")
	return warnings


func set_weapon_scene(new_scene: PackedScene) -> void:
	weapon_scene = new_scene
	update_configuration_warnings()

	if weapon != null:
		weapon.queue_free()

	if weapon_scene != null:
		weapon = weapon_scene.instantiate()
		add_child(weapon)


func set_texture(new_texture: Texture) -> void:
	texture = new_texture
	update_configuration_warnings()

	if _sprite_2d != null:
		_sprite_2d.texture = texture
