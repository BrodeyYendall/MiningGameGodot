extends Node2D
class_name OreChunk

var ores = []

func generate_with_config(config: Constants.OreChunkConfig):
	var fail_count = 0
	while ores.size() <= config.max_ore and fail_count <= config.max_fails:
		var rand_position = Vector2(randi_range(0, config.width), randi_range(0, config.width))
		var conflicting_position = false
		
		for existing_ore in ores:
			if existing_ore.position.distance_to(rand_position) < config.density:
				conflicting_position = true
				break
		
		if conflicting_position:
			fail_count += 1
		else:
			var ore = config.ore_type.instantiate()
			ore.generate_ore(randi_range(config.ore_width[0], config.ore_width[1]))
			ore.position = rand_position
			ores.append(ore)
			add_child(ore)
