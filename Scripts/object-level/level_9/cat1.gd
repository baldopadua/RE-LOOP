extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var animated_sprite1 = $AnimatedSprite2D
@onready var box = $"../box"
@onready var marker2D = $"../box/Marker2D"
@onready var sound_manager = $"../SoundManager"

var is_loop_shown = false
var cat_tween : Tween

func _on_add_cur_state(direction: Variant) -> void:
	if is_loop_shown:
		return
		
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			animated_sprite1.play("default")
			# Play cat sound
			if sound_manager and sound_manager.sfx.has("cat_sound"):
				sound_manager.play_sfx("cat_sound")
	else:
		if current_state == 1:
			animated_sprite1.play_backwards("default")
			# Play bones collapse when cat becomes bones
			if sound_manager and sound_manager.sfx.has("bones_collapse"):
				sound_manager.play_sfx("bones_collapse")

func _on_area_entered(area: Area2D) -> void:
	if area is object_class:
		if area.object_name == "box" and is_pickupable:
			is_pickupable = false
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_OUT)

			# Run tweens in parallel
			tween.parallel().tween_property(self, "global_position", marker2D.global_position, 0.3)
			tween.parallel().tween_property(self, "rotation", 0.0, 0.3)
			await tween.finished
			box.emit_signal("close_box", self)
			float_cat()

func float_cat() -> void:
	cat_tween = create_tween()
	cat_tween.set_loops()
	
	var float_offset := -5.0
	var duration := 1.0
	
	cat_tween.tween_property(self, "position:y", self.position.y + float_offset, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	cat_tween.tween_property(self, "position:y", self.position.y, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_player_scene_loop_break_shown() -> void:
	is_loop_shown = true
