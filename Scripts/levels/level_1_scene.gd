extends Node2D

@export var source_tilemap: TileMapLayer

# OBJECTS
@onready var seed_obj = $Seed
@onready var soil = $Soil
@onready var tree = $tree

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []
@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
#@onready var anim_handler = $AnimationHandler

var center_circle: Vector2i = Vector2i(0, 0)

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween

# FOCUS MARKERS

@onready var pos_to_focus = $pos_to_focus
@onready var initial_seed_focus = $initial_seed_focus

func _ready():
	# SET LEVEL
	level_handler.set_current_level(1)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# SHOW DECORATIVES
	area_handler.show_decoratives(1)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
	player.rotation = deg_to_rad(30.0)
	

func objects_initialize():
	objects.append(soil)
	objects.append(tree)
	objects.append(seed_obj)
	objects.append(sound_manager)

func play_level1_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent())
	level_handler.complete_current_level(get_parent())


func _on_level_handler_map_scale_tween_finished() -> void:
	
	# EXECUTE INITIAL CAMERA CUTSCENES FIRST
	# SUBTLE CAMERA PAN HINT
	
	GlobalVariables.player_stopped = true
	
 	# REQUIRED TO LET THEM LOAD FIRST
	await get_tree().create_timer(1.0).timeout
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", initial_seed_focus.global_position)
	
	await get_tree().create_timer(2.0).timeout
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", soil.global_position)
	
	await get_tree().create_timer(2.0).timeout
	ui_handler.show_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	
	GlobalVariables.player_stopped = false


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	# Only complete if this is the current level
	if level_number == 1:
		level_handler.complete_current_level(get_parent())
