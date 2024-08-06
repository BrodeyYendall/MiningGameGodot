extends GridContainer

var count: int = 1

func with_data(ore: OreTypes.OreType):
	$label.text = OreTypes.get_ore_name(ore) + ":"
	$count.text = str(count)

func increment_count(amount: int = 1.0):
	count += amount
	$count.text = str(count)
