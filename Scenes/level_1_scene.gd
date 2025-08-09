extends Node2D

@export var source_tilemap: TileMapLayer
var center_circle: Vector2i = Vector2i(0,0)

func _ready():
	#for i in range(1, 5):
		#draw_circle_from_tilemap(Vector2i(i,i), 200)
	pass

func draw_circle_from_tilemap(center: Vector2i, radius: int) -> void:
	var x: int = 0
	var y: int = -radius
	var p: int = -radius

	while x < -y:
		if p >= 0:
			y += 1
			p += 2*(x+y) + 1
		else:
			p += 2*x + 1

	source_tilemap.set_cell(Vector2i(center.x + x, center.y + y), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x - x, center.y + y), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x + x, center.y - y), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x - x, center.y - y), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x + y, center.y + x), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x + y, center.y - x), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x - y, center.y + x), 1, Vector2i(0,0))
	source_tilemap.set_cell(Vector2i(center.x - y, center.y - x), 1, Vector2i(0,0))
	
	#print(center.x + x, center.y + y)
	#print(center.x - x, center.y + y)
	#print(center.x + x, center.y - y)
	#print(center.x - x, center.y - y)
	#print(center.x + y, center.y + x)
	#print(center.x + y, center.y - x)
	#print(center.x - y, center.y + x)
	#print(center.x - y, center.y - x)

	x += 1
