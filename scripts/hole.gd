extends Area2D
class_name Hole

signal destroy_hole(point_id: int)

var point_number = 0
var square_wrapper: PackedVector2Array = PackedVector2Array()

func with_data(point_number: int):
	self.point_number = point_number

func _ready():
	$hitbox.shape.set_radius(Constants.HOLE_SIZE)

func _draw():
	draw_circle(Vector2(0, 0), Constants.HOLE_SIZE, Color.BLACK)
	draw_string(ThemeDB.fallback_font, Vector2(-2, 3), str(point_number), 0, -1, 12)


func _on_area_entered(area):
	if area is Cutout:		
		if Geometry2D.clip_polygons(_get_square_wrapper(), area.cutout_vertices).is_empty():
			area.add_hole(self)

# Used to determine if a hole is completely surrounded by a cutout. A square "hitbox" is used for
# optimisation and to be sure that it is surrounded. 
func _get_square_wrapper():
	if square_wrapper.is_empty():
		var negative = position - Vector2(Constants.HOLE_SIZE, Constants.HOLE_SIZE)
		var positive = position + Vector2(Constants.HOLE_SIZE, Constants.HOLE_SIZE)
		square_wrapper.append(Vector2(negative.x, negative.y))
		square_wrapper.append(Vector2(negative.x, positive.y))
		square_wrapper.append(Vector2(positive.x, positive.y))
		square_wrapper.append(Vector2(positive.x, negative.y))
	return square_wrapper
