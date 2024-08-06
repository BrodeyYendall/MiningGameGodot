extends Resource
class_name OreTableRow

@export var oreType: OreTypes.OreType
@export var weight: int
@export var density: int

func _init(oreType: OreTypes.OreType, weight: int, density: int):
	self.oreType = oreType
	self.weight = weight
	self.density = density

func _to_string():
	return "{oreType=%s, weight:%s, density=%s}" % [OreTypes.get_ore_name(oreType), weight, density]
