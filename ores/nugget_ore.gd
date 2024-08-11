extends Crack
class_name NuggetOre

var size = 0
var oreType: OreTypes.OreType
signal ore_cutout(ore: OreTypes.OreType, size: int)

var SMOOTH_SEGMENTS = 2
var SMOOTH_INCREMENTS = 2
var MIN_WIDTH = (SMOOTH_INCREMENTS * 2) + 1  # The min distance between the two lines before we end smoothing
	
func generate_ore(oreType: OreTypes.OreType, size: float):
	self.oreType = oreType
	generate_vertices_for_dir(Vector2(0, 0), Vector2(1, 0), size, Constants.NUGGET_ORE_CONFIG)
	
func generate_crack_line(start: Vector2, direction: Vector2, distance: float) -> Array[PackedVector2Array]:
	var crack_lines = super.generate_crack_line(start, direction, distance)
	
	var start_smooth = smooth_tip(crack_lines[0][0], crack_lines[1][0], Vector2(-1, 0))
	start_smooth[0].reverse()
	start_smooth[1].reverse()
	
	var top_line = start_smooth[0]
	var bottom_line = start_smooth[1]
	
	top_line.append_array(crack_lines[0])
	bottom_line.append_array(crack_lines[1])
	
	var end_smooth = smooth_tip(top_line[-1], bottom_line[-1], Vector2(1, 0))
	top_line.append_array(end_smooth[0])
	bottom_line.append_array(end_smooth[1])
	
	return [top_line, bottom_line]
	
func smooth_tip(top: Vector2, bottom: Vector2, direction: Vector2):
	var new_top_line = PackedVector2Array()
	var new_bottom_line = PackedVector2Array()
	
	var current_top = top
	var current_bottom = bottom
	
	while(abs(current_top.distance_to(current_bottom)) > MIN_WIDTH):
		var forward_increment = SMOOTH_SEGMENTS * direction
		
		current_top += randi_range(1, SMOOTH_INCREMENTS) * perpendicular_direction
		current_bottom -= randi_range(1, SMOOTH_INCREMENTS) * perpendicular_direction
		
		current_top += forward_increment
		current_bottom += forward_increment
		
		new_top_line.append(current_top)
		new_bottom_line.append(current_bottom)
		
	return [new_top_line, new_bottom_line]

func calculate_size():
	for i in range(top_line.size()):
		size += bottom_line[i].y - top_line[i].y

func _on_area_entered(area):
	if area is Cutout:
		if size == 0:
			calculate_size()
		ore_cutout.emit(oreType, size)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func _draw():	
	var shortened_vertices = PackedVector2Array()
	
	var bottom_copy = bottom_line.duplicate()
	bottom_copy.reverse()
	
	shortened_vertices.append_array(top_line)
	shortened_vertices.append_array(bottom_copy)
	
	var color = OreTypes.get_ore_color(oreType)
	draw_colored_polygon(shortened_vertices,color)
	
	var outline_vertices = shortened_vertices.duplicate()
	outline_vertices.append(shortened_vertices[0])
	draw_polyline(outline_vertices, color.darkened(0.05), 2)
