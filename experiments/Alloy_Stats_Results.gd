extends GridContainer

var result_row_scene = preload("res://experiments/alloy_result_row.tscn")
var results: Array[Result]
var tiered_only: Array[Result]

var TIERS = {
	"stone[font_size=10]100[/font_size]": "0",
	"copper[font_size=10]100[/font_size]": "1",
	"copper[font_size=10]75[/font_size] zinc[font_size=10]25[/font_size]": "2",
	"iron[font_size=10]75[/font_size] coal[font_size=10]25[/font_size]": "3",
	"iron[font_size=10]50[/font_size] coal[font_size=10]25[/font_size] zinc[font_size=10]25[/font_size]": "4",
	"iron[font_size=10]75[/font_size] zinc[font_size=10]15[/font_size] coal[font_size=10]10[/font_size]": "5"
}

func _calculate_event():
	var ore_stats: Array[OreStats] = []
	results = []
	for ore in get_parent().get_parent().get_node("ore_inputs").get_children():
		if ore is OreStatInput:
			ore_stats.append(ore.ore_stats)

			if get_parent().get_node("Single").button_pressed:
				results.append(calculate_raw_metal(ore.ore_stats))
	
	if get_parent().get_node("Double").button_pressed:	
		for i in range(ore_stats.size()):
			for j in range(ore_stats.size()):
				results.append(calculate_alloy([AlloyRatio.new(ore_stats[i], 75), AlloyRatio.new(ore_stats[j], 25)]))
		
	if get_parent().get_node("Triple").button_pressed:	
		for i in range(ore_stats.size()):
			for j in range(ore_stats.size()):
				for k in range(ore_stats.size()):
					results.append(calculate_alloy([AlloyRatio.new(ore_stats[i], 50), AlloyRatio.new(ore_stats[j], 25), AlloyRatio.new(ore_stats[k], 25)]))
		
	if $"../Any".button_pressed:
		for i in range(ore_stats.size()):
			recursive_form_alloy(ore_stats, [], 0, AlloyRatio.new(ore_stats[i], 5), i)
		
	var dedupe = {}
	var resultsCopy: Array[Result] = []
	for result in results:
		var metal_cost = result.name.count(" ") + 1
		if (metal_cost == 1 and get_parent().get_node("Single").button_pressed) or  \
			(metal_cost == 2 and get_parent().get_node("Double").button_pressed) or \
			(metal_cost == 3 and get_parent().get_node("Triple").button_pressed) or \
			(metal_cost > 3):
				
			if result.name not in dedupe:
				dedupe[result.name] = true
				resultsCopy.append(result)
	results = resultsCopy
	
	dedupe = {}
	resultsCopy = []
	for result in tiered_only:
		if result.name not in dedupe:
			dedupe[result.name] = true
			resultsCopy.append(result)
	tiered_only = resultsCopy
	
	_display_results(get_parent().get_node("Sort_Selection").current_tab)
	
	
	var file = FileAccess.open("res://game_data/ore_stats/stat_analysis.csv", FileAccess.WRITE)
	var result_string = "name,swing,power,durability,weight,sharp\n"
	for result in results:
		result_string += "%s,%s,%s,%s,%s,%s\n" % [result.name.replace("[font_size=10]","").replace("[/font_size]", ""), result.swing, result.power, result.durability, result.weight, result.sharp]
	
	file.store_string(result_string)
	
func recursive_form_alloy(ore_stats: Array[OreStats], current_metals: Array[AlloyRatio], ratio_total: int, to_add: AlloyRatio, min: int):
	var metals_copy: Array[AlloyRatio] = []
	var local_to_add = to_add
	
	var new_metal = true
	for metal in current_metals:
		if metal.ore.name == to_add.ore.name:
			metals_copy.append(AlloyRatio.new(metal.ore, metal.ratio + to_add.ratio))
			new_metal = false
		else:
			metals_copy.append(AlloyRatio.new(metal.ore, metal.ratio))
			
	if new_metal:
		local_to_add = AlloyRatio.new(to_add.ore, to_add.ore.critical_mass)
		metals_copy.append(local_to_add)
	
	if ratio_total + local_to_add.ratio == 100:
		results.append(calculate_alloy(metals_copy, false))
	
	if ratio_total + local_to_add.ratio < 100:
		for i in range(min, ore_stats.size()):
			recursive_form_alloy(ore_stats, metals_copy, ratio_total + local_to_add.ratio, AlloyRatio.new(ore_stats[i], 5), i)
		
	
	
func merge_metals(metals: Array[AlloyRatio]):
	var merges = {}
	for alloy_metal in metals:
		if alloy_metal.ore.name in merges:
			merges[alloy_metal.ore.name]["ratio"] += alloy_metal.ratio
		else:
			merges[alloy_metal.ore.name] = {
				"ore": alloy_metal.ore,
				"ratio": alloy_metal.ratio
			}
			
	metals = []
	for ore_name in merges:
		metals.append(AlloyRatio.new(merges[ore_name]["ore"], merges[ore_name]["ratio"]))
	return metals
	
