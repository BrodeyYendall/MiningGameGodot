extends Resource
class_name Level

@export var level_threshold = 0
@export var big_ore: OreSpawn
@export var small_ore: OreSpawn

func _init(level_threshold: int, big_ore: OreSpawn, small_ore: OreSpawn):
	self.level_threshold = level_threshold
	self.big_ore = big_ore
	self.small_ore = small_ore
	
