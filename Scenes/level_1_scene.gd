extends Node2D

@export var source_tilemap: TileMapLayer

func _ready():
	for i in range(1, 360):
		var cloned = source_tilemap.duplicate()
		cloned.rotate(deg_to_rad(i))
		add_child(cloned)
