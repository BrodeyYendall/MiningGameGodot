extends Node2D
class_name Crack

var config: Constants.CrackConfig

var start: Vector2
var end = Vector2(-1, -1)
var direction: Vector2
var perpendicular_direction: Vector2
var iteration = 2
var delta_progress = 0

var top_line: PackedVector2Array
var bottom_line: PackedVector2Array
var hitbox_vertices: PackedVector2Array
	
func generate_vertices_for_dir(start: Vector2, direction: Vector2, distance: float, config: Constants.CrackConfig) -> void:
	self.start = start
	self.direction = direction
	self.config = config
	
	var crack_lines = generate_crack_line(start, direction, distance)
	top_line = crack_lines[0]
	bottom_line = crack_lines[1]
	
	if end == Vector2(-1, -1): # If not previously assigned a value
		end = Vector2((top_line[-1].x + bottom_line[-1].x) / 2, (top_line[-1].y + bottom_line[-1].y) / 2)
	
	# If we dont want an animation for this crack
	if config.animation_delay == 0:
		iteration = bottom_line.size()
		
	generate_hitbox()

func generate_vertices(start: Vector2, end: Vector2, config: Constants.CrackConfig) -> void:
	self.end = end
	
	generate_vertices_for_dir(start, start.direction_to(end), start.distance_to(end), config)
	
	
func generate_crack_line(start: Vector2, direction: Vector2, distance: float) -> Array[PackedVector2Array]:
	perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	var offset = randi_range(-config.crack_variance, config.crack_variance)
	var crack_width = randi_range(config.min_width, config.max_width)
	var centre_position = start

	var main_points = PackedVector2Array()
	var width_points = PackedVector2Array()
	
	while(distance > config.segment_size * 2):
		centre_position = centre_position + (direction * config.segment_size)
		
		offset = randi_range(max(-config.max_variance, offset - config.crack_variance), min(config.max_variance, offset + config.crack_variance))
		crack_width = randi_range(max(config.min_width, crack_width - config.width_variance), min(config.max_width, crack_width + config.width_variance))
		
		var next_position = round_vector2(centre_position + (perpendicular_direction * offset))
		var width_position =  round_vector2(next_position + (perpendicular_direction * crack_width))
		
		main_points.append(next_position)
		width_points.append(width_position)
		
		distance -= config.segment_size
	
	return [main_points, width_points]
	
func get_nearest_crack_line(vector: Vector2):
	var crack_line: PackedVector2Array
	
	var direction = start.direction_to(end)
	var perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	
	# Check which side of the crack is closest.
	# TODO: I dont quite remember why I am doing this. Need to investigate removing it
	if vector.distance_to(start - perpendicular_direction) < vector.distance_to(start + perpendicular_direction):
		crack_line = bottom_line.duplicate()
	else:
		crack_line = top_line.duplicate()
		
	crack_line.insert(0, start)
	crack_line.append(end)
	
	return crack_line
	
func generate_hitbox():	
	var hitbox_vertices = PackedVector2Array()
	hitbox_vertices.append_array(top_line)
	
	var bottom_copy = bottom_line.duplicate()
	bottom_copy.reverse()
	hitbox_vertices.append_array(bottom_copy)
	
	$hitbox.set_polygon(hitbox_vertices)
	
	
func _draw():	
	var shortened_vertices = PackedVector2Array()
	shortened_vertices.append(start)
	
	var top_short = top_line.slice(0, iteration)
	var bottom_short = bottom_line.slice(0, min(iteration, bottom_line.size()))
	bottom_short.reverse()
	
	shortened_vertices.append_array(top_short)
	if iteration >= bottom_line.size():
		shortened_vertices.append(end)
	else:
		# Give the crack a "point" at the end, making the animation more realistic.
		var middle = Vector2((top_short[-1].x + bottom_short[0].x) / 2, (top_short[-1].y + bottom_short[0].y) / 2)
		middle += direction * config.segment_size
		shortened_vertices.append(middle)
		
	shortened_vertices.append_array(bottom_short)
	
	draw_colored_polygon(shortened_vertices, Color.BLACK)
	

func _process(delta):
	delta_progress += delta
	if(delta_progress > config.animation_delay):
		delta_progress -= config.animation_delay
		iteration += 1
		queue_redraw()
	
	if iteration >= top_line.size(): # top_line and bottom_line are the same size.
		set_process(false)
		
func round_vector2(vector: Vector2):
	return Vector2(roundi(vector.x), roundi(vector.y))
		
