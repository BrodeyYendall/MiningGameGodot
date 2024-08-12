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
			return OreChunkConfigs.NUGGET_CONFIG
		OreType.ZINC:
			return OreChunkConfigs.BALL_CONFIG
		OreType.IRON:
			return OreChunkConfigs.BAND_CONFIG
	assert(false, "Failed to get ore config")
	return null
	
func get_crack_generation_config(oreType: OreType) -> Constants.CrackConfig:
	match oreType:
		OreType.COPPER:
			return Constants.NUGGET_ORE_CONFIG
		OreType.IRON:
			return Constants.BAND_ORE_CONFIG
	assert(false, "Failed to get crack generation config")
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
