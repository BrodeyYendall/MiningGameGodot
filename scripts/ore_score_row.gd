extends GridContainer

var count: int = 1

func with_data():
	$label.text = "Copper:"
	$count.text = str(count)

func increment_count(amount: int = 1.0):
	count += amount
	$count.text = str(count)
