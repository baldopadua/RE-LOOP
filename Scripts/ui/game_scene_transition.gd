extends Control

var _callback: Callable = Callable()

func play_and_continue(callback: Callable) -> void:
	GlobalVariables.remove_custom_cursor()
	_callback = callback
	self.modulate.a = 0.0
	visible = true
	var ploy = $ploy
	ploy.rotation = 0.0
	ploy.scale = Vector2(2, 2)
	var parent_size = get_rect().size
	var ploy_size = ploy.size * ploy.scale
	ploy.position = (parent_size - ploy_size) / 2
	var start_y = -ploy_size.y
	var end_y = ploy.position.y
	ploy.position.y = start_y
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(
		ploy, "position:y", end_y, 0.8
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	# After falling, rotate and shrink ploy, then callback and fade out
	tween.tween_callback(Callable(self, "_ploy_spin_and_shrink").bind(ploy))

func _ploy_spin_and_shrink(ploy):
	var tween = create_tween()
	# Rotate to the left (counter-clockwise, negative angle)
	tween.tween_property(ploy, "rotation", -2 * PI, 0.5)
	tween.parallel().tween_property(ploy, "scale", Vector2(0, 0), 0.5)
	tween.tween_callback(_on_transition_finished)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func _on_transition_finished():
	if _callback and _callback.is_valid():
		_callback.call()
	# queue_free() is now called after fade out


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.s


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
