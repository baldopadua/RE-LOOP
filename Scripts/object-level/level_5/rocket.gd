extends object_class

var rocket_started : bool = false
var ready_for_entering: bool = false
var player_body: Node
@onready var player = $"../PlayerScene"
@onready var timer = $"../Timer"
@onready var temp_timer = $"../temp_timer"
@onready var text = $AnimatedSprite2D/Label
@onready var animationplayer = $"../AnimationPlayer"
var player_still_allowed : bool = true
@onready var level_handler = $"../CanvasLayer/LevelHandler"
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var level_script = get_parent()  # Reference to level script
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var rocket_exit = $"../rocket_exit"


func _process(_delta: float) -> void:
	if rocket_started:
		text.text = str(abs(round(int(timer.time_left))))

func rocket_start():
	ready_for_entering = true
	timer.start(10.0)
	
	# Zoom back to normal
	ui_handler.show_game_ui_elements()
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("hide_bars")
	
	timer.timeout.connect(func():
		
		# Zoom to rocket when it's about to launch
		ui_handler.hide_game_ui_elements()
		player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
		player.get_node("Camera2D").emit_signal("reveal_bars")
		player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
		
		await get_tree().create_timer(1.0).timeout

		# Send the rocket out into space
		rocket_started = false
		animationplayer.play("rocket_animation")
		text.visible = false
		player_still_allowed = false
	)
	rocket_started = true
	await get_tree().create_timer(11.0).timeout
	GlobalVariables.player_stopped = true
	await get_tree().create_timer(3.0).timeout
	# Play all finish_level_sfx SFX at once
	if sound_manager.has_method("play_finish_level_sfx"):
		sound_manager.play_finish_level_sfx()
	z_index = 1
	area_handler.show_loop_break(5)
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.8)
	player.get_node("Camera2D").emit_signal("pan_to_pos", rocket_exit.global_position)
	await get_tree().create_timer(1.9).timeout
	player.get_node("Camera2D").emit_signal("hide_bars")
	

func _on_body_entered(body) -> void:
	if ready_for_entering and player_still_allowed:
		handle_body_entered(body)
		
		if body.name == "PlayerScene":
			GlobalVariables.player_stopped = true
			level_script.player_has_entered = true  # Use level_script reference
			var tween = create_tween()
			tween.tween_property(body, "modulate", Color(0.0, 0.0, 0.0, 0.0), 1.5)
			tween.finished.connect(func():
				body.visible = false
				tween.kill()
			)


