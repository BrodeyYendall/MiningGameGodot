extends Node2D

var iteration = 0
var vertices = [Vector2(590, 609), Vector2(595, 604), Vector2(600, 602), Vector2(605, 598), Vector2(610, 594), Vector2(620, 591), Vector2(630, 596), Vector2(640, 594), Vector2(650, 595), Vector2(660, 596), Vector2(670, 591), Vector2(680, 593), Vector2(685, 595), Vector2(690, 599), Vector2(695, 604), Vector2(700, 608), Vector2(705, 611), Vector2(705, 619), Vector2(700, 624), Vector2(695, 628), Vector2(690, 633), Vector2(685, 637), Vector2(680, 638), Vector2(670, 634), Vector2(660, 641), Vector2(650, 640), Vector2(640, 639), Vector2(630, 641), Vector2(620, 631), Vector2(610, 636), Vector2(605, 633), Vector2(600, 628), Vector2(595, 624), Vector2(590, 619)]
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
