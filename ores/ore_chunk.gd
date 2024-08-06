extends Node2D
class_name OreChunk

var oreType: OreTypes.OreType
var ores = []

func generate_with_config(oreType: OreTypes.OreType,  size: int, ore_cutout_callback):
	self.oreType = oreType
	var config = OreTypes.get_ore_config(oreType)
	
	var fail_count = 0
	while ores.size() <= config.max_ore and fail_count <= config.max_fails:
		var rand_position = generate_random_pos_in_cirlce(size - config.ore_width[1])
		var conflicting_position = false
		
		for existing_ore in ores:
			if existing_ore.position.distance_to(rand_position) < config.density:
				conflicting_position = true
				break
		
		if conflicting_position:
			fail_count += 1
		else:
			var ore = config.ore_type.instantiate()
			ore.generate_ore(oreType, randi_range(config.ore_width[0], config.ore_width[1]))
			ore.position = rand_position
			ores.append(ore)
			add_child(ore)
			
			ore.ore_cutout.connect(ore_cutout_callback)
			
func generate_random_pos_in_cirlce(size: int):
	var theta : float = randf() * 2 * PI
	return (Vector2(cos(theta), sin(theta)) * sqrt(randf())) * size
