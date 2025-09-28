extends Node

func generate_crack_line(config: Constants.CrackConfig, start: Vector2, direction: Vector2, distance: float) -> Array[PackedVector2Array]:
	var perpendicular_direction = Vector2(-direction.y, direction.x).normalized()
	
	var offset = randi_range(-config.crack_variance, config.crack_variance)
	var crack_width = randi_range(config.min_width, config.max_width)
	var centre_position = start

	var main_points = PackedVector2Array()
	var width_points = PackedVector2Array()
	
	while(distance > config.segment_size * 2):
		centre_position = centre_position + (direction * config.segment_size)
		
		offset = randi_range(max(-config.max_variance, offset - config.crack_variance), min(config.max_variance, offset + config.crack_variance))
		crack_width = randi_range(max(config.min_width, crack_width - config.width_variance), min(config.max_width, crack_width + config.width_variance))
		
		var next_position = round_vector2(centre_position + (perpendicular_direction * offset))
		var width_position =  round_vector2(next_position + (perpendicular_direction * crack_width))
		
		main_points.append(next_position)
		width_points.append(width_position)
		
		distance -= config.segment_size
	
	return [main_points, width_points]

func round_vector2(vector: Vector2):
	return Vector2(roundi(vector.x), roundi(vector.y))
