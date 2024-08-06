extends NuggetOre

func generate_ore(oreType: OreTypes.OreType, size: float):
	self.oreType = oreType
	generate_vertices_for_dir(Vector2(0, 0), Vector2(1, 0), size, Constants.BAND_ORE_CONFIG)
