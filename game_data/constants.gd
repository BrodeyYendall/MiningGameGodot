extends Node

const SCREEN_WIDTH = 640
const SCREEN_HEIGHT = 360
const BACKGROUND_SCALE = 6

const HOLE_SIZE = 5
var CUTOUT_CRACK_CONFIG = CrackConfig.new(3, 8, 2, 1, 4, 0.04, 10)

var NUGGET_ORE_CONFIG = CrackConfig.new(10, 20, 2, 2, 4, 0.0, 5)
var BAND_ORE_CONFIG = CrackConfig.new(5, 10, 1, 1, 2, 0.0, 5)

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

