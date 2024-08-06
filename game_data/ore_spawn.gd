extends Resource
class_name OreSpawn

@export var wall_count_threshold: int = 1
@export var max_fails: int = 1
@export var max_count: int = 2
@export var ore_table: Array[OreTableRow]


func _init(wall_count_threshold: int, max_fails: int, max_count: int, ore_table: Array[OreTableRow]):
	self.wall_count_threshold = wall_count_threshold
	self.max_fails = max_fails
	self.max_count = max_count
	self.ore_table = ore_table
	
func _to_string():
	return "{threshold=%s, fails=%s, max=%s, ore_table=%s}" % [wall_count_threshold, max_fails, max_count, str(ore_table)]
