extends Ore

var ore_vertices: PackedVector2Array

var VARIANCE = 2
var MAX_VARIANCE = 6
var SEGMENT_SIZE = 16
var TOTAL_RADIUS = 64

func _generate_ore():
	self.oreType = oreType
	self.size = size
	ore_vertices = PackedVector2Array()
	var offset = 0
	
	var segment_ratio = TOTAL_RADIUS / SEGMENT_SIZE
	
	for segment in range(SEGMENT_SIZE):
		offset = randi_range(max(0, offset - VARIANCE), min(MAX_VARIANCE, offset + VARIANCE))
		
		var angle = (PI * 2 / SEGMENT_SIZE) * segment
		var x = offset + size * cos(angle)
		var y = offset + size * sin(angle)
		ore_vertices.append(Vector2(x, y))
	$hitbox.polygon = ore_vertices

func _draw():
	var color = OreTypes.get_ore_color(oreType)
	draw_colored_polygon(ore_vertices, color)
	draw_polyline(ore_vertices, color.darkened(0.1), 1)
	
func _get_centre_position():
	return position
