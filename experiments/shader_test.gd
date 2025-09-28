extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var window_size = Vector2(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
	var image = Image.create(window_size.x, window_size.y, false, Image.FORMAT_RGBA8)
	for x in range(window_size.x):
		for y in range(window_size.y):	
			image.set_pixel(x, y, Color.SEA_GREEN)
	texture = ImageTexture.create_from_image(image)

func _input(event):
	if event is InputEventKey and event.is_pressed() && not event.is_echo():
		match event.keycode:
			KEY_SPACE:
				material.set_shader_parameter("polygon_points", PackedVector2Array([
					Vector2(200, 200), Vector2(250, 150), Vector2(300, 200),
					Vector2(400, 200), Vector2(450, 150), Vector2(500, 200)
				]))
				material.set_shader_parameter("polygon_indices", [0, 3, 6])
				material.set_shader_parameter("polygon_count", 3)
				queue_redraw()
