extends object_class

var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween

var is_playing: bool = false	

func _on_body_entered(body) -> void:
	handle_body_entered(body) 
	
	# CLIMB THE TREE
	if not GlobalVariables.is_looping and not is_playing:
		
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		
		await get_tree().create_timer(1).timeout
		
		# PLAY CLIMB ANIMATION
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		tween_climb = create_tween()
		
		# Connect tween_finished if not yet connected
		if not tween_climb.is_connected("finished", _tween_climb_finished):
			tween_climb.connect("finished", _tween_climb_finished)
			
		var screen_center = Vector2(0.0, 250.0)
		tween_climb.tween_property(body, "position", screen_center, 1.5).set_trans(Tween.TRANS_LINEAR)
		await tween_climb.finished
		
		body.visible = false
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
	get_parent().get_tree().change_scene_to_file("res://Scenes/levels/level_2_scene.tscn")

func _tween_climb_finished():
	tween_climb.kill()

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()
