extends Area2D

var point_number = 0

func with_data(point_number: int):
	self.point_number = point_number

func _ready():
	$hitbox.shape.set_radius(Constants.HOLE_SIZE)

func _draw():
	draw_circle(Vector2(0, 0), Constants.HOLE_SIZE, Color.BLACK)
	draw_string(ThemeDB.fallback_font, Vector2(-2, 3), str(point_number), 0, -1, 12)