func calculate_alloy(metals: Array[AlloyRatio], should_merge_metals = true) -> Result:
	if should_merge_metals:
		metals = merge_metals(metals)
	
	var result = OreStats.new()
	
	var sharpness = 0
	var durability = 0
	var weight = 0
	var power = 0
	var ratio_total = 0
	
	for alloy_metal in metals:
		var adjusted_ratio = alloy_metal.ratio / 100.0
		sharpness += alloy_metal.ore.base_sharpness * adjusted_ratio
		durability += alloy_metal.ore.base_durability * adjusted_ratio
		weight += alloy_metal.ore.base_weight * adjusted_ratio
		power += alloy_metal.ore.base_power * adjusted_ratio
		ratio_total += alloy_metal.ratio
	assert(ratio_total == 100, "Got invalid alloy ratio total, ratio = " + str(ratio_total))
	
	for alloy_metal in metals:
		if alloy_metal.ratio >= alloy_metal.ore.critical_mass:
			sharpness *= alloy_metal.ore.multiplier_sharpness
			durability *= alloy_metal.ore.multiplier_durability
			weight *= alloy_metal.ore.multiplier_weight
			power *= alloy_metal.ore.multiplier_power
			
	var alloy_name = create_alloy_name(metals)
	var tier = ""
	if alloy_name in TIERS:
		tier = TIERS[alloy_name]
		tiered_only.append(Result.new(alloy_name, weight, sharpness, power, durability, tier))
			
	return Result.new(alloy_name, weight, sharpness, power, durability, tier)
	
func create_alloy_name(metals: Array[AlloyRatio]):
	metals.sort_custom(sort_alloy_ratio)
	
	var name =  metals[0].ore.name + "[font_size=10]" + str(metals[0].ratio) + "[/font_size]"
	for i in range(1, metals.size()):
		name += " " + metals[i].ore.name + "[font_size=10]" + str(metals[i].ratio) + "[/font_size]"
	return name
	
func sort_alloy_ratio(a: AlloyRatio, b: AlloyRatio):
	if a.ratio == b.ratio: 
		return a.ore.name < b.ore.name
	else:
		return a.ratio > b.ratio
	
func calculate_raw_metal(metal: OreStats) -> Result:
	var result = OreStats.new()
	var sharpness = metal.base_sharpness * metal.multiplier_sharpness
	var durability = metal.base_durability * metal.multiplier_durability
	var weight = metal.base_weight * metal.multiplier_weight
	var power = metal.base_power * metal.multiplier_power
	
	var tier = ""
	if metal.name in TIERS:
		tier = TIERS[metal.name]
		tiered_only.append(Result.new(metal.name, weight, sharpness, power, durability, tier))
	
	return Result.new(metal.name, weight, sharpness, power, durability, tier)
	
	
func _display_results(sort_type: int):
	results.sort_custom(get_sort_function(sort_type))
	tiered_only.sort_custom(get_sort_function(sort_type))
	
	clear_children(self)
	for result in results:
		add_row(self, result.name, result)
		
	clear_children($"../Tiered_Results")
	for result in tiered_only:
		add_row($"../Tiered_Results", result.name, result)
		
func get_sort_function(sort_type: int):
	match sort_type:
		0:
			return 	func(a, b): return a.swing < b.swing
		1:
			return 	func(a, b): return a.power > b.power
		2:
			return 	func(a, b): return a.durability > b.durability
	
func add_row(target: GridContainer, name: String, result: Result):
	var row = result_row_scene.instantiate()
	row.set_data(name, result.swing, result.power, result.durability, result.weight, result.sharp, result.tier)
	target.add_child(row)
	
func clear_children(target: GridContainer):
	for child in target.get_children():
		target.remove_child(child)

class AlloyRatio:
	var ore: OreStats
	var ratio: int
	
	func _init(ore: OreStats, ratio: int):
		self.ore = ore
		self.ratio = ratio
	
	func _to_string():
		return "%s @ %s" % [ore, ratio]

class Result:
	var name: String = ""
	var swing: float = 0.0
	var weight: float = 0.0
	var sharp: float = 0.0
	var power: float = 0.0
	var durability: float = 0.0
	var tier: String = ""
	
	func _init(name: String, weight: float, sharpness: float, power: float, durability: float, tier: String):
		self.name = name
		self.swing = weight * (1 - (sharpness / 100))
		self.power = power
		self.durability = durability
		self.weight = weight
		self.sharp = sharpness
		self.tier = tier
		
	func _to_string():
		return "%s, %s, %s, %s" % [name, swing, power, durability]
