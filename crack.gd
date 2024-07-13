extends Node2D

@export var segment_size = 15
@export var crack_range = 8
@export var crack_width = 8
@export var animation_delay = 0.04

var start: Vector2
var end: Vector2
var constructor_called = false
var points = PackedVector2Array()
var iteration = 2
var delta_progress = 0

var perpendicular_direction

func generate_vertices(start: Vector2, end: Vector2) -> PackedVector2Array:
	self.start = start
	self.end = end
	
	# End at the edge of the the hole instead of the centre
	var reverse_direction = end.direction_to(start)
	end = round_vector2(end + (reverse_direction * (Constants.HOLE_SIZE - 1)))

	var distance = start.distance_to(end)
	var direction = start.direction_to(end)
	perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	# Start at the edge of the the hole instead of the centre
	start = round_vector2(start + (direction * (Constants.HOLE_SIZE - 1)))
	
	var offset = 0 
	var centre_position = start
	var current_position = start
	
	#randomize()
	points.append(self.start)
	points.append(start)
	
	while(distance > segment_size):
		centre_position = centre_position + (direction * randi_range(10, segment_size))
		offset = randi_range(max(-crack_width, offset - crack_range), min(crack_width, offset + crack_range))
		
		var next_position = round_vector2(centre_position + (perpendicular_direction * offset))
		
		points.append(next_position)
		
		current_position = next_position
		distance -= segment_size
	
	points.append(end)	
	points.append(self.end)
	return points
	
	
func _draw():
	var shorterened_points = points.slice(0, iteration)
	draw_polyline(shorterened_points, Color8(45, 26, 11), 8)
	draw_polyline(shorterened_points, Color8(25, 15, 6), 6)
	draw_polyline(shorterened_points, Color8(17, 10, 4), 4)
	

func _process(delta):
	delta_progress += delta
	if(delta_progress > animation_delay):
		delta_progress - animation_delay
		iteration += 1
		queue_redraw()
	
	if iteration >= points.size():
		set_process(false)
		
func round_vector2(vector: Vector2):
	return Vector2(roundi(vector.x), roundi(vector.y))
