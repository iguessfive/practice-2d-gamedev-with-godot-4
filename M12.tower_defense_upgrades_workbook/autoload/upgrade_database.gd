extends Node

const ROCKET_LAUNCHER = preload("res://turrets/upgrades/rocket_launcher.tres")
const DAMAGE = preload("../turrets/upgrades/damage_upgrade.tres")
const FIRE_RATE = preload("../turrets/upgrades/fire_rate_upgrade.tres")
const RANGE = preload("../turrets/upgrades/range_upgrade.tres")

func get_upgrades_for_weapon(weapon: Weapon, turret_level: int) -> TurretUpgrade:
	if weapon is SimpleCannon:
		if turret_level == 1:
			return DAMAGE
		elif turret_level == 2:
			return FIRE_RATE
		elif turret_level == 3:
			return RANGE
		elif turret_level == 4:
			return ROCKET_LAUNCHER
	return null
