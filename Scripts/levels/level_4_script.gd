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

@onready var bone = $bone
@onready var chicken = $chicken
@onready var lizard = $lizard
@onready var dog = $dog
@onready var incubator = $incubator
@onready var trex = $trex
@onready var stick = $stick
@onready var lvl4_seed = $lvl4_seed
@onready var lvl4_soil = $lvl4_soil

# FOCUS MARKERS
@onready var pos_to_focus = $pos_to_focus

signal level_4_completed 

func _ready():
	# SET LEVEL
	level_handler.set_current_level(4)
	
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# SHOW DECORATIVES
	area_handler.show_decoratives(4)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	objects_initialize()
	
	player.rotation = deg_to_rad(120.0)
	trex.visible = false

func objects_initialize():
		# APPEND THE OBJECTS IN THE OBJECTS ARRAY HERE
	# THIS WILL BE REFERENCED BY THE PLAYER LATER ON SO DONT FORGET THIS!
	objects.append(bone)
	objects.append(chicken)
	objects.append(lizard)
	objects.append(dog)
	objects.append(incubator)
	objects.append(trex)
	objects.append(stick)
	objects.append(sound_manager)

func play_incubator_processing():
	if sound_manager and sound_manager.sfx.has("idle_incubator"):
		sound_manager.play_sfx("idle_incubator")

func play_trex_evolution():
	if sound_manager and sound_manager.sfx.has("incubator_complete"):
		sound_manager.play_sfx("incubator_complete")
	await get_tree().create_timer(0.5).timeout  
	
# If the Plooy being tail whipped animation is finished go to level 5
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tail_whipped":
		# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
		ui_handler.set_time_indicator_fixed()
		await get_tree().create_timer(1).timeout
		level_handler.complete_current_level(get_parent())
		emit_signal("level_4_completed")

func _on_level_handler_map_scale_tween_finished() -> void:
		# EXECUTE INITIAL CAMERA CUTSCENES FIRST
	# SUBTLE CAMERA PAN HINT
	
	GlobalVariables.player_stopped = true
	
	# REQUIRED TO LET THEM LOAD FIRST
	await get_tree().create_timer(1.0).timeout
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", chicken.global_position)
	await get_tree().create_timer(1.5).timeout
	player.get_node("Camera2D").emit_signal("pan_to_pos", lizard.global_position)
	await get_tree().create_timer(1.5).timeout
	player.get_node("Camera2D").emit_signal("pan_to_pos", lvl4_seed.global_position)
	await get_tree().create_timer(1.5).timeout
	player.get_node("Camera2D").emit_signal("pan_to_pos", lvl4_soil.global_position)
	await get_tree().create_timer(1.5).timeout
	player.get_node("Camera2D").emit_signal("pan_to_pos", dog.global_position)
	await get_tree().create_timer(1.5).timeout
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", incubator.global_position)
	await get_tree().create_timer(2.0).timeout
	
	ui_handler.show_game_ui_elements()
	
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	
	GlobalVariables.player_stopped = false

func _on_dog_add_cur_state(_direction):
	pass # Replace with function body.


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 4:
		level_handler.complete_current_level(get_parent())
		
