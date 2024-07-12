extends Node2D

var cutout_scene = preload("res://cutout.tscn")

var cutouts: Array[PackedVector2Array] = []

func _on_cracks_cycle_created(cycle_points: PackedVector2Array):
	cutouts.append(cycle_points)
	
	var cutout = cutout_scene.instantiate()
	var cutout_hitbox: CollisionPolygon2D = cutout.get_node("cutout_shape")
	cutout_hitbox.set_polygon(cycle_points)
	add_child(cutout)
	
	queue_redraw()


#func _draw():
	#for cutout in cutouts:
		#draw_colored_polygon(PackedVector2Array(cutout), Color.LIGHT_SLATE_GRAY)
