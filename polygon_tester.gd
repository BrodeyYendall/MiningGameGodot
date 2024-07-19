extends Node2D

var iteration = 0
var vertices = [Vector2(600, 600), Vector2(615, 601), Vector2(630, 601), Vector2(645, 605), Vector2(660, 604), Vector2(675, 607), Vector2(660, 606.5)]
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
