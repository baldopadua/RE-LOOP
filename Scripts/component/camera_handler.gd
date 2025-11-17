extends Camera2D

@warning_ignore("unused_signal")
signal cinematic_start(pos_to_focus)
@warning_ignore("unused_signal")
signal cinematic_end()
@warning_ignore("unused_signal")
signal pan_to_pos(pos_to_focus)
@warning_ignore("unused_signal")
signal pan_to_orig_pos()
@warning_ignore("unused_signal")
signal cam_zoom(value)
@warning_ignore("unused_signal")
signal cam_orig_zoom()
@warning_ignore("unused_signal")
signal reveal_bars()
@warning_ignore("unused_signal")
signal hide_bars()

@onready var upper_bar = $"../../CanvasLayer/upper_bar"
@onready var lower_bar = $"../../CanvasLayer/lower_bar"
@onready var orig_parent = get_parent()
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

# HIDING POSITIONS
# -50
# 676

# REVEALED POSITIONS
# 50
# 771

# TODO: CAM SIGNALS - pan_to_pos(pos), pan_to_orig_pos(), hide_bars(), reveal_bars(), cam_zoom(value), cam_orig_zoom()

func _on_pan_to_pos(pos_to_focus: Variant) -> void:
	var cam_move_tween = create_tween()
	cam_move_tween.set_trans(Tween.TRANS_SINE)
	cam_move_tween.set_ease(Tween.EASE_IN_OUT)
	cam_move_tween.tween_property(self, "global_position", pos_to_focus, 1.0)
	cam_move_tween.finished.connect(func():
		cam_move_tween.kill()
	)


func _on_pan_to_orig_pos() -> void:
	var cam_move_tween = create_tween()
	cam_move_tween.set_trans(Tween.TRANS_SINE)
	cam_move_tween.set_ease(Tween.EASE_IN_OUT)
	cam_move_tween.tween_property(self, "position", Vector2(0,-8.41), 1.0)
	cam_move_tween.finished.connect(func():
		cam_move_tween.kill()
	)


func _on_hide_bars() -> void:
	# UPPER BAR
	if is_instance_valid(upper_bar):
		var upper_tween = create_tween()
		upper_tween.set_trans(Tween.TRANS_SINE)
		upper_tween.set_ease(Tween.EASE_IN_OUT)
		upper_tween.tween_property(upper_bar, "position:y", -50, 1.0)
		upper_tween.finished.connect(func():
			upper_tween.kill()
		)
	# LOWER BAR
	if is_instance_valid(lower_bar):
		var lower_tween = create_tween()
		lower_tween.set_trans(Tween.TRANS_SINE)
		lower_tween.set_ease(Tween.EASE_IN_OUT)
		lower_tween.tween_property(lower_bar, "position:y", 771, 1.0)
		lower_tween.finished.connect(func():
			lower_tween.kill()	
			# HIDES BAR
			if is_instance_valid(upper_bar):
				upper_bar.visible = false
			if is_instance_valid(lower_bar):
				lower_bar.visible = false
		)

func _on_reveal_bars() -> void:
	# REVEAL BARS
	if is_instance_valid(upper_bar):
		upper_bar.visible = true
		var upper_tween = create_tween()
		upper_tween.set_trans(Tween.TRANS_SINE)
		upper_tween.set_ease(Tween.EASE_IN_OUT)
		upper_tween.tween_property(upper_bar, "position:y", 50, 1.0)
		upper_tween.finished.connect(func():
			upper_tween.kill()
		)
	if is_instance_valid(lower_bar):
		lower_bar.visible = true
		var lower_tween = create_tween()
		lower_tween.set_trans(Tween.TRANS_SINE)
		lower_tween.set_ease(Tween.EASE_IN_OUT)
		lower_tween.tween_property(lower_bar, "position:y", 676, 1.0)
		lower_tween.finished.connect(func():
			lower_tween.kill()	
		)


func _on_cam_zoom(value: Variant) -> void:
	var cam_zoom_tween = create_tween()
	cam_zoom_tween.set_trans(Tween.TRANS_SINE)
	cam_zoom_tween.set_ease(Tween.EASE_IN_OUT)
	cam_zoom_tween.tween_property(self, "zoom", Vector2(value, value), 1.0)
	cam_zoom_tween.finished.connect(func():
		cam_zoom_tween.kill()
	)

func _on_cam_orig_zoom() -> void:
	var cam_tween = create_tween()
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 1.0)
	cam_tween.finished.connect(func():
		cam_tween.kill()
	)
