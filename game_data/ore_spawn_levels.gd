extends Resource
class_name OreSpawnLevels

@export var levels: Array[OreSpawn] = [
	OreSpawn.new(1, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 100, 15)
	]),
	OreSpawn.new(3, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 95, 15),
		OreTableRow.new(OreTypes.OreType.ZINC, 5, 50)
	]),
	OreSpawn.new(5, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 90, 15),
		OreTableRow.new(OreTypes.OreType.ZINC, 10, 50)
	]),
	OreSpawn.new(8, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 80, 15),
		OreTableRow.new(OreTypes.OreType.ZINC, 20, 50)
	]),
	OreSpawn.new(10, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 70, 15),
		OreTableRow.new(OreTypes.OreType.ZINC, 30, 50)
	])
]

func _to_string():
	return str(levels)
