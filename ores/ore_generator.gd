extends Node2D

@export var level: Levels

var ore_chunk_scene = preload("res://ores/ore_chunk.tscn")

func _generate_ores(seed: int):
	var ore = ore_chunk_scene.instantiate()  
	ore.generate_with_config(OreTypes.OreType.ZINC, get_parent()._ore_cutout)
	ore.position = Vector2(600, 600)
	add_child(ore)
	
	ore = ore_chunk_scene.instantiate()  
	ore.generate_with_config(OreTypes.OreType.COPPER, get_parent()._ore_cutout)
	ore.position = Vector2(100, 100)
	add_child(ore)
	
	ore = ore_chunk_scene.instantiate()  
	ore.generate_with_config(OreTypes.OreType.IRON, get_parent()._ore_cutout)
	ore.position = Vector2(1100, 100)
	add_child(ore)
