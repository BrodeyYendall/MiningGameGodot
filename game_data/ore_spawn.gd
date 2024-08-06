extends Resource
class_name OreSpawn

@export var chunk_size = 400
@export var hitbox_size = 600
@export var max_fails = 1
@export var max_count = 2
@export var ore_table = [["copper", 100]]

func _init(chunk_size: int, hitbox_size: int, max_fails: int, max_count: int, ore_table: Array):
	self.chunk_size = chunk_size
	self.hitbox_size = hitbox_size
	self.max_fails = max_fails
	self.max_count = max_count
	self.ore_table = ore_table
