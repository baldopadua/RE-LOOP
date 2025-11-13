extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var canvas_layer = $CanvasLayer

@onready var switch_circle = $switch_circle
@onready var isaac_newton_1 = $isaac_newton_1
@onready var isaac_newton_2 = $isaac_newton_2
@onready var tree = $tree
@onready var seed = $seed

func _ready():
	# SET LEVEL
	level_handler.set_current_level(6)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	
	player.rotation = deg_to_rad(180.0)
	
	GlobalVariables.player_stopped = true
	player.set_process_input(false)
	
	await get_tree().create_timer(1.0).timeout
	
	# HIDE THE UI DURING CINEMA
	ui_handler.hide_game_ui_elements()
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
	switch_circle.visible = true
	isaac_newton_1.visible = true
	isaac_newton_2.visible = true
	tree.visible = true
	seed.visible = true
	# Reveal all the keystones here

	# Fade out animation
	flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
	await get_tree().create_timer(2.0).timeout
	
	GlobalVariables.player_stopped = false
	player.set_process_input(true)
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	# SHOW AGAIN THE UI AFTER
	ui_handler.show_game_ui_elements()
	
# ADD THIS METHOD AS A TEMPORARY WAY TO ENTER LEVELS 7 TO 12, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	
