extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var player_body: Node


var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var gun = $Gun # Make sure this matches your gun node path

func _ready():
	# SET LEVEL
	level_handler.set_current_level(8)
	
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	
#	OBject initialize

	player.rotation = deg_to_rad(240.0)
	if gun and gun.has_signal("turtle_win_race"):
		gun.connect("turtle_win_race", Callable(self, "_on_turtle_win_race"))

func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 8:
		level_handler.complete_current_level(get_parent())

func _on_turtle_win_race():
	if level_handler:
		level_handler.complete_current_level(get_parent())
