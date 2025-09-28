class_name SignalingCrack
extends "res://scripts/crack.gd"


signal crack_complete(parent: int)

var parent_cutouts: Array[int]

func add_parent(parent: int):
	parent_cutouts.append(parent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if not is_processing():
		for parent in parent_cutouts:
			crack_complete.emit(parent)
