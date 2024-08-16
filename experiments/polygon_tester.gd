extends Node2D

var iteration = 0
var vertices = [Vector2(506.6667, 229.6667), Vector2(512, 213), Vector2(516, 204), Vector2(520, 195), Vector2(523, 185), Vector2(528, 177), Vector2(534.3334, 168.3333), Vector2(524, 166), Vector2(515, 167), Vector2(504, 165), Vector2(494, 164), Vector2(484, 164), Vector2(474, 165), Vector2(461.3333, 172), Vector2(458, 186), Vector2(465, 195), Vector2(471, 203), Vector2(477, 211), Vector2(485, 217), Vector2(492, 225), Vector2(514.6667, 106.6667), Vector2(524, 119), Vector2(525, 129), Vector2(527, 139), Vector2(533, 148), Vector2(536, 157), Vector2(534.3334, 168.3333), Vector2(524, 170), Vector2(515, 172), Vector2(504, 171), Vector2(494, 169), Vector2(484, 169), Vector2(474, 170), Vector2(461.3333, 172), Vector2(468, 165), Vector2(475, 157), Vector2(481, 149), Vector2(487, 141), Vector2(492, 133), Vector2(498, 124), Vector2(506, 118)]
var alt_vertices = [Vector2(475, 157), Vector2(487, 141), Vector2(492, 133), Vector2(498, 124), Vector2(506, 118), Vector2(514.6667, 106.6667), Vector2(524, 119), Vector2(525, 129), Vector2(527, 139), Vector2(533, 148), Vector2(536, 157), Vector2(534.3334, 168.3333), Vector2(528, 177), Vector2(523, 185), Vector2(520, 195), Vector2(512, 213), Vector2(506.6667, 229.6667), Vector2(492, 225), Vector2(485, 217), Vector2(477, 211), Vector2(465, 195), Vector2(458, 186), Vector2(461.3334, 172), Vector2(468, 165)]
var already_existed = {}

func _ready():
	pass
	#vertices = translate_vertices(vertices)
	
func translate_vertices(vertices: Array) -> Array:
	var min_vertex = vertices[0]
	for vertex in vertices:
		if vertex.x < min_vertex.x:
			min_vertex.x = vertex.x
		if vertex.y < min_vertex.y:
			min_vertex.y = vertex.y
	
	min_vertex -= Vector2(10, 10)  # Give a little buffer
	var updated_vertices = []
	for vertex in vertices:
		updated_vertices.append(vertex - min_vertex)
	return updated_vertices

func _draw():
	draw_point(vertices[0])
	for i in range(1, min(iteration, vertices.size())):
		draw_point(vertices[i])
		draw_line(vertices[i - 1], vertices[i], Color.GREEN, 1)
	if iteration >= vertices.size():
		draw_line(vertices[-1], vertices[0], Color.GREEN, 1)
	
		if alt_vertices.size() > 0:
			var adjusted_iteration = iteration - vertices.size()
			draw_point(alt_vertices[0])
			for i in range(1, min(adjusted_iteration, alt_vertices.size())):
				draw_point(alt_vertices[i])
				draw_line(alt_vertices[i - 1], alt_vertices[i], Color.BLUE, 1)
			if adjusted_iteration == alt_vertices.size():
				draw_line(alt_vertices[-1], alt_vertices[0], Color.BLUE, 1)
		
	already_existed = {} 
		
func draw_point(point: Vector2):
	if point in already_existed:
		draw_circle(point, 2, Color.YELLOW)
	else:
		already_existed[point] = true
		draw_circle(point, 2, Color.WHITE)
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_TAB && iteration < vertices.size() + alt_vertices.size():
			iteration += 1
			queue_redraw()
		if event.keycode == KEY_SPACE:
			get_tree().reload_current_scene()
