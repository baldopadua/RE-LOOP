extends Control

const OVERLAY_FINAL_SCALE = Vector2(1, 1)
const OVERLAY_START_SCALE = Vector2(0.2, 0.2)
const OVERLAY_FINAL_POSITION = Vector2(-425, -425) # from tutorial_overlay node offsets
const OVERLAY_START_POSITION = Vector2(1920, -425) # right edge, same Y

@onready var tutorial_overlay := $tutorial_overlay
@onready var close_button := $close_button
@onready var page_turn_sound := $tutorial_overlay/page_turn_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset_overlay()
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))
	close_button.z_index = 100
	tutorial_overlay.z_index = 99
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))

func _on_visibility_changed():
	if visible:
		_reset_overlay()

func _reset_overlay():
	tutorial_overlay.visible = true
	tutorial_overlay.scale = OVERLAY_FINAL_SCALE
	var parent_size = get_viewport_rect().size
	var overlay_size = tutorial_overlay.size
	var final_pos = (parent_size / 2) - (overlay_size / 2)
	var start_pos = Vector2(parent_size.x, final_pos.y)
	tutorial_overlay.position = start_pos
	var tween := create_tween()
	tween.tween_property(tutorial_overlay, "position", final_pos, 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_close_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out_and_close()

func _fade_out_and_close():
	var parent_size = get_viewport_rect().size
	var overlay_size = tutorial_overlay.size
	var start_pos = Vector2(parent_size.x, (parent_size.y / 2) - (overlay_size.y / 2))
	var tween := create_tween()
	tween.tween_property(tutorial_overlay, "position", start_pos, 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_fade_out_overlay"))

func _fade_out_overlay():
	tutorial_overlay.visible = false
	tutorial_overlay.position = OVERLAY_FINAL_POSITION
	await get_tree().create_timer(0.18).timeout
	_after_fade_out()

func _after_fade_out():
	_restore_main_menu()
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("restore_default_bg_animation"):
		main_scene.restore_default_bg_animation()
	visible = false # Hide the node instead of freeing

func _restore_main_menu():
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = true
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = true
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = true
		if main_scene.has_node("credits"):
			main_scene.get_node("credits").visible = true
