extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

@onready var monk = $monk
@onready var canvas_layer = $CanvasLayer

# Area Handlers

@onready var area_handler1 = $AreaHandler1
@onready var area_handler2 = $AreaHandler2
@onready var area_handler3 = $AreaHandler3
@onready var area_handler4 = $AreaHandler4
@onready var area_handler5 = $AreaHandler5
@onready var area_handler6 = $AreaHandler6
@onready var area_handler7 = $AreaHandler7
@onready var area_handler8 = $AreaHandler8
@onready var area_handler9 = $AreaHandler9
@onready var area_handler10 = $AreaHandler10
@onready var area_handler11 = $AreaHandler11
@onready var area_handler12 = $AreaHandler12

# Statues

@onready var tree_statue = $tree_statue
@onready var hero_statue = $hero_statue
@onready var geyser_statue = $geyser_statue
@onready var dinosaur_statue = $dinosaur_statue
@onready var rocket_statue = $rocket_statue
@onready var apple_statue = $apple_statue
@onready var butterfly_statue = $butterfly_statue
@onready var turtle_statue = $turtle_statue
@onready var cat_statue = $cat_statue
@onready var electric_statue = $electric_statue
@onready var plooy_statue = $plooy_statue

# Keystones

@onready var seed = $seed
@onready var skull = $skull
@onready var rock = $rock
@onready var egg = $egg
@onready var soda = $soda
@onready var apple = $apple
@onready var butterfly = $butterfly
@onready var carrot = $carrot
@onready var cat = $cat
@onready var lightbulb = $lightbulb

func _ready():
	# SET LEVEL
	level_handler.set_current_level(12)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	GlobalVariables.is_looping = false
	
	player.set_process_input(false)
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.65)
#	Pan to Monk position
	#player.get_node("Camera2D").emit_signal("pan_to_pos", monk.global_position)
	
	await get_tree().create_timer(1.0).timeout
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)
	
	flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.0).timeout
	
#	Rotate the monk to 0 degrees

	var monk_tween = create_tween()
	monk_tween.tween_property(monk, "rotation_degrees", 180.0, 2.0)
	await monk_tween.finished
	
#	Hide Keystones and Statues

	seed.hide()
	skull.hide()
	rock.hide()
	egg.hide()
	soda.hide()
	apple.hide()
	butterfly.hide()
	carrot.hide()
	cat.hide()
	lightbulb.hide()
	
	tree_statue.hide()
	hero_statue.hide()
	geyser_statue.hide()
	dinosaur_statue.hide()
	rocket_statue.hide()
	apple_statue.hide()
	butterfly_statue.hide()
	turtle_statue.hide()
	cat_statue.hide()
	electric_statue.hide()
	plooy_statue.hide()
	
#	Put all Keystone and statues away to prevent player from picking them up
	
	seed.position = Vector2(-9999,-9999)
	skull.position = Vector2(-9999,-9999)
	rock.position = Vector2(-9999,-9999)
	egg.position = Vector2(-9999,-9999)
	soda.position = Vector2(-9999,-9999)
	apple.position = Vector2(-9999,-9999)
	butterfly.position = Vector2(-9999,-9999)
	carrot.position = Vector2(-9999,-9999)
	cat.position = Vector2(-9999,-9999)
	lightbulb.position = Vector2(-9999,-9999)
	
	tree_statue = Vector2(-9999,-9999)
	hero_statue = Vector2(-9999,-9999)
	geyser_statue = Vector2(-9999,-9999)
	dinosaur_statue = Vector2(-9999,-9999)
	rocket_statue = Vector2(-9999,-9999)
	apple_statue = Vector2(-9999,-9999)
	butterfly_statue = Vector2(-9999,-9999)
	turtle_statue = Vector2(-9999,-9999)
	cat_statue = Vector2(-9999,-9999)
	electric_statue = Vector2(-9999,-9999)
	plooy_statue = Vector2(-9999,-9999)
	
	player.shake_camera(5.0, 10.0, 4.0)
	
# 	Fade out animation
	var unflash = create_tween()
	unflash.tween_property(flash, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
#	Tween of the two circle separating	
	area_handler1.create_tween().tween_property(area_handler1, "position:x", -342.0, 3.0)
	area_handler2.create_tween().tween_property(area_handler2, "position:x", 342.0, 3.0)
	
#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position:x", -342.0, 3.0)
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position:x", 342.0, 3.0)
	
	await unflash.finished
	
#	Hide Cinematic Cameras
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	
#	Enable Player Movement
	player.set_process_input(true)
	
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
