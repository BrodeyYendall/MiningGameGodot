extends Node

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

const HOLE_SIZE = 15
var CUTOUT_CRACK_CONFIG = CrackConfig.new(6, 12, 5, 3, 10, 0.04)
var LARGE_CRACK_CONFIG = CrackConfig.new(10, 40, 15, 5, 1000)


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
