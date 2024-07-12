extends Node2D

@export var crack_distance = 500
@export var crack_width = 15
@export var new_crack_hitbox = 60

signal cycle_created(cycle_points: PackedVector2Array)

var hole_scene = preload("res://hole.tscn")
var holes = []
var cracks: Array[Array] = []
var pathfinder: AStar2D = AStar2D.new()
var should_redraw = false

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && circle_raycast(event.position).is_empty():
		pathfinder.add_point(holes.size(), event.position)
		
		var new_connections = check_for_new_connections(event.position)
		
		if new_connections.size() >= 2:
			check_for_cycle(new_connections, event.position)
			
		for new_connection in new_connections:
			pathfinder.connect_points(holes.size(), new_connection)
		
		create_circle(event.position)
		should_redraw = true
		
func check_for_new_connections(new_point_position: Vector2) -> Array[int]:
	var new_connections: Array[int] = []
	for i in range(holes.size()):
		if holes[i].position.distance_to(new_point_position) < crack_distance:
			cracks.append([holes[i].position, new_point_position])
			new_connections.append(i)
	return new_connections
		
			
func check_for_cycle(new_connections, new_point):
	var cycles = []
	for i in range(new_connections.size()):
		for j in range(i + 1, new_connections.size()):
			var path = pathfinder.get_id_path(new_connections[i], new_connections[j])
			if not path.is_empty():
				cycles.append(path)
				
	cycles.sort_custom(func(a, b): return a.size() < b.size())
	
	var points_used = {}
	for cycle in cycles:
		var contains_unqiue_points = false
		var pathVectors = PackedVector2Array()
		for point in cycle:
			if not points_used.has(point):
				contains_unqiue_points = true
				points_used[point] = true
			pathVectors.append(holes[point].position)
				
		if contains_unqiue_points:
			pathVectors.append(new_point)
			cycle_created.emit(pathVectors)
			

			
func circle_raycast(position: Vector2, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circleShape = CircleShape2D.new()
	circleShape.set_radius(new_crack_hitbox)
	query.set_shape(circleShape)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
	
func create_circle(hole_position: Vector2):
	var hole = hole_scene.instantiate()
	print("Circle created at " + str(hole_position))
	hole.position = hole_position
	add_child(hole)
	holes.append(hole)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_redraw:
		queue_redraw()
	
func _draw():
	for line in cracks:
		draw_line(line[0], line[1], Color.BLACK, crack_width)
