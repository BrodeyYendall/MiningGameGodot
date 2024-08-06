extends Node
enum OreType {COPPER, ZINC, IRON, COAL, ALUMINIUM, NICKEL, MANGANESE, OSMIUM, PLATINUM}

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
	return "Unkown"
	
func get_ore_config(oreType: OreType) -> Constants.OreChunkConfig:
	match oreType:
		OreType.COPPER:
			return Constants.NUGGET_CONFIG
		OreType.ZINC:
			return Constants.BALL_CONFIG
		OreType.IRON:
			return Constants.BAND_CONFIG
	return null
	
func get_ore_color(oreType: OreType) -> Color:
	match oreType:
		OreType.COPPER:
			return Color.SADDLE_BROWN
		OreType.ZINC:
			return Color.LIGHT_GRAY
		OreType.IRON:
			return Color.CADET_BLUE
	return Color.BLACK
	
