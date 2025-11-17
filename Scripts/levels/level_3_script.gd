extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene
@onready var geyser: object_class = $geyser
@onready var rock1: object_class = $Rock1
@onready var rock2: object_class = $Rock2
@onready var rock3: object_class = $Rock3
@onready var rock4: object_class = $Rock4
@onready var rock5: object_class = $Rock5
var objects: Array = []

# HANDLERS
@onready var sound_manager = $SoundManager
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# TWEENS
var tween_rotate: Tween
var tween_scale: Tween

# FOCUS MARKERS
@onready var pos_to_focus = $pos_to_focus


func _ready():
	# SET LEVEL
	level_handler.set_current_level(3)
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	objects_initialize()
	# SHOW DECORATIVES
	area_handler.show_decoratives(3)
	player.rotation = deg_to_rad(90.0)

func objects_initialize():
	# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(geyser)
	objects.append(sound_manager) # Add SoundManager to objects array

func play_level3_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 


func _on_level_handler_map_scale_tween_finished() -> void:
		# EXECUTE INITIAL CAMERA CUTSCENES FIRST
	
	GlobalVariables.player_stopped = true
	
	# REQUIRED TO LET THEM LOAD FIRST
	await get_tree().create_timer(1.0).timeout
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 3.5)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", rock3.global_position)
	await get_tree().create_timer(2.0).timeout
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", geyser.global_position)
	await get_tree().create_timer(2.0).timeout
	
	ui_handler.show_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	
	GlobalVariables.player_stopped = false


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	# Only complete if this is the current level
	if level_number == 3:
		level_handler.complete_current_level(get_parent())
