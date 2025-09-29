extends Node2D

var space

func _ready():
	space = get_world_2d().direct_space_state

func line_raycast(start: Vector2, end: Vector2, collision_layer: int):
	var query = PhysicsRayQueryParameters2D.new()
	query.set_from(start)
	query.set_to(end)
	query.set_collide_with_areas(true)
	query.set_collision_mask(collision_layer)
	return space.intersect_ray(query)

func circle_raycast(point: Vector2, collision_layer: int = 0xFFFFFFFF, radius = 15, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(radius)
	query.set_shape(circle_shape)
	query.set_collide_with_areas(true)
	query.set_collision_mask(collision_layer)
	query.transform.origin = point
	
	return space.intersect_shape(query, max_results)
	
func raycast_shape(point: Vector2, shape: Shape2D, collision_layer: int, max_results = 1):
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.set_collide_with_areas(true)
	query.set_collision_mask(collision_layer)
	query.transform.origin = point
	
	return space.intersect_shape(query, max_results)
