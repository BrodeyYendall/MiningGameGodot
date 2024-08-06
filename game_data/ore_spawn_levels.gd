extends Resource
class_name OreSpawnLevels

@export var levels: Array[OreSpawn] = [
	OreSpawn.new(1, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 100, 50)
	]),
	OreSpawn.new(3, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 95, 50),
		OreTableRow.new(OreTypes.OreType.ZINC, 5, 100)
	]),
	OreSpawn.new(5, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 90, 50),
		OreTableRow.new(OreTypes.OreType.ZINC, 10, 100)
	]),
	OreSpawn.new(8, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 80, 50),
		OreTableRow.new(OreTypes.OreType.ZINC, 20, 100)
	]),
	OreSpawn.new(10, 100, 10, [
		OreTableRow.new(OreTypes.OreType.COPPER, 70, 50),
		OreTableRow.new(OreTypes.OreType.ZINC, 30, 100)
	])
]

func _to_string():
	return str(levels)
