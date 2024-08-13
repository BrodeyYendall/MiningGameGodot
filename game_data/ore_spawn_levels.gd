extends Resource
class_name OreSpawnLevels

@export var levels: Array[OreSpawn] = [
	OreSpawn.new(1, 100, 20, [
		OreTableRow.new(OreTypes.OreType.COPPER, 100, 30)
	]),
	OreSpawn.new(3, 100, 20, [
		OreTableRow.new(OreTypes.OreType.COPPER, 95, 30),
		OreTableRow.new(OreTypes.OreType.ZINC, 5, 50)
	]),
	OreSpawn.new(5, 100, 20, [
		OreTableRow.new(OreTypes.OreType.COPPER, 90, 30),
		OreTableRow.new(OreTypes.OreType.ZINC, 10, 50)
	]),
	OreSpawn.new(8, 100, 20, [
		OreTableRow.new(OreTypes.OreType.COPPER, 80, 30),
		OreTableRow.new(OreTypes.OreType.ZINC, 20, 50)
	]),
	OreSpawn.new(10, 100, 20, [
		OreTableRow.new(OreTypes.OreType.COPPER, 70, 30),
		OreTableRow.new(OreTypes.OreType.ZINC, 30, 50)
	])
]

func _to_string():
	return str(levels)
