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
@onready var finish_line = $"Finish Line"
@onready var start_line = $"Start Line"

signal level_8_completed

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
	
	initial_cam_scene()

func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 8:
		level_handler.complete_current_level(get_parent())

func _on_turtle_win_race():
	if level_handler:
		level_handler.complete_current_level(get_parent())
	emit_signal("level_8_completed")
func initial_cam_scene():
	ui_handler.hide_game_ui_elements()
	var p = player.get_node("Camera2D")
	player.set_process_input(false)
	await get_tree().create_timer(1.0).timeout
	p.emit_signal("reveal_bars")
	p.emit_signal("cam_zoom", 1.5)
	p.emit_signal("pan_to_pos", finish_line.global_position)
	await get_tree().create_timer(1.5).timeout
	p.emit_signal("pan_to_pos", start_line.global_position)
	await get_tree().create_timer(1.5).timeout
	p.emit_signal("pan_to_pos", gun.global_position)
	await get_tree().create_timer(1.5).timeout
	p.emit_signal("cam_orig_zoom")
	p.emit_signal("pan_to_orig_pos")
	p.emit_signal("hide_bars")
	player.set_process_input(true)
	ui_handler.show_game_ui_elements()
