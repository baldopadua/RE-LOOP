extends Node2D

@export var source_tilemap: TileMapLayer
@export var radius := 300.0
@export var center := Vector2(0,0)

func _ready():
	draw_circular_level()

func draw_circular_level():
	var tile_size = source_tilemap.tile_set.tile_size.x
	var length = source_tilemap.get_used_rect().size.x

	for i in range(length):
		var tile_id = source_tilemap.get_cell_source_id(Vector2i(i, 0))
		if tile_id == -1:
			continue

		# Calculate position around circle
		var percent = float(i) / length
		var angle = percent * TAU
		var pos = center + Vector2(cos(angle), sin(angle)) * radius

		# Spawn tile manually as Sprite2D (or use a new circular TileMap)
		var tile_sprite = Sprite2D.new()
		tile_sprite.texture = source_tilemap.tile_set.get_source(tile_id).texture
		tile_sprite.position = pos
		tile_sprite.rotation = angle + PI / 2
		tile_sprite.centered = true
		add_child(tile_sprite)
