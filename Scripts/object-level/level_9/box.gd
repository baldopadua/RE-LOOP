extends object_class

@warning_ignore("unused_signal")
signal close_box(cat)
signal open_box # New signal

@onready var cat = $"../cat"
@onready var cat2 = $"../cat2"
@onready var player = $"../PlayerScene"
@onready var box_down_marker = $"../box_down_marker"
@onready var schrodinger = $"../schrodinger"
@onready var sound_manager = $"../SoundManager"

var cat_placed = false
var cat2_placed = false
var box_closed = false
var is_loop_broken = false

@onready var animation_sprite = $AnimatedSprite2D
var float_tween : Tween

@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

func _ready() -> void:
	float_box()
	
func float_box() -> void:
	float_tween = create_tween()
	float_tween.set_loops()
	var float_offset := -5.0
	var duration := 1.0
	float_tween.tween_property(self, "position:y", self.position.y + float_offset, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	float_tween.tween_property(self, "position:y", self.position.y, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_close_box(cat_arg: Variant) -> void:
	if cat_arg.object_name == "cat":
		cat_placed = true
	elif cat_arg.object_name == "cat2":
		cat2_placed = true
	
	if cat_placed and cat2_placed:
		# Camera animations
		if cat.current_state == cat2.current_state:
			# play box close function
			close_box_function()
			

func close_box_function():
	player.set_process_input(false)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("pan_to_pos", global_position)
	
	await get_tree().create_timer(1.5).timeout
	
	# Play box closing SFX
	if sound_manager and sound_manager.sfx.has("box_closing"):
		sound_manager.play_sfx("box_closing")
	
	animation_sprite.play("activate")

	await get_tree().create_timer(1.5).timeout

	cat.visible = false
	cat2.visible = false

	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	player.set_process_input(true)
	box_closed = true

func open_box_function():
	player.set_process_input(false)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	player.get_node("Camera2D").emit_signal("pan_to_pos", box_down_marker.global_position)
	await get_tree().create_timer(1.0).timeout	
	_on_open_box_animation_finished("activate") 
	
	# Show the cat at frame 2
	#cat.visible = true

func _on_open_box_animation_finished(anim_name: StringName) -> void:
	if anim_name == "activate":
		cat.get_node("AnimatedSprite2D").frame = 2
		schrodinger.get_node("AnimatedSprite2D").frame = 0
		schrodinger.get_node("AnimatedSprite2D2").frame = 0
		#emit_signal("open_box")
		
		if float_tween and float_tween.is_valid() and cat.cat_tween and cat.cat_tween.is_valid():
			float_tween.kill()
			cat.cat_tween.kill()
			print("Stopped floating tween.")

		# Play loop break sound when box goes down
		if sound_manager and sound_manager.sfx.has("loop_break"):
			sound_manager.play_sfx("loop_break")

		var tween := create_tween()
		cat.create_tween().tween_property(cat, "position:y", 280.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", 280.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.connect("finished", Callable(self, "_on_box_tween_finished"))
		print("Started downward tween.")

func _on_box_tween_finished():
	#print("Box tween finished, new position: ", position)
	
	# Play box opening sound when cats appear
	if sound_manager and sound_manager.sfx.has("box_opening"):
		sound_manager.play_sfx("box_opening")
	
	animation_sprite.play_backwards("activate")
	animation_sprite.animation_finished.connect(func():
		player.get_node("Camera2D").emit_signal("cam_orig_zoom")
		player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
		player.get_node("Camera2D").emit_signal("hide_bars")
		player.set_process_input(true)
		box_closed = false
		is_loop_broken = true
		player.ui_handler.show_game_ui_elements()
		player.set_process_input(true)
		GlobalVariables.player_stopped = false
	)

func _on_body_entered(body) -> void:
	handle_body_entered(body)
	if is_loop_broken:
		player.set_process_input(false)
		ui_handler.hide_game_ui_elements()
		player.get_node("Camera2D").emit_signal("pan_to_pos", cat.global_position)
		player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
		player.get_node("Camera2D").emit_signal("reveal_bars")
		await get_tree().create_timer(1.0).timeout	
		cat.create_tween().tween_property(cat, "position:y", 290.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func():
			await get_tree().create_timer(0.5).timeout	
			player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
			
			# Play box climbing SFX when Plooy ascends
			if sound_manager and sound_manager.sfx.has("box_climb"):
				sound_manager.play_sfx("box_climb")
			
			ui_handler.show_game_ui_elements()
			var tween := create_tween()
			tween.tween_property(self, "position:y", 0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			player.create_tween().tween_property(player.get_node("AnimatedSprite2D"), "position:y", 0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func():
				await get_tree().create_timer(1.0).timeout	
				player.get_node("AnimatedSprite2D").play("jump")
				player.create_tween().tween_property(player.get_node("AnimatedSprite2D"), "position:y", 100.0, 1.0).finished.connect(func():
					player.create_tween().tween_property(player.get_node("AnimatedSprite2D"), "position:y", 20, 0.75)
					player.create_tween().tween_property(player, "modulate:a",  0.0, 0.75).finished.connect(func():
						ui_handler.show_game_ui_elements()
						get_parent().level_handler.complete_current_level(get_parent())
					)
					
				)
			)
		)
		
#	handle here rising up and jumping
