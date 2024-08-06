extends Node2D

var ORE_BORDER_BUFFER = 200

var ore_chunk_scene = preload("res://ores/ore_chunk.tscn")

func _generate_ores(wall_count: int):
	var current_level = get_current_level(wall_count)
		
	for oreSpawn in current_level:
		var fail_count = 0
		var success_count = 0
		while fail_count <= oreSpawn.max_fails and success_count < oreSpawn.max_count:
			var rand_location = generate_random_spawn_location(oreSpawn.chunk_size)
			
			var raycast = circle_raycast(rand_location, oreSpawn.hitbox_size)
			if raycast.is_empty():
				success_count += 1
				create_ore_chunk(get_ore_from_table(oreSpawn.ore_table), rand_location, oreSpawn.chunk_size)
			else:
				fail_count += 1
	
func get_current_level(wall_count: int):
	while wall_count > 0:
		if wall_count in LEVELS:
			return LEVELS[wall_count]
		wall_count -= 1
	return LEVELS[1]
	
func generate_random_spawn_location(chunk_size: int) -> Vector2:
	var radius = (chunk_size / 2) + ORE_BORDER_BUFFER
	var rand_x = randi_range(radius, Constants.SCREEN_WIDTH - radius)
	var rand_y = randi_range(radius, Constants.SCREEN_HEIGHT - radius)
	
	return Vector2(rand_x, rand_y)
	
func get_ore_from_table(oreTable: Array) -> OreTypes.OreType:
	var weights_total = 0
	for ore in oreTable:
		weights_total += ore[1]
	
	var rand = randi_range(0, weights_total)
	for ore in oreTable:
		if rand <= ore[1]:
			return ore[0]
		rand -= ore[1]
	assert(false, "failed to determine ore from ore table")
	return OreTypes.OreType.UNKNOWN 
	
func create_ore_chunk(oreType: OreTypes.OreType, postion: Vector2, size: int):
	var ore = ore_chunk_scene.instantiate()  
	ore.generate_with_config(oreType, size, get_parent()._ore_cutout)
	ore.position = postion
	add_child(ore)
	
func circle_raycast(position: Vector2, radius: int, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(radius)
	query.set_shape(circle_shape)
	query.set_collide_with_areas(true)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
	
@export var LEVELS = {
	1: [
		OreSpawn.new(300, 400, 1, 2, [
			[OreTypes.OreType.COPPER, 100]
		])
	],
	3: [
		OreSpawn.new(300, 400, 1, 2, [
			[OreTypes.OreType.COPPER, 100]
		]), 
		OreSpawn.new(200, 300, 2, 2, [
			[OreTypes.OreType.COPPER, 75],
			[OreTypes.OreType.ZINC, 25]
		])
	],
	5: [
		OreSpawn.new(300, 400, 1, 2, [
			[OreTypes.OreType.COPPER, 100]
		]), 
		OreSpawn.new(200, 300, 2, 2, [
			[OreTypes.OreType.COPPER, 75],
			[OreTypes.OreType.ZINC, 25]
		])
	],
	8: [
		OreSpawn.new(300, 400, 1, 2, [
			[OreTypes.OreType.COPPER, 100]
		]), 
		OreSpawn.new(200, 300, 2, 2, [
			[OreTypes.OreType.COPPER, 75],
			[OreTypes.OreType.ZINC, 25]
		])
	],
	10: [
		OreSpawn.new(300, 400, 1, 2, [
			[OreTypes.OreType.COPPER, 50],
			[OreTypes.OreType.ZINC, 50]
		]), 
		OreSpawn.new(200, 300, 2, 2, [
			[OreTypes.OreType.COPPER, 50],
			[OreTypes.OreType.ZINC, 50]
		])
	]
}
