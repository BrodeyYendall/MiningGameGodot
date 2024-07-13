extends TileMap

@export var deep_rock_level = 0.30
@export var rock_level = 0.10
@export var rock_trim_level = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_wall()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_SPACE):
		get_tree().reload_current_scene()
	
func generate_wall():
	var noise = FastNoiseLite.new()
	noise.set_seed(randi())
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX)
	
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
					if randi_range(0, 0) == 0:
						atlasTarget = Vector2(0, 2)
					else:
						atlasTarget = Vector2(0, 1)
					
				
			set_cell(0, Vector2(x, y), 0, atlasTarget)
	
