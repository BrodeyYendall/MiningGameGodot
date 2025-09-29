extends Node2D

var ORE_BORDER_BUFFER = 50
var MAX_ORE_WIDTH = 100

@export var levels: OreSpawnLevels

var collision_layer: int = 1

var ore_script = preload("res://scripts/ores/Ore.cs")


func set_collision_layer(layer: int):
	collision_layer = layer
	for child in get_children():
		child.set_collision_layer(layer)
		child.set_collision_mask(layer)
				
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
	var oreSize = randi_range(config.ore_width[0], config.ore_width[1])
	var ore = ore_script.new().Create(oreSize, ore_position, collision_layer)
	add_child(ore)
	
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
	var shape = raycast_shape_func.call(size, density)
	return RaycastHelper.raycast_shape(position, shape, collision_layer, max_results)
