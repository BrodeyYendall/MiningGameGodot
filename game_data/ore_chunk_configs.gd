extends Node

var NUGGET_CONFIG = OreChunkConfig.new([20, 40], 80, 6, 4, create_ball_raycast_shape, preload("res://ores/nugget_ore.tscn"))
var BAND_CONFIG = OreChunkConfig.new([80, 120], 80, 6, 4, create_nugget_raycast_shape, preload("res://ores/nugget_ore.tscn"))
var BALL_CONFIG = OreChunkConfig.new([15, 25], 100, 6, 4, create_band_raycast_shape, preload("res://ores/ball_ore.tscn"))

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

func create_nugget_raycast_shape(size: int, buffer: int):
	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(size + buffer, Constants.NUGGET_ORE_CONFIG.max_width + buffer))
	return shape
	
func create_band_raycast_shape(size: int, buffer: int):
	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(size + buffer, Constants.BAND_ORE_CONFIG.max_width + buffer))
	return shape
	
	
