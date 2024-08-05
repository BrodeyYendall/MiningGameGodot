extends GridContainer
class_name OreStatInput

@export var resource_file: String = "res://game_data/ore_stats/coal.tres"
var ore_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	ore_stats = load(resource_file)
	$Name.text = ore_stats.name
	$Sharpness.value = ore_stats.base_sharpness
	$Durabilty.value = ore_stats.base_durability
	$Weight.value = ore_stats.base_weight
	$Power.value = ore_stats.base_power
	$Sharpness_Multipler.value = ore_stats.multiplier_sharpness
	$Durabilty_Multiplier.value = ore_stats.multiplier_durability
	$Weight_Multiplier.value = ore_stats.multiplier_weight
	$Power_Multiplier.value = ore_stats.multiplier_power
	$Critical_Mass.value = ore_stats.critical_mass
	
	
func _input(event):
	if event is InputEventKey and event.is_pressed() && not event.is_echo():
		if event.keycode == KEY_ENTER:
			ore_stats = OreStats.new()
			ore_stats.name = $Name.text
			ore_stats.base_sharpness = $Sharpness.value
			ore_stats.base_durability = $Durabilty.value
			ore_stats.base_weight = $Weight.value
			ore_stats.base_power = $Power.value
			ore_stats.multiplier_sharpness = $Sharpness_Multipler.value
			ore_stats.multiplier_durability = $Durabilty_Multiplier.value
			ore_stats.multiplier_weight = $Weight_Multiplier.value
			ore_stats.multiplier_power = $Power_Multiplier.value
			ore_stats.critical_mass = $Critical_Mass.value
			ResourceSaver.save(ore_stats, resource_file)
			print("Saved " + resource_file)
