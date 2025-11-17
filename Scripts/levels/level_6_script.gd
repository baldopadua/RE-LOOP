extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var area_handler = $AreaHandler
@onready var sound_manager = $SoundManager
@onready var canvas_layer = $CanvasLayer

@onready var switch_circle = $switch_circle
@onready var isaac_newton_1 = $isaac_newton_1
@onready var isaac_newton_2 = $isaac_newton_2
@onready var seed = $seed
@onready var seed2 = $seed2
@onready var center_pos = $center_pos

var player_body: Node = null
@onready var anim_handler = $AnimationPlayer

var jump_animation_played := false # Add this flag

func _ready():
	# SET LEVEL
	level_handler.set_current_level(6)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	
	player.rotation = deg_to_rad(180.0)
	
	# Hide player at start
	player.modulate.a = 0.0
	
	object_initialize()
	
	GlobalVariables.player_stopped = true
	player.set_process_input(false)
	
	await get_tree().create_timer(1.0).timeout
	
	# HIDE THE UI DURING CINEMA
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.65)
	player.shake_camera(5.0, 10.0, 2.5)
	
	await get_tree().create_timer(2.5).timeout
	
	# Play crystal transition sound
	if sound_manager and sound_manager.sfx.has("crystal_transition"):
		sound_manager.play_sfx("crystal_transition")

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
	seed.visible = true
	seed2.visible = true
	# Reveal all the keystones here

	# Fade out animation
	flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
	await get_tree().create_timer(2.0).timeout
	
	# Restore player visibility before enabling movement
	player.modulate.a = 1.0
	
	GlobalVariables.player_stopped = false
	player.set_process_input(true)
	
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	# SHOW AGAIN THE UI AFTER
	ui_handler.show_game_ui_elements()
	anim_handler.playback_active = false # AnimationPlayer OFF at start

func object_initialize():
	objects.append(isaac_newton_1)
	objects.append(isaac_newton_2)
	objects.append(seed)
	objects.append(seed2)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animation finished: ", anim_name)
	if anim_name == "climbing_animation":
		# Play jump animation on player sprite after climbing finishes
		if player_body and player_body.has_node("AnimatedSprite2D"):
			var sprite = player_body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("jump")
		# Play jump animation in AnimationPlayer only once
		if not jump_animation_played:
			jump_animation_played = true
			anim_handler.play("jumping_animation")
			await get_tree().create_timer(1.7).timeout
			anim_handler.stop() 
			ui_handler.set_time_indicator_fixed()
			level_handler.complete_current_level(get_parent())
		player_body.get_node("Camera2D").emit_signal("hide_bars")
		player_body.get_node("Camera2D").emit_signal("cam_orig_zoom")
		player_body.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	

# Add this function so player.gd can call it after match
func enable_animation_player():
	jump_animation_played = false # Reset flag when enabling
	anim_handler.playback_active = true

func play_climb_animation(body: Node) -> void:
	self.player_body = body
	anim_handler.play("climbing_animation")


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 6:
		level_handler.complete_current_level(get_parent())
