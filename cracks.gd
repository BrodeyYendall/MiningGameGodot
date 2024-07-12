extends Node2D

@export var circle_radius = 15
@export var crack_distance = 500
@export var crack_width = 15

var circles = PackedVector2Array()
var cracks: Array[Array] = []
var cutouts: Array[PackedVector2Array] = []
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
			check_for_cutout(new_connections, event.position)
			
		for new_connection in new_connections:
			pathfinder.connect_points(circles.size(), new_connection)
		
		circles.append(event.position)
		should_redraw = true
		
		
			
func check_for_cutout(new_connections, new_point):
	var cycles = []
	for i in range(new_connections.size()):
		for j in range(i + 1, new_connections.size()):
			var path = pathfinder.get_id_path(new_connections[i], new_connections[j])
			if not path.is_empty():
				cycles.append(path)
				
	cycles.sort_custom(sort_by_array_size)
	
	var points_used = {}
	var new_cutout_count = 0
	for cycle in cycles:
		var contains_unqiue_points = false
		var pathVectors = PackedVector2Array()
		for point in cycle:
			if not points_used.has(point):
				contains_unqiue_points = true
				points_used[point] = true
			pathVectors.append(circles[point])
				
		if contains_unqiue_points:
			pathVectors.append(new_point)
			cutouts.append(pathVectors)
			new_cutout_count += 1
	print("Created " + str(new_cutout_count) + " new cutouts")
		
		
func sort_by_array_size(a: Array, b: Array):
	return a.size() < b.size()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_redraw:
		queue_redraw()
	
func _draw():
	for cutout in cutouts:
		draw_colored_polygon(PackedVector2Array(cutout), Color.LIGHT_SLATE_GRAY)
	for line in cracks:
		draw_line(line[0], line[1], Color.BLACK, crack_width)
	
	for i in range(circles.size()):
		draw_circle(circles[i], circle_radius, Color.BLACK)
		var half_size = circle_radius / 2
		draw_string(ThemeDB.fallback_font, Vector2(circles[i].x - half_size, circles[i].y + half_size), str(i), HORIZONTAL_ALIGNMENT_CENTER, circle_radius, 20, Color.WHITE)
