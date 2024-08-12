extends Node2D

var falling_cutout_scene = preload("res://cutout/falling_cutout.tscn")
var cutout_scene = preload("res://cutout/cutout.tscn")
var generated_wall_image: Image

var queue = {}
var id_counter = 0

func queue_cutout(cutout_vecters: PackedVector2Array, new_cracks: Array[SignalingCrack]):
	var cutout = cutout_scene.instantiate().with_data(cutout_vecters)
	cutout.visible = false
	$cutout_holder.add_child(cutout)
	
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
		
		var falling_cutout = falling_cutout_scene.instantiate().with_data(refered_cutout["vertices"], generated_wall_image)
		(refered_cutout["cutout"] as Cutout).add_falling_cutout_reference(falling_cutout)
		$falling_cutout_holder.add_child(falling_cutout)
		
		queue[cutout_id] = null

func _on_background_image_changed(new_image: Image):
	generated_wall_image = new_image
