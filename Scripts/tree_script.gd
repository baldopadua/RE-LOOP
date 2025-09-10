extends object_class

var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween
var level_2 = preload("res://Scenes/levels/level_2_scene.tscn")
var time_indicator: AnimatedSprite2D
var is_playing: bool = false	
@onready var sound_manager = $SoundManager

func _ready() -> void:
	pass

func _on_body_entered(body) -> void:
	print("[DEBUG] _on_body_entered called. is_playing:", is_playing, " GlobalVariables.is_looping:", GlobalVariables.is_looping)
	handle_body_entered(body) 
	# CLIMB THE TREE
	if not GlobalVariables.is_looping and not is_playing:
		print("[DEBUG] Entering climb logic.")
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		await get_tree().create_timer(1).timeout
		# Set time_indicator to fixed and reset to frame 0
		var root = get_tree().root
		print("[DEBUG] root node:", root)
		if root.has_node("MainScene/UiHandler"):
			var ui_handler = root.get_node("MainScene/UiHandler")
			print("[DEBUG] Found UiHandler node:", ui_handler)
			if ui_handler.has_method("set_time_indicator_fixed"):
				ui_handler.set_time_indicator_fixed()
			else:
				print("[DEBUG] UiHandler has no method set_time_indicator_fixed.")
		else:
			print("[DEBUG] MainScene/UiHandler not found in root.")
		# PLAY CLIMB ANIMATION
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			print("[DEBUG] Found AnimatedSprite2D node in body:", sprite)
			sprite.stop()
			sprite.play("climb")
		else:
			print("[DEBUG] AnimatedSprite2D not found in body.")
		# CLIMB
		tween_climb = create_tween()
		# Connect tween_finished if not yet connected
		if not tween_climb.is_connected("finished", _tween_climb_finished):
			tween_climb.connect("finished", _tween_climb_finished)
		print("[DEBUG] Playing climb SFX.")
		sound_manager.play_player_sfx("Climb")
		var screen_center = Vector2(0.0, 250.0)
		tween_climb.tween_property(body, "position", screen_center, 1.5).set_trans(Tween.TRANS_LINEAR)
		await tween_climb.finished
		body.visible = false
		print("[DEBUG] Finished climb tween, switching scene.")
		# SWITCH SCENE TO LEVEL 2
		go_to_level_2()
		
func go_to_level_2():
	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	# Connect tween_finished if not yet connected
	if not tween_rotate.is_connected("finished", _tween_rotation_finished):
		tween_rotate.connect("finished", _tween_rotation_finished)
	var rotation_tween = get_parent().rotation - deg_to_rad(-360.0)
	tween_rotate.tween_property(get_parent(), "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	# Connect tween_finished if not yet connected
	if not tween_scale.is_connected("finished", _tween_scale_finished):
		tween_scale.connect("finished", _tween_scale_finished)
	tween_scale.tween_property(get_parent(), "scale", Vector2(0.0,0.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await tween_scale.finished
	await get_tree().create_timer(1).timeout
	
	# NEXT LEVEL
	GlobalVariables.change_level("res://Scenes/levels/level_2_scene.tscn", get_parent().get_parent())

func _tween_climb_finished():
	tween_climb.kill()

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()
