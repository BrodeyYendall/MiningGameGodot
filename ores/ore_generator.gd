extends Node2D

var ORE_BORDER_BUFFER = 50
var MAX_ORE_WIDTH = 100

@export var levels: OreSpawnLevels
				
func _generate_ores(wall_count: int):
	var current_level = get_current_level(wall_count)
		
	var fail_count = 0
	var success_count = 0
	while fail_count <= 10 and success_count < 100:
		var rand_location = Vector2(randi_range(ORE_BORDER_BUFFER, Constants.SCREEN_WIDTH - ORE_BORDER_BUFFER - MAX_ORE_WIDTH), randi_range(ORE_BORDER_BUFFER, Constants.SCREEN_HEIGHT - ORE_BORDER_BUFFER))
		
		var target_ore = get_ore_from_table(current_level.ore_table)
		var target_ore_config = OreTypes.get_ore_config(target_ore.oreType)
		var target_ore_size = randi_range(target_ore_config.ore_width[0], target_ore_config.ore_width[1])
		
		var raycast = ore_raycast(rand_location, target_ore_size, target_ore.density, target_ore_config.raycast_shape_func)
		if raycast.is_empty():
			success_count += 1
			create_ore(target_ore.oreType, target_ore_config, rand_location)
		else:
			fail_count += 1

func create_ore(oreType: OreTypes.OreType, config: OreChunkConfigs.OreChunkConfig, ore_position: Vector2):
	var ore = config.ore_type.instantiate()
	ore.create(oreType, randi_range(config.ore_width[0], config.ore_width[1]))
	ore.position = ore_position
	add_child(ore)
	
	ore.ore_cutout.connect(get_parent()._ore_cutout)
	
func get_current_level(wall_count: int) -> OreSpawn:
	for i in range(levels.levels.size()):
		if levels.levels[i].wall_count_threshold > wall_count:
			return levels.levels[i - 1]
	return levels.levels[-1]
	
func get_ore_from_table(oreTable: Array[OreTableRow]) -> OreTableRow:	
	var rand = randi_range(0, 100)
	for ore in oreTable:
		if rand <= ore.weight:
			return ore
		rand -= ore.weight
	assert(false, "failed to determine ore from ore table")
	return null
	
func ore_raycast(position: Vector2, size: int, density: int, raycast_shape_func: Callable, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = raycast_shape_func.call(size, density)
	query.set_shape(shape)
	query.set_collide_with_areas(true)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
