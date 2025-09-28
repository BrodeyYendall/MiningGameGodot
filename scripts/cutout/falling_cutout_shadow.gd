extends Node2D

var shadow_vertices: PackedVector2Array

func prepare_shadow(parent_vertices: PackedVector2Array, min_vector: Vector2):
	shadow_vertices = remove_mins(parent_vertices, min_vector)

func remove_mins(vertices: PackedVector2Array, min_vector: Vector2):
	var vertices_copy = vertices.duplicate()
	for i in range(vertices.size()):
		vertices_copy[i] = vertices[i] - min_vector
		
	return vertices_copy

func _draw():
	draw_colored_polygon(shadow_vertices, Color.BLACK)
