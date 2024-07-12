extends Node2D

@export var segment_size = 15
@export var crack_range = 16
@export var crack_width = 16
@export var animation_delay = 0.04

var start: Vector2
var end: Vector2
var constructor_called = false
var points = PackedVector2Array()
var iteration = 2
var delta_progress = 0

var perpendicular_direction

func with_data(start: Vector2, end: Vector2) -> Node2D:
	self.start = start
	self.end = end
	constructor_called = true
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(constructor_called, "with_data() must be called when creating a Crack scene")
	
	randomize()
	points.append(start)

	var distance = start.distance_to(end)
	var direction = start.direction_to(end)
	perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	var offset = 0 
	var centre_position = start
	var current_position = start
	
	while(distance > segment_size):
		centre_position = centre_position + (direction * randi_range(10, segment_size))
		offset = randi_range(max(-crack_width, offset - crack_range), min(crack_width, offset + crack_range))
		
		var next_position = centre_position + (perpendicular_direction * offset)
		
		points.append(next_position)
		
		current_position = next_position
		distance -= segment_size
	
	points.append(end)
	
	
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
