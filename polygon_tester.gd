extends Node2D

var iteration = 0
var vertices = [Vector2(1002, 403), Vector2(1004.103, 382.1056), Vector2(1151, 418), Vector2(1153.104, 397.1056)]
var alt_vertices = []

func _draw():
	draw_circle(vertices[0], 2, Color.WHITE)
	for i in range(1, iteration):
		draw_circle(vertices[i], 2, Color.WHITE)
		draw_line(vertices[i - 1], vertices[i], Color.GREEN, 1)
		
	for point in alt_vertices:
		draw_circle(point, 2, Color.BLUE)
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_TAB && iteration < vertices.size():
			iteration += 1
			queue_redraw()
		if event.keycode == KEY_SPACE:
			get_tree().reload_current_scene()
