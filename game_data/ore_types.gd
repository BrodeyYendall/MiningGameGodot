extends Node
enum OreType {COPPER, ZINC, IRON, COAL, ALUMINIUM, NICKEL, MANGANESE, OSMIUM, PLATINUM, UNKNOWN}

func get_ore_name(oreType: OreType) -> String:
	match oreType:
		OreType.COPPER:
			return "Copper"
		OreType.ZINC:
			return "Zinc"
		OreType.IRON:
			return "Iron"
		OreType.COAL:
			return "Coal"
		OreType.ALUMINIUM:
			return "Aluminium"
		OreType.NICKEL:
			return "Nickel"
		OreType.MANGANESE:
			return "Manganese"
		OreType.OSMIUM:
			return "Osmium"
		OreType.PLATINUM:
			return "Platinum"
	assert(false, "Failed to get ore name")
	return "Unkown"
	
func get_ore_config(oreType: OreType) -> OreChunkConfigs.OreChunkConfig:
	match oreType:
		OreType.COPPER:
			return OreChunkConfigs.BALL_CONFIG
		OreType.ZINC:
			return OreChunkConfigs.BALL_CONFIG
	assert(false, "Failed to get ore config")
	return null
	
func get_ore_color(oreType: OreType) -> Color:
	match oreType:
		OreType.COPPER:
			return Color.SADDLE_BROWN
		OreType.ZINC:
			return Color.LIGHT_GRAY
		OreType.IRON:
			return Color.CADET_BLUE
	assert(false, "Failed to get ore color")
	return Color.BLACK
