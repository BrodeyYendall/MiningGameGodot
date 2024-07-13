extends Sprite2D

@export var fall_speed = 500
@export var rotate_speed = 0.5

var cutout_vertices: PackedVector2Array
var viewport_image: Image

func with_data(cutout_vertices: PackedVector2Array, viewport_image: Image) -> Node2D:
	self.cutout_vertices = cutout_vertices
	self.viewport_image = viewport_image
	return self
	
func _ready():
	assert(not cutout_vertices.is_empty(), "cutout created with vertices, please call with_data().")
	
	var bounding_box = get_cutout_bounding_box()
	var x_width = bounding_box[1] - bounding_box[0]
	var y_width = bounding_box[3] - bounding_box[2]
	
	var image = Image.create(x_width, y_width, false, Image.FORMAT_RGBA8)
	image.set_pixel(0, 0, Color(0, 0, 0, 0)) # Set transparency outside the polygon
	
	for y in range(y_width):
		for x in range(x_width):
			var world_x = x + bounding_box[0]
			var world_y = y + bounding_box[2]
			var inside_polygon = Geometry2D.is_point_in_polygon(Vector2(world_x, world_y), cutout_vertices)
			if inside_polygon:
				var color = viewport_image.get_pixel(world_x, world_y)
				image.set_pixel(x, y, color)
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0)) # Set transparency outside the polygon
				
	texture = ImageTexture.create_from_image(image)
	position = Vector2(bounding_box[0] + (x_width / 2), bounding_box[2] + (y_width / 2))
	
	
func _process(delta):
	position.y += fall_speed * delta
	rotation += rotate_speed * delta
	if position.y > 1080:
		queue_free()
	
func get_cutout_bounding_box() -> Array[int]:
	var x_min = cutout_vertices[0].x
	var x_max = cutout_vertices[0].x
	var y_min = cutout_vertices[0].y
	var y_max = cutout_vertices[0].y
	
	for vertex in cutout_vertices:
		if vertex.x < x_min:
			x_min = vertex.x
		else:
			x_max = max(x_max, vertex.x)
			
		if vertex.y < y_min:
			y_min = vertex.y
		else:
			y_max = max(y_max, vertex.y)
			
	return [x_min, x_max, y_min, y_max]
	
func remove_mins(bounding_box: Array[int]):
	var result = PackedVector2Array()
	for vertex in cutout_vertices:
		result.append(Vector2(vertex.x - bounding_box[0], vertex.y - bounding_box[2]))
	return result
