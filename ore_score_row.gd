extends GridContainer

var count: float = 0.0

func with_data(ore: OreTypes.OreType, count: float):
	$label.text = OreTypes.get_ore_name(ore) + ":"
	$count.text = str(count)
	self.count = count

func increment_count(amount: float):
	count += amount
	$count.text = str(count)
