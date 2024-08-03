extends Area2D

var ore_vertices: PackedVector2Array

var VARIANCE = 4
var MAX_VARIANCE = 8
var SEGMENT_SIZE = 32

func generate_ore(size: int):
	ore_vertices = PackedVector2Array()
	var offset = 0
	
	for segment in range(SEGMENT_SIZE):
		offset = randi_range(max(0, offset - VARIANCE), min(MAX_VARIANCE, offset + VARIANCE))
		
		var angle = (PI * 2 / SEGMENT_SIZE) * segment
		var x = offset + size * cos(angle)
		var y = offset + size * sin(angle)
		ore_vertices.append(Vector2(x, y))
	$hitbox.polygon = ore_vertices

func _draw():
	draw_colored_polygon(ore_vertices, Color.GOLDENROD)
