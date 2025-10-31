extends Camera2D

signal cinematic_start(obj_to_reparent_to)
signal cinematic_end()

@onready var upper_bar = $"../CanvasLayer/upper_bar"
@onready var lower_bar = $"../CanvasLayer/lower_bar"
@onready var orig_parent = get_parent()

# HIDING POSITIONS
# -48
# 676

# REVEALED POSITIONS
# 46
# 771

func _on_cinematic_start(obj_to_reparent_to) -> void:
	
	var cam_move_tween = create_tween()
	cam_move_tween.set_trans(Tween.TRANS_SINE)
	cam_move_tween.set_ease(Tween.EASE_IN_OUT)
	cam_move_tween.tween_property(self, "position", obj_to_reparent_to.position, 1.0)
	cam_move_tween.finished.connect(func():
		cam_move_tween.kill()
	)
	
	var cam_zoom_tween = create_tween()
	cam_zoom_tween.set_trans(Tween.TRANS_SINE)
	cam_zoom_tween.set_ease(Tween.EASE_IN_OUT)
	cam_zoom_tween.tween_property(self, "zoom", Vector2(1.5, 1.5), 1.0)
	cam_zoom_tween.finished.connect(func():
		cam_zoom_tween.kill()
	)
	
	# REVEAL BARS
	upper_bar.visible = true
	lower_bar.visible = true
	
	# UPPER BAR
	var upper_tween = create_tween()
	upper_tween.set_trans(Tween.TRANS_SINE)
	upper_tween.set_ease(Tween.EASE_IN_OUT)
	upper_tween.tween_property(upper_bar, "position:y", 46, 1.0)
	upper_tween.finished.connect(func():
		upper_tween.kill()
	)

	# LOWER BAR
	var lower_tween = create_tween()
	lower_tween.set_trans(Tween.TRANS_SINE)
	lower_tween.set_ease(Tween.EASE_IN_OUT)
	lower_tween.tween_property(lower_bar, "position:y", 771, 1.0)
	lower_tween.finished.connect(func():
		lower_tween.kill()	
	)

func _on_cinematic_end() -> void:

	var cam_move_tween = create_tween()
	cam_move_tween.set_trans(Tween.TRANS_SINE)
	cam_move_tween.set_ease(Tween.EASE_IN_OUT)
	cam_move_tween.tween_property(self, "position", Vector2(0,0), 1.0)
	cam_move_tween.finished.connect(func():
		cam_move_tween.kill()
	)

	var cam_tween = create_tween()
	cam_tween.set_trans(Tween.TRANS_SINE)
	cam_tween.set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 1.0)
	cam_tween.finished.connect(func():
		cam_tween.kill()
	)

	# UPPER BAR
	var upper_tween = create_tween()
	upper_tween.set_trans(Tween.TRANS_SINE)
	upper_tween.set_ease(Tween.EASE_IN_OUT)
	upper_tween.tween_property(upper_bar, "position:y", -48, 1.0)
	upper_tween.finished.connect(func():
		upper_tween.kill()
	)

	# LOWER BAR
	var lower_tween = create_tween()
	lower_tween.set_trans(Tween.TRANS_SINE)
	lower_tween.set_ease(Tween.EASE_IN_OUT)
	lower_tween.tween_property(lower_bar, "position:y", 676, 1.0)
	lower_tween.finished.connect(func():
		lower_tween.kill()	
		# HIDES BAR
		upper_bar.visible = false
		lower_bar.visible = false
	)
