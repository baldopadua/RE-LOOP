extends Control

@onready var credits_overlay := $credits_frame/credits_overlay
@onready var close_button := $credits_frame/credits_overlay/close_button
@onready var hover_sound := $"../hover_sound"
@onready var page_turn_sound := $"../page_turn_sound"
@onready var credits_animated_icon := $credits_button/credits_animated_icon
@onready var credits_button := $credits_button
@onready var click_sound := $"../click_sound"

const CREDITS_ICON_BASE_SCALE = Vector2(6.28704, 6.95834)
const CREDITS_ICON_HOVER_SCALE = CREDITS_ICON_BASE_SCALE * 1.2
const OVERLAY_FINAL_POSITION = Vector2(52, 11) 
const ICON_POSITION = Vector2(88, 65.2501)

var last_frame_index := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))
	credits_button.connect("mouse_entered", Callable(self, "_on_credits_button_hovered"))
	credits_button.connect("mouse_exited", Callable(self, "_on_credits_button_unhovered"))
	credits_button.connect("pressed", Callable(self, "_on_credits_button_pressed"))

func _on_credits_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	# Fade in overlay with animation
	_fade_in_overlay()
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_method("play_dim_bg_animation"):
			main_scene.play_dim_bg_animation()
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = false
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = false
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = false
		if main_scene.has_node("credits/credits_button"):
			main_scene.get_node("credits/credits_button").visible = false

func _on_credits_icon_pressed() -> void:
	_fade_in_overlay()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _fade_in_overlay():
	credits_overlay.visible = true
	credits_overlay.scale = Vector2(0.2, 0.2)
	credits_overlay.position = ICON_POSITION
	var tween := create_tween()
	tween.tween_property(credits_overlay, "scale", Vector2(1, 1), 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(credits_overlay, "position", OVERLAY_FINAL_POSITION, 0.18)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Removed fade-in transition, just show overlay instantly.
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = false
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = false
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = false

func _on_close_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	_fade_out_overlay()

func _fade_out_overlay():
	# Animate overlay scale down and move back to icon position before hiding
	var tween := create_tween()
	tween.tween_property(credits_overlay, "scale", Vector2(0.2, 0.2), 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(credits_overlay, "position", ICON_POSITION, 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_hide_overlay_and_fade"))

func _hide_overlay_and_fade():
	credits_overlay.visible = false
	credits_overlay.scale = Vector2(1, 1)
	credits_overlay.position = OVERLAY_FINAL_POSITION
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.z_index = 999
	$credits_frame.add_child(fade_rect)
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.2)
	tween.tween_callback(Callable(self, "_restore_main_menu_and_close"))
	tween.tween_callback(Callable(fade_rect, "queue_free"))

func _restore_main_menu_and_close():
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = true
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = true
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = true
		if main_scene.has_node("credits/credits_button"):
			main_scene.get_node("credits/credits_button").visible = true
		if main_scene.has_method("restore_default_bg_animation"):
			main_scene.restore_default_bg_animation()
	credits_overlay.visible = false

func _restore_main_menu():
	credits_overlay.visible = false
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = true
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = true
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = true
		if main_scene.has_method("restore_default_bg_animation"):
			main_scene.restore_default_bg_animation()

func _on_credits_button_hovered() -> void:
	if hover_sound:
		hover_sound.play()
	if credits_animated_icon:
		var last_frame = credits_animated_icon.frame
		credits_animated_icon.play("credits_icon_hover")
		credits_animated_icon.frame = last_frame
		credits_animated_icon.scale = CREDITS_ICON_HOVER_SCALE # scale up from base

func _on_credits_button_unhovered() -> void:
	if credits_animated_icon:
		var last_frame = credits_animated_icon.frame
		credits_animated_icon.play("default")
		credits_animated_icon.frame = last_frame
		credits_animated_icon.scale = CREDITS_ICON_BASE_SCALE # restore to base
		credits_animated_icon.play("default")
		credits_animated_icon.frame = last_frame
