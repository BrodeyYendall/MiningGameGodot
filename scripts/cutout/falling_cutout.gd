extends Sprite2D
class_name FallingCutout

@export var fall_speed = 200
@export var rotate_speed = 0.5
@export var drop_shadow_offset = Vector2(8, 8)

signal cutout_offscreen(ores: Array[Area2D])

var cutout_vertices: PackedVector2Array
var background_image: Image
var cutout_size: float
var adjusted_cutout_size: float

var width: int
var height: int
var min_x: int
var min_y: int
var rotation_direction: int
var ores: Array[Area2D] = []

func with_data(cutout_vertices: PackedVector2Array, background_image: Image) -> FallingCutout:
	self.cutout_vertices = cutout_vertices
	self.background_image = background_image
	calculate_cutout_bounding_box()
	return self
	
func _ready():
	assert(not cutout_vertices.is_empty(), "cutout created with vertices, please call with_data().")
	rotation_direction = -1 if randi_range(0, 1) == 0 else 1
	
	cutout_size = calculate_area()
	adjusted_cutout_size = cutout_size / 20000
	adjusted_cutout_size = min(2, max(0.75, adjusted_cutout_size))
	
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.set_pixel(0, 0, Color(0, 0, 0, 0)) # Set transparency outside the polygon
	
	for y in range(height):
		for x in range(width):
			var world_pos = Vector2(x, y) + Vector2(min_x, min_y)
			var inside_polygon = Geometry2D.is_point_in_polygon(world_pos, cutout_vertices)
			if inside_polygon:
				var color = background_image.get_pixelv(world_pos)
				image.set_pixel(x, y, color)
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0)) # Set transparency outside the polygon
				
	texture = ImageTexture.create_from_image(image)
	
	var half_width = width / 2
	var half_height = height / 2
	
	position = Vector2(min_x + half_width, min_y + half_height)
	$drop_shadow.prepare_shadow(cutout_vertices, Vector2(min_x, min_y))
	$drop_shadow.position = Vector2(-half_width + drop_shadow_offset.x, -half_height + drop_shadow_offset.y)
	
	
func _process(delta):	
	position.y += fall_speed * delta
	rotation += (rotate_speed * delta * rotation_direction) / adjusted_cutout_size
	if position.y > Constants.SCREEN_HEIGHT + max(height, width):
		queue_free()
		cutout_offscreen.emit(ores)
	
func calculate_cutout_bounding_box():
	min_x = cutout_vertices[0].x
	min_y = cutout_vertices[0].y
	
	var max_x = cutout_vertices[0].x
	var max_y = cutout_vertices[0].y
	
	for vertex in cutout_vertices:
		if vertex.x < min_x:
			min_x = vertex.x
		else:
			max_x = max(max_x, vertex.x)
			
		if vertex.y < min_y:
			min_y = vertex.y
		else:
			max_y = max(max_y, vertex.y)
			
	height = max_y - min_y
	width = max_x - min_x
	
func calculate_area():
	var area = 0.0
	
	for i in range(cutout_vertices.size()):
		var j = (i + 1) % cutout_vertices.size()
		area += cutout_vertices[i].x * cutout_vertices[j].y
		area -= cutout_vertices[j].x * cutout_vertices[i].y
	
	area = abs(area) / 2.0
	return area
	
func add_ore(ore: Area2D):
	ores.append(ore)
	ore.get_parent().remove_child(ore)
	add_child(ore)
	ore.position -= Vector2(min_x, min_y) + (Vector2(width, height) / 2)
	ore.queue_redraw()
