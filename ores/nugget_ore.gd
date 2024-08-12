extends Ore
class_name NuggetOre

var top_line: PackedVector2Array = PackedVector2Array()
var bottom_line: PackedVector2Array = PackedVector2Array()
var centre_position = null

var SMOOTH_SEGMENTS = 2
var SMOOTH_INCREMENTS = 2
var MIN_WIDTH = (SMOOTH_INCREMENTS * 2) + 1  # The min distance between the two lines before we end smoothing
	
func _generate_ore():	
	var config = OreTypes.get_crack_generation_config(oreType)
	var crack_lines = RandomUtils.generate_crack_line(config, Vector2(0, 0), Vector2(1, 0), size)
	
	var start_smooth = smooth_tip(crack_lines[0][0], crack_lines[1][0], Vector2(-1, 0))
	start_smooth[0].reverse()
	start_smooth[1].reverse()
	
	top_line = start_smooth[0]
	bottom_line = start_smooth[1]
	
	top_line.append_array(crack_lines[0])
	bottom_line.append_array(crack_lines[1])
	
	var end_smooth = smooth_tip(top_line[-1], bottom_line[-1], Vector2(1, 0))
	top_line.append_array(end_smooth[0])
	bottom_line.append_array(end_smooth[1])
		
	generate_hitbox()
	randomly_rotate()
	
func smooth_tip(top: Vector2, bottom: Vector2, direction: Vector2):
	var perpendicular_direction = Vector2(0, 1)
	
	var new_top_line = PackedVector2Array()
	var new_bottom_line = PackedVector2Array()
	
	var current_top = top
	var current_bottom = bottom
	
	while(abs(current_top.distance_to(current_bottom)) > MIN_WIDTH):
		var forward_increment = SMOOTH_SEGMENTS * direction
		
		current_top += randi_range(1, SMOOTH_INCREMENTS) * perpendicular_direction
		current_bottom -= randi_range(1, SMOOTH_INCREMENTS) * perpendicular_direction
		
		current_top += forward_increment
		current_bottom += forward_increment
		
		new_top_line.append(current_top)
		new_bottom_line.append(current_bottom)
		
	return [new_top_line, new_bottom_line]
	
func generate_hitbox():	
	var hitbox_vertices = PackedVector2Array()
	hitbox_vertices.append_array(top_line)
	
	var bottom_copy = bottom_line.duplicate()
	bottom_copy.reverse()
	hitbox_vertices.append_array(bottom_copy)
	
	$hitbox.set_polygon(hitbox_vertices)
	
func randomly_rotate():
	set_rotation_degrees(randi_range(0, 180))
	
func _get_centre_position() -> Vector2:
	if centre_position == null:
		var middle_index = top_line.size() / 2
		centre_position = (top_line[middle_index] + bottom_line[middle_index]) / 2
		centre_position = centre_position.rotated(rotation) + position
	return centre_position # This method should be implemented by the child

func _draw():	
	var shortened_vertices = PackedVector2Array()
	
	var bottom_copy = bottom_line.duplicate()
	bottom_copy.reverse()
	
	shortened_vertices.append_array(top_line)
	shortened_vertices.append_array(bottom_copy)
	
	var color = OreTypes.get_ore_color(oreType)
	draw_colored_polygon(shortened_vertices,color)
	
	var outline_vertices = shortened_vertices.duplicate()
	outline_vertices.append(shortened_vertices[0])
	draw_polyline(outline_vertices, color.darkened(0.05), 2)
