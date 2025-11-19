extends Node2D

# ALL THE OBJECTS FOR THE PLAYER
@onready var objects: Array = []
@onready var player = $PlayerScene

# HANDLERS
@onready var area_handler = $AreaHandler
@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# LEVEL 5 OBJECTS
@onready var science_project = $science_project
@onready var vending = $vending
@onready var rocket = $rocket
@onready var dreamer = $dreamer

# PLAYER STATE AND LABEL
var player_has_entered: bool = false
var level_completed: bool = false  # NEW: Prevent multiple completions
@onready var upper_bar = $CanvasLayer/upper_bar
@onready var lower_bar = $CanvasLayer/lower_bar

# TWEENS
@onready var tween_rotate: Tween
@onready var tween_scale: Tween


signal level_5_completed 

func _ready():
	# SET LEVEL
	level_handler.set_current_level(5)
	
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	# SHOW DECORATIVES
	area_handler.show_decoratives(5)
	# PLAY LEVEL AMBIENCE
	if sound_manager:
		sound_manager.play_level_ambience()
	# MANIPULATING OBJECTS APPENDED IN ARRAY
	objects_initialize()
	
	player.rotation = deg_to_rad(150.0)

func objects_initialize():
	objects.append(science_project)
	objects.append(vending)
	objects.append(rocket)
	objects.append(dreamer)
	objects.append(sound_manager)

func play_level5_sfx(sfx_name: String):
	if sound_manager and sound_manager.sfx.has(sfx_name):
		sound_manager.play_sfx(sfx_name)

func play_rocket_countdown():
	play_level5_sfx("rocket_countdown")

func play_rocket_launch_sequence():
	play_level5_sfx("rocket_ignition")
	await get_tree().create_timer(2.0).timeout
	play_level5_sfx("rocket_launch")

func play_science_project_activate():
	play_level5_sfx("science_project_activate")


func _on_level_handler_map_scale_tween_finished() -> void:
	# EXECUTE INITIAL CAMERA CUTSCENES FIRST
	# SUBTLE CAMERA PAN HINT
	
	GlobalVariables.player_stopped = true
	
	# REQUIRED TO LET THEM LOAD FIRST
	await get_tree().create_timer(1.0).timeout
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", dreamer.global_position)
	await get_tree().create_timer(1.5).timeout
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", vending.global_position)
	await get_tree().create_timer(1.5).timeout
	
	ui_handler.show_game_ui_elements()
	
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	
	GlobalVariables.player_stopped = false

# If the rocket animation is finished go to level 6
func _on_animation_player_animation_finished(anim_name: StringName) -> void:

	if level_completed:
		return
		
	if anim_name == "rocket_animation":
		
		# DISCONNECT immediately to prevent re-triggers
		if $AnimationPlayer.is_connected("animation_finished", _on_animation_player_animation_finished):
			$AnimationPlayer.disconnect("animation_finished", _on_animation_player_animation_finished)
			
		if not player_has_entered:
			await get_tree().create_timer(1.0).timeout
			GlobalVariables.player_stopped = true
			ui_handler.hide_game_ui_elements()
			player.get_node("Camera2D").emit_signal("pan_to_pos", player.get_node("AnimatedSprite2D").global_position)
			player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
			player.get_node("Camera2D").emit_signal("reveal_bars")
			DialogueManager.show_dialogue_balloon_scene("res://dialogues/made/balloon.tscn", load("res://dialogues/forgot.dialogue"), "", [self])
			DialogueManager.dialogue_ended.connect(func(_resource: DialogueResource):
				await get_tree().create_timer(1.0).timeout
				level_handler.restart_level(get_parent())
			)
		else:
			# Mark as completed BEFORE calling level handler
			level_completed = true
			emit_signal("level_5_completed")
			# Player successfully entered the rocket and animation finished
			ui_handler.set_time_indicator_fixed()
			player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
			player.get_node("Camera2D").emit_signal("cam_orig_zoom")
			
			await get_tree().process_frame # Wait for animation to visually finish
			level_handler.complete_current_level(get_parent())
			player.get_node("Camera2D").emit_signal("hide_bars")
			# Permanently remove bars so they can't come back
			if upper_bar:
				upper_bar.queue_free()
			if lower_bar:
				lower_bar.queue_free()


func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 5:
		level_handler.complete_current_level(get_parent())
