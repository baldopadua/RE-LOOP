extends Control

@onready var tutorial_overlay := $tutorial_overlay
@onready var close_button := $close_button
@onready var page_turn_sound := $tutorial_overlay/page_turn_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_overlay.visible = true
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_close_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out_and_close()

func _fade_out_and_close():
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.z_index = 999
	add_child(fade_rect)
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_after_fade_out"))

func _after_fade_out():
	_restore_main_menu()
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("restore_default_bg_animation"):
		main_scene.restore_default_bg_animation()
	queue_free()

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

# No changes needed unless you want to control tutorial_bg visibility here.