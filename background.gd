extends TileMap

@export var deep_rock_level = 0.30
@export var rock_level = 0.10
@export var rock_trim_level = 0.05

func _on_wall_generate_background(seed: int):
	var noise = FastNoiseLite.new()
	noise.set_seed(seed)
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX_SMOOTH)
	
	var window_size = get_viewport().size / 8

	for x in range(window_size.x):
		for y in range(window_size.y):
			var atlasTarget: Vector2
			var noiseAtPixel = noise.get_noise_2d(x, y)
			
			if noiseAtPixel > rock_level:
				if noiseAtPixel > deep_rock_level:
					atlasTarget = Vector2(1, 1)
				else:
					atlasTarget = Vector2(1, 0)
			else:
				if noiseAtPixel > rock_trim_level:
					atlasTarget = Vector2(0, 0)
				else:
					if randi_range(0, 1) == 0:
						atlasTarget = Vector2(0, 2)
					else:
						atlasTarget = Vector2(0, 1)
					
				
			set_cell(0, Vector2(x, y), 0, atlasTarget)
