extends Node2D

var falling_cutout_scene = preload("res://cutout/falling_cutout.tscn")
var cutout_scene = preload("res://cutout/cutout.tscn")
var generated_wall_image: Image

signal ore_cutout(ore: OreTypes.OreType)

var queue = {}
var id_counter = 0
var should_destroy = false
var collision_layer: int = 1

func set_collision_layer(layer: int):
	collision_layer = layer
	for child in $"../contents/cutout_holder".get_children():
		child.set_collision_layer(layer)
		child.set_collision_mask(layer)

func queue_cutout(cutout_vecters: PackedVector2Array, new_cracks: Array[SignalingCrack]):
	var cutout = cutout_scene.instantiate().with_data(cutout_vecters)
	cutout.visible = false
	cutout.set_collision_layer(collision_layer)
	cutout.set_collision_mask(collision_layer)
	$"../contents/cutout_holder".add_child(cutout)
	
	queue[id_counter] = {"vertices": cutout_vecters, "cutout": cutout, "new_cracks": new_cracks, "completed_cracks_count": 0}
	for crack in new_cracks:
		crack.add_parent(id_counter)
		
		# Not having this if statement causes an annoying error message. 
		if not crack.crack_complete.is_connected(crack_completed):
			crack.crack_complete.connect(crack_completed)
		
	id_counter += 1
	
func crack_completed(cutout_id: int):
	var refered_cutout = queue[cutout_id]
	refered_cutout["completed_cracks_count"] += 1
	
	if refered_cutout["completed_cracks_count"] == refered_cutout["new_cracks"].size():
		refered_cutout["cutout"].visible = true
		
		var falling_cutout: FallingCutout = falling_cutout_scene.instantiate().with_data(refered_cutout["vertices"], generated_wall_image)
		(refered_cutout["cutout"] as Cutout).add_falling_cutout_reference(falling_cutout)
		falling_cutout.cutout_offscreen.connect(_falling_cutout_offscreen)
		$"../falling_cutout_holder".add_child(falling_cutout)
		
		queue[cutout_id] = null
		
func destroy():
	should_destroy = true
	check_for_destroy(0)
	
func check_for_destroy(min_children: int):
	var children = $"../falling_cutout_holder".get_children()
	if $"../falling_cutout_holder".get_child_count() <= min_children:  
		get_parent().queue_free()

func _on_background_image_changed(new_image: Image):
	generated_wall_image = new_image

func _falling_cutout_offscreen(ores: Array[Ore]):
	for ore in ores:
		ore_cutout.emit(ore.oreType)
		
	if should_destroy:
		# The signalling cutout will be alive during the check so we set the min_children to 1
		check_for_destroy(1)
