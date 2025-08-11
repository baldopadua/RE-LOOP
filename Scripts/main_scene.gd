extends Control

@onready var hover_sound := $hover_sound
@onready var main_bgm := $main_bgm
@onready var main_bg := $main_bg
@onready var tutorial_overlay := $tutorial_overlay
@onready var close_button := $tutorial_overlay/close_button
@onready var start_button := $start_button
@onready var tutorial_button := $tutorial_button
@onready var page_turn_sound := $tutorial_overlay/page_turn_sound
@onready var click_sound := $click_sound
@onready var game_animated_bg := $game_animated_bg
var tutorial_bg_texture := preload("res://Assets/ui/tutorial_bg.png")
var original_bg_texture := preload("res://Assets/ui/game_mainscene.png")

# --- Initialization & Connections ---
func _ready() -> void:
	_play_bgm()
	_connect_buttons()
	_hide_tutorial_overlay_initial()
	if game_animated_bg:
		game_animated_bg.play()

func _input(event):
	if event is InputEventMouseMotion:
		GlobalVariables.update_cursor_by_mouse_motion(event)

func _play_bgm() -> void:
	if main_bgm and main_bgm.stream:
		if main_bgm.stream.has_method("set_loop"):
			main_bgm.stream.set_loop(true)
		elif main_bgm.stream.has_property("loop"):
			main_bgm.stream.loop = true
		main_bgm.play()

func _connect_buttons() -> void:
	_connect_button(start_button, "_on_start_button_pressed")
	_connect_button(tutorial_button, "_on_tutorial_button_pressed")
	_connect_button(close_button, "_on_close_button_pressed")
	_connect_hover_signals()

func _connect_button(btn: Object, method: String) -> void:
	if btn and (btn is Button or btn is TextureButton):
		btn.connect("pressed", Callable(self, method))

func _hide_tutorial_overlay_initial() -> void:
	if tutorial_overlay:
		tutorial_overlay.visible = false
		tutorial_overlay.modulate.a = 0.0

# --- Button Event Handlers ---
func _on_start_button_pressed() -> void:
	start_button.disabled = true
	if click_sound:
		click_sound.play()
	_fade_out(main_bg, 0.25, Callable(self, "_go_to_level_scene"))

func _go_to_level_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/levels/level_1_scene.tscn")

func _on_tutorial_button_pressed() -> void:
	_set_buttons_disabled(true)
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out(main_bg, 0.3, Callable(self, "_show_tutorial_and_change_bg"))

func _show_tutorial_and_change_bg() -> void:
	_show_tutorial_overlay()
	_change_bg_to_tutorial()
	_fade_in(main_bg, 0.3)

func _on_close_button_pressed() -> void:
	_set_buttons_disabled(false)
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out(
		tutorial_overlay, 0.3,
		Callable(self, "_hide_tutorial_and_restore_bg")
	)

func _hide_tutorial_and_restore_bg() -> void:
	_hide_tutorial_overlay()
	_fade_out(
		main_bg, 0.3,
		Callable(self, "_restore_bg_to_original_and_fade_in")
	)

func _restore_bg_to_original_and_fade_in() -> void:
	_restore_bg_to_original()
	_fade_in(main_bg, 0.3)

func _set_buttons_disabled(disabled: bool) -> void:
	start_button.disabled = disabled
	tutorial_button.disabled = disabled

# --- Transition Helpers ---
func _fade_out(node: CanvasItem, duration: float, callback: Callable) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(callback)

func _fade_in(node: CanvasItem, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

# --- Overlay & Background Helpers ---
func _show_tutorial_overlay() -> void:
	if tutorial_overlay:
		tutorial_overlay.visible = true
		_fade_in(tutorial_overlay, 0.4)

func _hide_tutorial_overlay() -> void:
	if tutorial_overlay:
		tutorial_overlay.visible = false

func _change_bg_to_tutorial() -> void:
	main_bg.texture = tutorial_bg_texture

func _restore_bg_to_original() -> void:
	main_bg.texture = original_bg_texture

# --- Hover Logic ---
func _connect_hover_signals() -> void:
	var btns = [start_button, tutorial_button]
	for btn in btns:
		if btn:
			btn.connect("mouse_entered",
				Callable(self, "_on_button_hovered").bind(btn))
			btn.connect("mouse_exited",
				Callable(self, "_on_button_unhovered").bind(btn))

func _on_button_hovered(btn: TextureButton) -> void:
	if hover_sound:
		hover_sound.play()
	btn.disabled = true
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_enable_button").bind(btn))

func _enable_button(btn: TextureButton) -> void:
	btn.disabled = false

func _on_button_unhovered(btn: TextureButton) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_property(btn, "scale", Vector2(1, 1), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	pass
