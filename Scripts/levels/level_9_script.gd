extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var canvas_layer = $CanvasLayer
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

@onready var cat1 = $cat
@onready var cat2 = $cat2
@onready var schrodinger1 = $schrodinger
@onready var schrodinger2 = $schrodinger2
@onready var box = $box
@onready var lever1 = $lever
@onready var lever2 = $lever2
@onready var switch_circle = $switch_circle
@onready var center_pos = $center_pos

func _ready():
	# SET LEVEL
	level_handler.set_current_level(9)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()

	player.rotation = deg_to_rad(270.0)
	
	object_initialize()
	
	GlobalVariables.player_stopped = true
	player.set_process_input(false)
	
	await get_tree().create_timer(1.0).timeout
	
	# HIDE THE UI DURING CINEMA
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.75)
	player.shake_camera(5.0, 10.0, 2.5)
	
	await get_tree().create_timer(2.5).timeout
	
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 1)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)

	# Do all things before transitionting here...
	area_handler.get_node("world_environment").get_node("map").animation = "other_map"
	player.position.x = -240.0
	# Reveal all the keystones here
	cat1.visible = true
	cat2.visible = true
	schrodinger1.visible = true
	schrodinger2.visible = true
	box.visible = true
	lever1.visible = true
	lever2.visible = true
	switch_circle.visible = true
	
	# Fade out animation
	flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
	await get_tree().create_timer(2.0).timeout
	
	GlobalVariables.player_stopped = false
	player.set_process_input(true)
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	# SHOW AGAIN THE UI AFTER
	ui_handler.show_game_ui_elements()

func object_initialize():
	objects.append(cat1)
	objects.append(cat2)
	objects.append(schrodinger1)
	objects.append(schrodinger2)
	objects.append(box)
	objects.append(lever1)
	objects.append(lever2)

# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 9:
		level_handler.complete_current_level(get_parent())
