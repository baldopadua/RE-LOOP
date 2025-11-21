extends object_class

var rocket_started : bool = false
var ready_for_entering: bool = false
var player_body: Node
@onready var player = $"../PlayerScene"
@onready var timer = $"../Timer"
@onready var text = $AnimatedSprite2D/Label
@onready var animationplayer = $"../AnimationPlayer"
var player_still_allowed : bool = true
@onready var level_handler = $"../CanvasLayer/LevelHandler"
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var level_script = get_parent()  # Reference to level script
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var rocket_exit = $"../rocket_exit"
@onready var animated_sprite = $AnimatedSprite2D
@onready var science_project = $"../science_project"
@onready var soda = $"../soda"
@onready var dreamer = $"../dreamer"

func _process(_delta: float) -> void:
	if rocket_started:
		text.text = str(abs(round(int(timer.time_left))))

func rocket_start():
	await get_tree().create_timer(3.0).timeout
	ready_for_entering = true
	timer.start(10.0)
	
	timer.timeout.connect(func():
		player_still_allowed = false
		text.hide()
		player.set_process_input(false)
		# Zoom to rocket when it's about to launch
		ui_handler.hide_game_ui_elements()
		player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
		player.get_node("Camera2D").emit_signal("reveal_bars")
		player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
		
		await get_tree().create_timer(1.0).timeout

		# Send the rocket out into space
		rocket_started = false
		animationplayer.play("rocket_animation")
		
		await get_tree().create_timer(4.0).timeout
		player.get_node("Camera2D").emit_signal("pan_to_pos", rocket_exit.global_position)
		
		await get_tree().create_timer(1.0).timeout
		
		player.set_process_input(true)
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

func set_rocket():	
	player.set_process_input(false)
	
	#		Camera
	player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
	
	visible = true
	animated_sprite.play("rocket_ship")
	science_project.visible = false
	
	await animated_sprite.animation_finished
	# Set dreamer animation to astronaut
	if sound_manager:
		sound_manager.play_sfx("astronaut_transform")
		
	soda.visible = false
	soda.is_pickupable = false
	
	var d_anim : AnimatedSprite2D= dreamer.get_node("AnimatedSprite2D")
	d_anim.play("astronaut")
	
	d_anim.animation_finished.connect(func():
		if dreamer.is_connected("add_cur_state", Callable(dreamer, "_on_add_cur_state")):
			dreamer.disconnect("add_cur_state", Callable(dreamer, "_on_add_cur_state"))
		if sound_manager:
			sound_manager.play_sfx("rocket_blastoff")
		science_project.visible = false
		GlobalVariables.player_stopped = false
		
		await get_tree().create_timer(1.0).timeout
		
		ui_handler.show_game_ui_elements()
		player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
		player.get_node("Camera2D").emit_signal("cam_orig_zoom")
		player.get_node("Camera2D").emit_signal("hide_bars")
		dreamer.hide()
		player.set_process_input(true)
		rocket_start()
	)
