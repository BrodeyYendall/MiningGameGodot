extends Resource
class_name OreStats

@export var name = ""
@export var base_sharpness: int = 0
@export var base_durability: int = 0
@export var base_weight: int = 0
@export var base_power: int = 0
@export var multiplier_sharpness: float = 1.0
@export var multiplier_durability: float = 1.0
@export var multiplier_weight: float = 1.0
@export var multiplier_power: float = 1.0
@export var critical_mass: int = 0

func _to_string():
	return "{%s, %s * %s, %s * %s, %s * %s, %s * %s, @ %s}" % [name, base_sharpness, 
		multiplier_sharpness, base_durability, multiplier_durability, 
		base_weight, multiplier_weight, base_power, multiplier_power, critical_mass]
