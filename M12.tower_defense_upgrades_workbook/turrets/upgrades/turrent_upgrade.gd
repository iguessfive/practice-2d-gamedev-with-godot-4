class_name TurentUpgrade extends Resource

# cost to upgrade
# what can be upgraded:
	# detection range
	# attack rate
	# damage 
	# the type of weapon

@export var cost := 100

@export_group("Upgrades")
@export var mob_detection_radius_change := 0.0
@export var attack_rate_change := 0.0
@export var damage_change := 0.0
@export var replacement_weapon: PackedScene = null

func apply_to_turret(turrent: Turret) -> void:
	# increase the level of turrent by 1
	turrent.level += 1
	# upgarde the turrent passed in by the values in this turrent upgrade resource
	# upgrate the mob dection radius by amount
	# upgrade the attack rate
	# upgrate the damage change
	turrent.weapon.stats.mob_detection_radius += mob_detection_radius_change
	turrent.weapon.stats.attack_rate += attack_rate_change
	turrent.weapon.stats.damage += damage_change
	
	# only if the replacement weapon is not null
	# then set the weapon to the replacement weapon
	if replacement_weapon != null:
		turrent.set_weapon_scene(replacement_weapon)
	
