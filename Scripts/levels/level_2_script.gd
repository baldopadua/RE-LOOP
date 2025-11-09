extends Node2D

# TILEMAP AND PLAYER
@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

# OBJECTS
@onready var old_man: object_class = $old_man
@onready var sword: object_class = $Sword
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
@onready var initial_oldman_focus = $initial_oldman_focus
@onready var pos_to_focus = $pos_to_focus

func _ready():
	# SET LEVELd
	level_handler.set_current_level(2)
	# INTRO OF MAP ROTATE AND SCALE PLUS TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# SHOW DECORATIVES
	area_handler.show_decoratives(2)
	player.rotation = deg_to_rad(60.0)

	# INITIALIE OBJECTS
	objects_initialize()
	
func objects_initialize():
	objects.append(old_man)
	objects.append(sword)

# Example function to play a sound effect using the centralized sound manager
func play_level2_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

func _on_level_handler_map_scale_tween_finished() -> void:
	# EXECUTE INITIAL CAMERA CUTSCENES FIRST
	# SUBTLE CAMERA PAN HINT
	
	GlobalVariables.player_stopped = true
	
	# REQUIRED TO LET THEM LOAD FIRST
	await get_tree().create_timer(1.0).timeout
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", old_man.global_position)
	
	await get_tree().create_timer(2.0).timeout
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", sword.global_position)
	
	await get_tree().create_timer(2.0).timeout
	ui_handler.show_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	
	GlobalVariables.player_stopped = false

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent())
