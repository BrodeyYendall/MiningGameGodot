extends Resource
class_name Levels

@export var levels = [
	Level.new(0, 
		OreSpawn.new(100, 0.25, 1, {
			"iron": 100
		}), 
		OreSpawn.new(0, 0, 0, {})
	),
	Level.new(3, 
		OreSpawn.new(100, 0.25, 1, {
			"iron": 100
		}), 
		OreSpawn.new(0.25, 0.2, 1, {
			"copper": 75,
			"iron": 25
		})
	),
	Level.new(5, 
		OreSpawn.new(100, 0.25, 1, {
			"iron": 100
		}), 
		OreSpawn.new(0.5, 0.25, 1, {
			"copper": 75,
			"iron": 25
		})
	),
	Level.new(8, 
		OreSpawn.new(100, 0.25, 1, {
			"iron": 100
		}), 
		OreSpawn.new(0.75, 0.25, 2, {
			"copper": 75,
			"iron": 25
		})
	),
	Level.new(10, 
		OreSpawn.new(100, 0.25, 1, {
			"iron": 50,
			"copper": 50
		}), 
		OreSpawn.new(0.75, 0.25, 2, {
			"iron": 50,
			"copper": 50
		})
	),
]
