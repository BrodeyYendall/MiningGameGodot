extends Node2D

@export var circle_radius = 15
@export var crack_distance = 300
@export var crack_width = 15

var circles: Array[Vector2] = []
var cracks: Array[Array] = []
var pathfinder: AStar2D = AStar2D.new()
var should_redraw = false

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		pathfinder.add_point(circles.size(), event.position)
		
		var new_connections = []
		for i in range(circles.size()):
			if circles[i].distance_to(event.position) < crack_distance:
				cracks.append([circles[i], event.position])
				new_connections.append(i)
		
		if new_connections.size() >= 2:
			check_for_cutout(new_connections)
			
		for new_connection in new_connections:
			pathfinder.connect_points(circles.size(), new_connection)
		
		circles.append(event.position)
		should_redraw = true
		
		
			
func check_for_cutout(new_connections):
	print("enter")
	for i in range(new_connections.size()):
		for j in range(i + 1, new_connections.size()):
			var new_cycle = pathfinder.get_id_path(new_connections[i], new_connections[j])
			if not new_cycle.is_empty():
				print(str(i) + " to " + str(j) + " is " + str(new_cycle)) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_redraw:
		queue_redraw()
	
func _draw():
	for line in cracks:
		draw_line(line[0], line[1], Color.BLACK, crack_width)
	for i in range(circles.size()):
		draw_circle(circles[i], circle_radius, Color.BLACK)
		var half_size = circle_radius / 2
		draw_string(ThemeDB.fallback_font, Vector2(circles[i].x - half_size, circles[i].y + half_size), str(i), HORIZONTAL_ALIGNMENT_CENTER, circle_radius, 20, Color.WHITE)
