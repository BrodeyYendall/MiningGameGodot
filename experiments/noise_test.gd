extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():		
	var image = Image.create(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, false, Image.FORMAT_RGBA8)
				
	var map: Array = create_background_matrix(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

	for x in range(Constants.SCREEN_WIDTH):
		for y in range( Constants.SCREEN_HEIGHT):
			map[y][x] = randi_range(0, 1)
			
	for iteration in range(1):
		var updated_map = map.duplicate(true)
		for x in range(Constants.SCREEN_WIDTH):
			for y in range(Constants.SCREEN_HEIGHT):
				var sum = get_tile_sum(map, x, y, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
				
				var atlasTarget: Vector2
				if sum <= 4:
					updated_map[y][x] = 0
				else:
					updated_map[y][x] = 1
		map = updated_map
	
	for x in range(Constants.SCREEN_WIDTH):
		for y in range(Constants.SCREEN_HEIGHT):
			var color: Color
			if map[y][x] == 0:
				color = Color.WHITE
			else:
				color = Color.BLACK
			image.set_pixel(x, y, color)
			
	texture = ImageTexture.create_from_image(image)
	
func get_tile_sum(map:Array, x: int, y:int, width: int, height: int):
	var sum = 0
	
	for i in range(x - 1, x + 1):
		for j in range(y - 1, y + 1):
				if i < 0 or j < 0 or i >= width	or j >= height:
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
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			get_tree().reload_current_scene()

