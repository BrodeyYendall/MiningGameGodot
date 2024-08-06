extends Area2D

var ore_vertices: PackedVector2Array
var oreType: OreTypes.OreType
var size = 0

signal ore_cutout(ore: OreTypes.OreType, size: int)

var VARIANCE = 4
var MAX_VARIANCE = 8
var SEGMENT_SIZE = 32
var TOTAL_RADIUS = 64

func generate_ore(oreType: OreTypes.OreType, size: int):
	self.oreType = oreType
	self.size = size
	ore_vertices = PackedVector2Array()
	var offset = 0
	
	var segment_ratio = TOTAL_RADIUS / SEGMENT_SIZE
	
	for segment in range(SEGMENT_SIZE):
		offset = randi_range(max(0, offset - VARIANCE), min(MAX_VARIANCE, offset + VARIANCE))
		
		self.size += offset * segment_ratio
		var angle = (PI * 2 / SEGMENT_SIZE) * segment
		var x = offset + size * cos(angle)
		var y = offset + size * sin(angle)
		ore_vertices.append(Vector2(x, y))
	$hitbox.polygon = ore_vertices

func _draw():
	draw_colored_polygon(ore_vertices, OreTypes.get_ore_color(oreType))


func _on_area_entered(area):
	if area is Cutout:
		ore_cutout.emit(oreType, size)
