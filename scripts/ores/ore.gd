extends Area2D
class_name Ore

var oreType: OreTypes.OreType
var size: int

func create(oreType: OreTypes.OreType, size: int):
	self.oreType = oreType
	self.size = size
	
	_generate_ore()
	
func _on_area_entered(area):
	if area is Cutout:
		if (area as Cutout).point_is_inside(_get_centre_position()):
			(area as Cutout).add_ore(self)
			area_entered.disconnect(_on_area_entered) 
	
func _generate_ore():
	pass
	
func _get_centre_position() -> Vector2:
	assert(false, "_get_centre_position is not implemented")
	return position 
