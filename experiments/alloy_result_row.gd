extends GridContainer
class_name AlloyResultRow

func set_data(name: String, swing: float, power: float, durability: float, weight: float, sharp: float, tier: String):
	$Tier.text = tier
	$Name.text = name
	$Swing.text = str(swing)
	$Power.text = str(power)
	$Durability.text = str(durability)
	$Weight.text = str(weight)
	$Sharp.text = str(sharp)
