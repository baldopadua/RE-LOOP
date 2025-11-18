extends object_class

@onready var animated_sprite = $AnimatedSprite2D
var angle_per_move = 30.0
var transition_time = 0.25
var min_rotation = -90.0
var max_rotation = -270.0

func _on_rotate_object(direction: Variant) -> void:
	var tween = create_tween()
		
	# Rotate based on direction
	var rotation_tween: float
	
	if direction == GlobalVariables.Directions.COUNTERCLOCKWISE and round(rad_to_deg(rotation)) > max_rotation:
		animated_sprite.play("walk")
		# Play footstep sound with lower pitch for turtle
		var sound_manager = get_parent().get_node("SoundManager")
		if sound_manager and sound_manager.sfx.has("rabbit_turtle_step"):
			sound_manager.set_sfx_pitch_scale("rabbit_turtle_step", 0.7)
			sound_manager.play_sfx("rabbit_turtle_step")
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		animated_sprite.flip_h = true
	else:
		tween.kill()
		return
		
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(func():
		tween.kill()	
	)
