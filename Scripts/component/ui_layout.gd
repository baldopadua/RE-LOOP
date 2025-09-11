extends Control



@onready var credits_button = $main_menu/credits_button
@onready var hint_button = $game_ui_elements/hint_button
@onready var ui_handler = get_parent() # Assumes ui_layout is child of UiHandler
var animated_icon: AnimatedSprite2D = null

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready() -> void:
	if credits_button and credits_button.has_node("credits_animated_icon"):
		animated_icon = credits_button.get_node("credits_animated_icon")
	if credits_button:
		setup_credits_button()
	if hint_button:
		hint_button.connect("pressed", Callable(self, "_on_hint_button_pressed"))

# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME.
func _process(_delta: float) -> void:
	pass

func setup_credits_button():
	if credits_button:
		# ENSURE MOUSE_FILTER IS CORRECT
		credits_button.mouse_filter = Control.MOUSE_FILTER_STOP
		var enter_cb = Callable(self, "_on_credits_button_mouse_entered")
		var exit_cb = Callable(self, "_on_credits_button_mouse_exited")
		if not credits_button.is_connected("mouse_entered", enter_cb):
			credits_button.connect("mouse_entered", enter_cb)
		if not credits_button.is_connected("mouse_exited", exit_cb):
			credits_button.connect("mouse_exited", exit_cb)
		if animated_icon:
			animated_icon.animation = "default"
			animated_icon.play()

func _on_credits_button_mouse_entered():
	if animated_icon:
		var current_frame = animated_icon.frame
		animated_icon.animation = "hover"
		animated_icon.frame = current_frame
		animated_icon.play()

func _on_credits_button_mouse_exited():
	if animated_icon:
		var current_frame = animated_icon.frame
		animated_icon.animation = "default"
		animated_icon.frame = current_frame
		animated_icon.play()

func _on_hint_button_pressed():
	ui_handler.sound_manager.play_ui("page_turn")
	if ui_handler and ui_handler.has_method("show_overlay_hint"):
		ui_handler.show_overlay_hint()

# Animate overlay open: slide in from right to center
func animate_overlay_open_from_right(node: Control) -> void:
	var parent_size = get_viewport_rect().size
	var overlay_size = node.size
	var final_pos = (parent_size / 2) - (overlay_size / 2)
	var start_pos = Vector2(parent_size.x, final_pos.y)
	node.position = start_pos
	node.visible = true
	var tween = create_tween()
	tween.tween_property(node, "position", final_pos, 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Animate overlay open: slide in from left to center
func animate_overlay_open_from_left(node: Control) -> void:
	var parent_size = get_viewport_rect().size
	var overlay_size = node.size
	var final_pos = (parent_size / 2) - (overlay_size / 2)
	var start_pos = Vector2(-overlay_size.x, final_pos.y)
	node.position = start_pos
	node.visible = true
	var tween = create_tween()
	tween.tween_property(node, "position", final_pos, 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Animate overlay close: slide out to left, then call optional callback
func animate_overlay_close_to_left(node: Control, callback: Callable = Callable()) -> void:
	var parent_size = get_viewport_rect().size
	var overlay_size = node.size
	var end_pos = Vector2(-overlay_size.x, (parent_size.y / 2) - (overlay_size.y / 2))
	var tween = create_tween()
	tween.tween_property(node, "position", end_pos, 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if callback:
		tween.tween_callback(callback)

# Animate overlay close: slide out to right, then call optional callback
func animate_overlay_close_to_right(node: Control, callback: Callable = Callable()) -> void:
	var parent_size = get_viewport_rect().size
	var overlay_size = node.size
	var end_pos = Vector2(parent_size.x, (parent_size.y / 2) - (overlay_size.y / 2))
	var tween = create_tween()
	tween.tween_property(node, "position", end_pos, 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if callback:
		tween.tween_callback(callback)


# Animate overlay: pop up from button position and small scale to center and full scale (async, returns tween)
func popup_overlay_from_button(button: Control, overlay: Control, duration: float = 0.18) -> Tween:
	if not button or not overlay:
		return null
	overlay.visible = true
	overlay.scale = Vector2(0.2, 0.2)
	var viewport_size = get_viewport_rect().size
	var overlay_size = overlay.size
	var final_pos = (viewport_size / 2) - (overlay_size / 2)
	var start_pos = button.get_global_position() - overlay.get_parent().get_global_position()
	overlay.position = start_pos
	var tween = create_tween()
	tween.tween_property(overlay, "position", final_pos, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "scale", Vector2(1, 1), duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween
