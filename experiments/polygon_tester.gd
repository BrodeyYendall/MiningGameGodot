extends Node2D

var iteration = 0
var vertices = [Vector2(25, 1), Vector2(26.86863, 11.71514), Vector2(23.62742, 23.62742), Vector2(12.24587, 29.56414), Vector2(1, 37), Vector2(-15.3688, 47.34622), Vector2(-37.59798, 41.59798), Vector2(-54.43277, 23.96101), Vector2(-69, 3), Vector2(-71.91036, -28.61468), Vector2(-63.88225, -63.88225), Vector2(-39.92201, -104.8655), Vector2(6, -138), Vector2(70.29082, -149.2118), Vector2(137.9361, -127.9361), Vector2(201.8625, -75.12889)]
var alt_vertices = []
var already_existed = {}

func _ready():
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
	vertices = updated_vertices

func _draw():
	draw_point(vertices[0])
	for i in range(1, iteration):
		draw_point(vertices[i])
		draw_line(vertices[i - 1], vertices[i], Color.GREEN, 1)
		
	for point in alt_vertices:
		draw_circle(point, 2, Color.BLUE)
		
	already_existed = {} 
		
func draw_point(point: Vector2):
	if point in already_existed:
		draw_circle(point, 2, Color.YELLOW)
	else:
		already_existed[point] = true
		draw_circle(point, 2, Color.WHITE)
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_TAB && iteration < vertices.size():
			iteration += 1
			queue_redraw()
		if event.keycode == KEY_SPACE:
			get_tree().reload_current_scene()
