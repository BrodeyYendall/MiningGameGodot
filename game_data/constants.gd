extends Node

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

const HOLE_SIZE = 5
var CUTOUT_CRACK_CONFIG = CrackConfig.new(6, 12, 5, 3, 10, 0.04)
var LARGE_CRACK_CONFIG = CrackConfig.new(10, 40, 15, 5, 1000)

var CHUNK_ORE_CONFIG = CrackConfig.new(40, 50, 5, 5, 10, 0.0, 10)
var BAND_ORE_CONFIG = CrackConfig.new(20, 24, 2, 2, 4, 0.0, 10)

var NUGGET_CONFIG = OreChunkConfig.new([30, 70], 80, 6, 4, preload("res://ores/nugget_ore.tscn"))
var BAND_CONFIG = OreChunkConfig.new([100, 200], 80, 6, 4, preload("res://ores/band_ore.tscn"))
var BALL_CONFIG = OreChunkConfig.new([30, 50], 100, 6, 4, preload("res://ores/ball_ore.tscn"))

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
	
