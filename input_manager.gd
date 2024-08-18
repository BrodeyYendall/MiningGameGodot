extends Node

signal create_hole(point: Vector2)
signal next_wall()

var DELAY_BETWEEN_HOLES = 200

var prev_hole_created_at = 0

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var current_time = Time.get_ticks_msec()
		if current_time - prev_hole_created_at >= DELAY_BETWEEN_HOLES:
			prev_hole_created_at = current_time
			create_hole.emit(event.position)
	elif event is InputEventKey and event.is_pressed() && not event.is_echo():
		match event.keycode:
			KEY_SPACE:
				next_wall.emit()
		

