extends Sprite2D

@export var ROCK_COLORS = {
	1: [Color(0.557, 0.557, 0.557), Color(0.498, 0.498, 0.498), Color(0.466, 0.466, 0.466)]
}

signal image_changed(new_image: Image)

var current_rock_colors = 0
var background_generation_thread: Thread = Thread.new()

func _ready():
	scale = Vector2(8, 8)
	
func with_data(wall_count: int):
	current_rock_colors = ROCK_COLORS[1] # TODO Do this properly by handling this object being reset
	background_generation_thread.start(generate_background.bind(wall_count, Vector2(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT), 
		current_rock_colors))

func render():
	var generated_background = background_generation_thread.wait_to_finish()
	
	texture = generated_background[0]
	texture_filter = CanvasItem.TextureFilter.TEXTURE_FILTER_NEAREST # Changes sprite scaling to stop the texture becoming blurry
	image_changed.emit(generated_background[1])
	
func generate_background(wall_count: int, window_size: Vector2, rock_colors: Array) -> Array:
	window_size /= 4
	var map: Array = create_background_matrix(window_size.x, window_size.y)

	for x in range(window_size.x):
		for y in range(window_size.y):
			var rand = randf()
			if rand >= 0.55:
				map[y][x] = 1
			else:
				map[y][x] = 0
			
	for iteration in range(2):
		var updated_map = create_background_matrix(window_size.x, window_size.y)
		for x in range(window_size.x):
			for y in range(window_size.y):
				var sum = get_tile_sum(map, x, y, window_size.x, window_size.y)
				
				if sum <= 4:
					updated_map[y][x] = 0
				else:
					updated_map[y][x] = 1
		map = updated_map
	
	
	var image = Image.create(window_size.x, window_size.y, false, Image.FORMAT_RGBA8)
	for x in range(window_size.x):
		for y in range(window_size.y):
			var sum = get_tile_sum(map, x, y, window_size.x, window_size.y)
			
			var color: Color
			if sum <= 4:
				if sum >= 1:
					color = rock_colors[1]
				else:
					color = rock_colors[0]
			else:
				color = rock_colors[2]
				
			image.set_pixel(x, y, color)
	var texture = ImageTexture.create_from_image(image)
	return [texture, image]
	
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

