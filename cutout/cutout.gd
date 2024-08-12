extends Area2D
class_name Cutout

var cutout_vertices: PackedVector2Array
var related_falling_cutout: FallingCutout = null
var ores_in_cutout: Array[Ore] = []

func with_data(cutout_vertices: PackedVector2Array) -> Node2D:
	self.cutout_vertices = cutout_vertices
	return self
	
func _ready():
	assert(not cutout_vertices.is_empty(), "cutout created with vertices, please call with_data().")
	$hitbox.set_polygon(cutout_vertices)

func _draw():
	draw_colored_polygon(cutout_vertices, Color(Color.BLACK, 0.5))
	
func add_ore(ore: Ore):
	if related_falling_cutout == null:
		ores_in_cutout.append(ore)
	else: 
		# If the cracks are fast enough then the falling cutout can generate before ore signals its in the cutout.
		# The following line mades the ore retroactively in this scenario. 
		related_falling_cutout.call_deferred("add_ore", ore)
	
func add_falling_cutout_reference(falling_cutout: FallingCutout):
	self.related_falling_cutout = falling_cutout
	
	for ore in ores_in_cutout:
		falling_cutout.add_ore(ore)
	

func point_is_inside(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, cutout_vertices)
