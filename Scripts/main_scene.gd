extends Control

@onready var hover_sound := $hover_sound
@onready var main_bgm := $main_bgm
@onready var main_bg := $main_bg
@onready var start_button := $start_button
@onready var tutorial_button := $tutorial_button
@onready var click_sound := $click_sound
@onready var game_animated_bg := $game_animated_bg
@onready var gametitle := $gametitle
@onready var page_turn_sound := $page_turn_sound
@onready var tutorial_scene_packed := preload("res://Scenes/ui/tutorial.tscn")
var tutorial_instance: Control = null

# --- Initialization & Connections ---
func _ready() -> void:
	_play_bgm()
	_connect_buttons()
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
	_connect_hover_signals()

func _connect_button(btn: Object, method: String) -> void:
	if btn and (btn is Button or btn is TextureButton):
		btn.connect("pressed", Callable(self, method))

# --- Button Event Handlers ---
func _on_start_button_pressed() -> void:
	start_button.disabled = true
	if click_sound:
		click_sound.play()
	_fade_out(main_bg, 0.25, Callable(self, "_go_to_next_scene"))

func _go_to_next_scene() -> void:
	get_tree().change_scene_to_file('res://Scenes/game_scene.tscn')

func _on_tutorial_button_pressed() -> void:
	_set_buttons_disabled(true)
	if page_turn_sound:
		page_turn_sound.play()
	# Hide main menu elements
	if gametitle:
		gametitle.visible = false
	if start_button:
		start_button.visible = false
	if tutorial_button:
		tutorial_button.visible = false
	if has_node("credits"):
		get_node("credits").visible = false
	_fade_in_tutorial_overlay()

func _fade_in_tutorial_overlay():
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.z_index = 999
	add_child(fade_rect)
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.2)
	tween.tween_callback(Callable(self, "_show_tutorial_overlay"))
	tween.tween_callback(Callable(fade_rect, "queue_free"))

func _show_tutorial_overlay():
	if tutorial_instance == null or not is_instance_valid(tutorial_instance):
		tutorial_instance = tutorial_scene_packed.instantiate()
		add_child(tutorial_instance)
		tutorial_instance.z_index = 100
		# Hide tutorial_bg when shown from main scene
		if tutorial_instance.has_node("tutorial_bg"):
			tutorial_instance.get_node("tutorial_bg").visible = false
	else:
		tutorial_instance.visible = true
		# Hide tutorial_bg when shown from main scene
		if tutorial_instance.has_node("tutorial_bg"):
			tutorial_instance.get_node("tutorial_bg").visible = false

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

func _process(_delta: float) -> void:
	pass
