extends Node

var BALL_CONFIG = OreChunkConfig.new([15, 25], 100, 6, 4, create_ball_raycast_shape, preload("res://scenes/ores/ball_ore.tscn"))

class OreChunkConfig: 
	var ore_width: Array[int]
	var density: int
	var max_ore: int
	var max_fails: int 
	var raycast_shape_func: Callable
	var ore_type: PackedScene
	
	func _init(ore_width: Array[int], density: int, max_ore: int, max_fails: int, raycast_shape_func: Callable, ore_type: PackedScene):
		self.ore_width = ore_width
		self.density = density
		self.max_ore = max_ore
		self.max_fails = max_fails
		self.raycast_shape_func = raycast_shape_func
		self.ore_type = ore_type
	
func create_ball_raycast_shape(size: int, buffer: int):
	var shape = CircleShape2D.new()
	shape.set_radius(size + buffer)
	return shape
