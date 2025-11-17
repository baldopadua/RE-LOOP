extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# Objects
@onready var butterfly = $butterfly
@onready var spider = $spider
@onready var flower = $flower
@onready var wind = $wind

func _ready():
	# SET LEVEL
	level_handler.set_current_level(7)
	
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()

	objects_initialize()

	player.rotation = deg_to_rad(210.0)

func objects_initialize():
	objects.append(butterfly)
	objects.append(spider)
	objects.append(flower)


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 7:
		level_handler.complete_current_level(get_parent())
