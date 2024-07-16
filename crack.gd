extends Node2D

@export var segment_size = 15
@export var half_crack_width = 7 # Must be odd 
@export var min_width = 3
@export var animation_delay = 0.04

var start: Vector2
var end: Vector2
var iteration = 2
var delta_progress = 0

var crack_variance = (half_crack_width - 1) / 2
var half_of_min_band = (min_width - 1) / 2

var top_line: PackedVector2Array
var bottom_line: PackedVector2Array

func _ready():
	assert(half_crack_width % 2 == 1, "half_crack_width must be odd")
	assert(min_width % 2 == 1, "min_width must be odd")

func generate_vertices(start: Vector2, end: Vector2) -> void:
	self.start = start
	self.end = end
	
	var crack_lines = generate_crack_line(start, end)
	top_line = crack_lines[0]
	bottom_line = crack_lines[1]
	
	
func generate_crack_line(start: Vector2, end: Vector2) -> Array[PackedVector2Array]:
	var distance = start.distance_to(end)
	var direction = start.direction_to(end)
	var perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	var offset = 0 
	var opposite_offset = 0
	var centre_position = start

	var main_points = PackedVector2Array()
	var opposite_points = PackedVector2Array()
	
	var crack_line_buffer = perpendicular_direction * (crack_variance + half_of_min_band + 1)
	
	while(distance > segment_size * 2):
		centre_position = centre_position + (direction * segment_size)
		offset = randi_range(max(-crack_variance, offset - crack_variance), min(crack_variance, offset + crack_variance))
		opposite_offset = randi_range(max(-crack_variance, opposite_offset - crack_variance), min(crack_variance, opposite_offset + crack_variance))
		
		var next_position = round_vector2((centre_position - crack_line_buffer) - (perpendicular_direction * offset))
		var opposite_line_next_position =  round_vector2((centre_position + crack_line_buffer) + (perpendicular_direction * opposite_offset))
		
		main_points.append(next_position)
		opposite_points.append(opposite_line_next_position)
		
		distance -= segment_size
	
	return [main_points, opposite_points]
	
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
	
	
	
func _draw():	
	var shortened_vertices = PackedVector2Array()
	shortened_vertices.append(start)
	
	var top_short = top_line.slice(0, iteration)
	var bottom_short = bottom_line.slice(0, min(iteration, bottom_line.size()))
	bottom_short.reverse()
	
	shortened_vertices.append_array(top_short)
	shortened_vertices.append(end)
	shortened_vertices.append_array(bottom_short)
	
	draw_colored_polygon(shortened_vertices, Color.BLACK)
	

func _process(delta):
	delta_progress += delta
	if(delta_progress > animation_delay):
		delta_progress - animation_delay
		iteration += 1
		queue_redraw()
	
	if iteration >= top_line.size(): # top_line and bottom_line are the same size.
		set_process(false)
		
func round_vector2(vector: Vector2):
	return Vector2(roundi(vector.x), roundi(vector.y))
