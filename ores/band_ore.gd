extends NuggetOre

func generate_ore(size: float):
	generate_vertices_for_dir(Vector2(0, 0), Vector2(1, 0), size, Constants.BAND_ORE_CONFIG)
	
	
func _draw():	
	var shortened_vertices = PackedVector2Array()
	
	var bottom_copy = bottom_line.duplicate()
	bottom_copy.reverse()
	
	shortened_vertices.append_array(top_line)
	shortened_vertices.append_array(bottom_copy)
	
	draw_colored_polygon(shortened_vertices, Color.CORAL)
