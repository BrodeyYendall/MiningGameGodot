extends Node2D

var ORE_BORDER_BUFFER = 50
var MAX_ORE_WIDTH = 100

@export var levels: OreSpawnLevels

var ore_chunk_scene = preload("res://ores/ore_chunk.tscn")
				
func _generate_ores(wall_count: int):
	var current_level = get_current_level(wall_count)
		
	var fail_count = 0
	var success_count = 0
	while fail_count <= 10 and success_count < 100:
		var rand_location = Vector2(randi_range(ORE_BORDER_BUFFER, Constants.SCREEN_WIDTH - ORE_BORDER_BUFFER - MAX_ORE_WIDTH), randi_range(ORE_BORDER_BUFFER, Constants.SCREEN_HEIGHT - ORE_BORDER_BUFFER))
		
		var raycast = circle_raycast(rand_location, 100)
		if raycast.is_empty():
			success_count += 1
			create_ore(get_ore_from_table(current_level.ore_table), rand_location)
		else:
			fail_count += 1

func create_ore(oreType: OreTypes.OreType, position: Vector2):
	var config = OreTypes.get_ore_config(oreType)
	var ore = config.ore_type.instantiate()
	ore.generate_ore(oreType, randi_range(config.ore_width[0], config.ore_width[1]))
	ore.position = position
	add_child(ore)
	
	ore.ore_cutout.connect(get_parent()._ore_cutout)
	
func get_current_level(wall_count: int) -> OreSpawn:
	for i in range(levels.levels.size()):
		if levels.levels[i].wall_count_threshold > wall_count:
			return levels.levels[i - 1]
	return levels.levels[-1]
	
func get_ore_from_table(oreTable: Array[OreTableRow]) -> OreTypes.OreType:	
	var rand = randi_range(0, 100)
	for ore in oreTable:
		if rand <= ore.weight:
			return ore.oreType
		rand -= ore.weight
	assert(false, "failed to determine ore from ore table")
	return OreTypes.OreType.UNKNOWN 
	
func circle_raycast(position: Vector2, radius: int, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(radius)
	query.set_shape(circle_shape)
	query.set_collide_with_areas(true)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
	
#@export var LEVELS = {
#	1: [
#		[OreTypes.OreType.COPPER, 100]
#	],
#	3: [
#			[OreTypes.OreType.COPPER, 95],
#			[OreTypes.OreType.ZINC, 5]
#		],
#	5: [
#			[OreTypes.OreType.COPPER, 90],
#			[OreTypes.OreType.ZINC, 10]
#		],
#	8: [
#			[OreTypes.OreType.COPPER, 85],
#			[OreTypes.OreType.ZINC, 15]
#		],
#	10: [
#			[OreTypes.OreType.COPPER, 80],
#			[OreTypes.OreType.ZINC, 20]
#		]
#}
