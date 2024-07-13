extends StaticBody2D

var cutout_vertices: PackedVector2Array

func with_data(cutout_vertices: PackedVector2Array) -> Node2D:
	self.cutout_vertices = cutout_vertices
	return self
	
func _ready():
	assert(not cutout_vertices.is_empty(), "cutout created with vertices, please call with_data().")
	$cutout_shape.set_polygon(cutout_vertices)

func _draw():
	draw_colored_polygon(PackedVector2Array(cutout_vertices), Color.LIGHT_SLATE_GRAY)
