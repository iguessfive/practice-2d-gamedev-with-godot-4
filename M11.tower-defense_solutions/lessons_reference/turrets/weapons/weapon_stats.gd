## This resource represents one turret's stats. It compiles information that the
## turret weapon and the turret itself need to function. It's also passed to
## menus for display purposes.
class_name WeaponStats extends Resource


## The weapon's attack range in pixels.
@export_range(80.0, 1000.0) var mob_detection_radius := 200.0: set = set_mob_detection_radius
## Number of times the turret can attack per second.
@export_range(0.1, 10.0) var attack_rate := 1.0: set = set_attack_rate
## The amount of damage the turret's weapon deals, if it deals damage.
@export var damage := 10.0
## How fast the weapon can rotate in radians per second.
@export var max_rotation_speed := 2.0 * PI
## If the weapon applies a status effect, this represents how strongly the effect is applied.
## This value is interpreted by the weapon itself.
@export var effect_intensity := 0.3
## How long a status effect applied by this turret's weapon lasts, in seconds.
@export var effect_duration := 0.5


func set_mob_detection_radius(new_radius: float) -> void:
	mob_detection_radius = new_radius
	emit_changed()


func set_attack_rate(new_rate: float) -> void:
	attack_rate = maxf(new_rate, 0.1)
	emit_changed()
