extends Node2D

@export var cutout_holder: Node2D
@export var falling_cutout_holder: Node2D

var falling_cutout_scene = preload("res://scenes/cutout/falling_cutout.tscn")
var cutout_scene = preload("res://scenes/cutout/cutout.tscn")
var generated_wall_image: Image

signal ore_cutout(ore: OreTypes.OreType)
signal render_cutout(cutout_vertices: PackedVector2Array)

var queue = {}
var cutout_map = {} # A map pointing a crack to the cutouts that use it. 
var id_counter = 0
var should_destroy = false
var collision_layer: int = 1

func set_collision_layer(layer: int):
	collision_layer = layer
	for child in cutout_holder.get_children():
		child.set_collision_layer(layer)
		child.set_collision_mask(layer)

func queue_cutout(cutout_vecters: PackedVector2Array, new_cracks: Array[Node2D], all_cracks: Array):
	var cutout = create_cutout(cutout_vecters, all_cracks)
	cutout.visible = false
	
	queue[id_counter] = {
		"cutout": cutout, 
		"new_crack_count": new_cracks.size(), 
		"completed_cracks_count": 0
	}
	
	for crack in new_cracks:
		crack.AddParent(id_counter)
		
		# Not having this if statement causes an annoying error message when the crack is already connected.
		if not crack.CrackComplete.is_connected(crack_completed):
			crack.CrackComplete.connect(crack_completed)
	
	id_counter += 1
	
func crack_completed(cutout_id: int):
	var refered_cutout = queue[cutout_id]
	refered_cutout["completed_cracks_count"] += 1
	
	if refered_cutout["completed_cracks_count"] == refered_cutout["new_crack_count"]:
		var cutout: Cutout = refered_cutout["cutout"]
		cutout.destroy_crack.connect(_crack_destroy)
		cutout.destroy_hole.connect(_hole_destroy)
		
		var falling_cutout: FallingCutout = falling_cutout_scene.instantiate().with_data(cutout.cutout_vertices, generated_wall_image)
		cutout.add_falling_cutout_reference(falling_cutout)
		falling_cutout.cutout_offscreen.connect(_falling_cutout_offscreen)
		falling_cutout_holder.add_child(falling_cutout)
		
		render_cutout.emit(cutout.cutout_vertices)
		check_for_cutout_merge(cutout)
		
		queue[cutout_id] = null
		
func check_for_cutout_merge(cutout: Cutout):
	var cutouts_to_merge = []
	for crack in cutout.cracks:
		if crack in cutout_map and not cutouts_to_merge.has(cutout_map[crack]):
			cutouts_to_merge.append(cutout_map[crack])
	
	for existing_cutout in cutouts_to_merge:
		existing_cutout.merge_cutout(cutout)
		cutout = existing_cutout

	if cutouts_to_merge.size() == 0:
		cutout.visible = true
		
	for crack in cutout.cracks:
		cutout_map[crack] = cutout
	
func create_cutout(cutout_vecters: PackedVector2Array, cracks: Array) -> Cutout: 
	var cutout = cutout_scene.instantiate().with_data(cutout_vecters, cracks)
	cutout.set_collision_layer(collision_layer)
	cutout.set_collision_mask(collision_layer)
	cutout_holder.add_child(cutout)
	return cutout
		
func destroy():
	should_destroy = true
	check_for_destroy(0)
	
func check_for_destroy(min_children: int):
	if falling_cutout_holder.get_child_count() <= min_children:  
		get_parent().queue_free()

func _on_background_image_changed(new_image: Image):
	generated_wall_image = new_image

func _falling_cutout_offscreen(ores: Array[Ore]):
	for ore in ores:
		ore_cutout.emit(ore.oreType)
		
	if should_destroy:
		# The signalling cutout will be alive during the check so we set the min_children to 1
		check_for_destroy(1)
		
func _crack_destroy(crack: Node2D):
	get_parent().destroy_crack(crack.CrackPointReferences[0], crack.CrackPointReferences[1])
	
func _hole_destroy(hole: Hole):
	get_parent()._destroy_cracks_and_hole(hole.point_number)
