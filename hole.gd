extends Area2D

func _ready():
	$hole_hitbox.shape.set_radius(Constants.HOLE_SIZE)

func _draw():
	draw_circle(Vector2(0, 0), Constants.HOLE_SIZE, Color.BLACK)
