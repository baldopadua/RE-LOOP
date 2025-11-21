extends object_class

@onready var animated_sprite = $AnimatedSprite2D
var angle_per_move = 30
var transition_time = 0.25
var min_rotation = -90.0
var max_rotation = -270.0
var array = []

func _on_rotate_object(direction: Variant) -> void:

	var tween = create_tween()
		
	# Rotate based on direction
	var rotation_tween: float
	if direction == GlobalVariables.Directions.COUNTERCLOCKWISE and round(rad_to_deg(rotation)) > max_rotation:
		animated_sprite.play("walk")
		# Play footstep sound with normal pitch for hare
		var sound_manager = get_parent().get_node("SoundManager")
		if sound_manager and sound_manager.sfx.has("rabbit_turtle_step"):
			sound_manager.set_sfx_pitch_scale("rabbit_turtle_step", 1.0)
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

func _on_area_entered(area: Area2D) -> void:
	if area is object_class:
		if area.object_type == GlobalVariables.object_types.DECORATIVE:
			return
		if area.object_name == "tree" or area.object_name == "chair" or area.object_name == "small_carrot" or area.object_name == "finish_line":
			print("AREA IS OBJECT CLASS: ",area is object_class)
			print("OBJECT NAME: ", area.object_name)
			array.append(area)
			
func _on_area_exited(area: Area2D) -> void:
	if area is object_class:
		if area.object_type == GlobalVariables.object_types.DECORATIVE:
			return
		if area.object_name == "tree" or area.object_name == "chair" or area.object_name == "small_carrot" or area.object_name == "finish_line":
			array.erase(area)
