extends Area2D
class_name Cutout

signal destroy_crack(crack: Vector2)
signal destroy_hole(hole: Hole)

var cutout_vertices: PackedVector2Array
var cracks: Array
var related_falling_cutout: FallingCutout = null
var ores_in_cutout: Array[Area2D] = []
var holes_in_cutout: Array[Hole] = []

func with_data(cutout_vertices: PackedVector2Array, cracks: Array) -> Node2D:
	print("Creating cutout with " + str(cracks))
	self.cutout_vertices = cutout_vertices
	self.cracks = cracks
	return self
	
func _ready():
	assert(not cutout_vertices.is_empty(), "cutout created with vertices, please call with_data().")
	$hitbox.set_polygon(cutout_vertices)

func _draw():
	draw_colored_polygon(cutout_vertices, Color(Color.BLACK, 0.2))
	
func add_ore(ore: Area2D):
	if related_falling_cutout == null:
		ores_in_cutout.append(ore)  # This will be added to the falling cutout when add_falling_cutout_reference is called
	else: 
		# If the cracks are fast enough then the falling cutout can generate before ore signals its in the cutout.
		# The following line mades the ore retroactively in this scenario. 
		related_falling_cutout.call_deferred("add_ore", ore)
		
func add_hole(hole: Hole):
	holes_in_cutout.append(hole)
	
func add_falling_cutout_reference(falling_cutout: FallingCutout):
	self.related_falling_cutout = falling_cutout
	
	for ore in ores_in_cutout:
		falling_cutout.add_ore(ore)
		
	for hole in holes_in_cutout:
		destroy_hole.emit(hole)

func point_is_inside(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, cutout_vertices)
	
func merge_cutout(cutout_to_merge: Cutout):
	print("Merging %s with %s" % [cracks, cutout_to_merge.cracks])
	var result = Geometry2D.merge_polygons(cutout_to_merge.cutout_vertices, cutout_vertices)
	
	var cracks_to_remove = []
	for crack in cracks:
		if cutout_to_merge.cracks.has(crack):
			cracks_to_remove.append(crack)
		
	var merged_cracks = []
	
	var new_cutout_cracks = cutout_to_merge.cracks.duplicate()
	for crack in cracks_to_remove:
		new_cutout_cracks.erase(crack)
		cracks.erase(crack)
		
		destroy_crack.emit(crack)
	cracks.append_array(new_cutout_cracks)
	
	with_data(result[0], cracks)
	_ready()
	queue_redraw()
	
	cutout_to_merge.destroy()
	
func destroy():
	queue_free()

func get_parent_wall_count():
	return get_parent().get_parent().get_parent().wall_count
