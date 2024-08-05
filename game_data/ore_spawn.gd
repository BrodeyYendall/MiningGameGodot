extends Resource
class_name OreSpawn

@export var base_chance = 100
@export var chance_reduction = 0.25
@export var max_fails = 1
@export var ore_table = {
	"iron": 100
}

func _init(base_chance: int, chance_reduction: int, max_fails: int, ore_table: Dictionary):
	self.base_chance = base_chance
	self.chance_reduction = chance_reduction
	self.max_fails = max_fails
	self.ore_table = ore_table
