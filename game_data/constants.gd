extends Node

const SCREEN_WIDTH = 640
const SCREEN_HEIGHT = 360

const HOLE_SIZE = 5
var CUTOUT_CRACK_CONFIG = CrackConfig.new(3, 8, 2, 1, 4, 0.04, 10)

var NUGGET_ORE_CONFIG = CrackConfig.new(10, 20, 2, 2, 4, 0.0, 5)
var BAND_ORE_CONFIG = CrackConfig.new(5, 10, 1, 1, 2, 0.0, 5)

var NUGGET_CONFIG = OreChunkConfig.new([20, 40], 80, 6, 4, preload("res://ores/nugget_ore.tscn"))
var BAND_CONFIG = OreChunkConfig.new([80, 120], 80, 6, 4, preload("res://ores/band_ore.tscn"))
var BALL_CONFIG = OreChunkConfig.new([15, 25], 100, 6, 4, preload("res://ores/ball_ore.tscn"))

class CrackConfig:
	var min_width: int
	var max_width: int
	var crack_variance: int 
	var width_variance: int
	var max_variance: int
	var animation_delay: float
	var segment_size: int
	
	
	func _init(min_width: int, max_width: int, crack_variance: int, width_variance: int, 
			max_variance: int, animation_delay: float = 0.0, segment_size: int = 15):
		
		self.min_width = min_width
		self.max_width = max_width
		self.crack_variance = crack_variance	
		self.width_variance = width_variance
		self.max_variance = max_variance
		self.animation_delay = animation_delay
		self.segment_size = segment_size

class OreChunkConfig: 
	var ore_width: Array[int]
	var density: int
	var max_ore: int
	var max_fails: int 
	var ore_type: PackedScene
	
	func _init(ore_width: Array[int], density: int, max_ore: int, max_fails: int, ore_type: PackedScene):
		self.ore_width = ore_width
		self.density = density
		self.max_ore = max_ore
		self.max_fails = max_fails
		self.ore_type = ore_type
	
