extends TileMap

@export var deep_rock_level = 0.30
@export var rock_level = 0.10
@export var rock_trim_level = 0.05

func _on_wall_generate_background(seed: int):
	var noise = FastNoiseLite.new()
	noise.set_seed(seed)
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX_SMOOTH)
	
	var window_size = get_viewport().size / 8
	var map: Array = create_background_matrix(window_size.x, window_size.y)

	for x in range(window_size.x):
		for y in range(window_size.y):
			var rand = randf()
			if rand >= 0.50:
				map[y][x] = 1
			else:
				map[y][x] = 0
			
	for iteration in range(3):
		var updated_map = create_background_matrix(window_size.x, window_size.y)
		for x in range(window_size.x):
			for y in range(window_size.y):
				var sum = get_tile_sum(map, x, y, window_size.x, window_size.y)
				
				var atlasTarget: Vector2
				if sum <= 4:
					updated_map[y][x] = 0
				else:
					updated_map[y][x] = 1
		map = updated_map
	
	for x in range(window_size.x):
		for y in range(window_size.y):
			var atlasTarget: Vector2
			if map[y][x] == 0:
				atlasTarget = Vector2(0, 1)
			else:
				atlasTarget = Vector2(1, 0)
			set_cell(0, Vector2(x, y), 0, atlasTarget)
	
func get_tile_sum(map:Array, x: int, y:int, width: int, height: int):
	var sum = 0

	for i in range(x - 1, x + 2): # + 2 because the upper bound is exclusive
		if i < 0 or i >= width:
			sum += 3
			continue
		
		for j in range(y - 1, y + 2):
				if j < 0 or j >= height:
					sum += 1
				else:
					sum += map[j][i]
	return sum
			
func create_background_matrix(width: int, height: int) -> Array:
	var height_array = []
	height_array.resize(height)
	
	for i in range(height_array.size()):
		var width_array = []
		width_array.resize(width)
		
		height_array[i] = width_array

	return height_array

