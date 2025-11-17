extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager

func _ready():
	# SET LEVEL
	level_handler.set_current_level(12)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	
	# PLAY SPECIAL FINAL LEVEL MUSIC
	if sound_manager:
		sound_manager.stop_music("main_bgm")
		sound_manager.stop_ambience_music("space_ambience")
		sound_manager.play_music("final_level_bgm")

# ADD THIS METHOD AS A TEMPORARY WAY TO FINISH LEVEL, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# STOP FINAL LEVEL MUSIC BEFORE COMPLETING
	if sound_manager:
		sound_manager.stop_music("final_level_bgm")
	
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 12:
		level_handler.complete_current_level(get_parent())
