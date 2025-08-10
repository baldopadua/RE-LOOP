extends Control

@onready var hover_sound := $hover_sound
@onready var click_sound := $click_sound
@onready var main_bgm := $main_bgm
@onready var main_bg := $main_bg
@onready var tutorial_overlay := $tutorial_overlay
@onready var close_button := $tutorial_overlay/close_button
@onready var start_button := $start_button
@onready var tutorial_button := $tutorial_button
@onready var page_turn_sound := $tutorial_overlay/page_turn_sound

var tutorial_bg_texture := preload("res://Assets/ui/tutorial_bg.png")
var original_bg_texture := preload("res://Assets/ui/game_mainscene.png")

func _ready() -> void:
    # Play and loop the background music
    if main_bgm and main_bgm.stream:
        if main_bgm.stream.has_method("set_loop"):
            main_bgm.stream.set_loop(true)
        elif main_bgm.stream.has_property("loop"):
            main_bgm.stream.loop = true
        main_bgm.play()
        
    _connect_start_button()
    _connect_hover_signals()
    _connect_tutorial_button()
    _connect_close_button()
    # Ensure overlay is hidden and transparent at start
    if tutorial_overlay:
        tutorial_overlay.visible = false
        tutorial_overlay.modulate.a = 0.0

func _connect_start_button() -> void:
    var btn := get_node("start_button")
    if not btn:
        return
    btn.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_file("res://Scenes/levels/level_1_scene.tscn")

func _connect_tutorial_button() -> void:
    var tut_btn := get_node("tutorial_button")
    if tut_btn:
        tut_btn.connect("pressed", Callable(self, "_on_tutorial_button_pressed"))

func _connect_close_button() -> void:
    if close_button:
        close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))

func _on_tutorial_button_pressed() -> void:
    # Disable buttons
    start_button.disabled = true
    tutorial_button.disabled = true
    # Play page turn sound
    if page_turn_sound:
        page_turn_sound.play()
    # Fade out current bg
    var tween := create_tween()
    tween.tween_property(main_bg, "modulate:a", 0.0, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_callback(Callable(self, "_show_tutorial_overlay"))
    tween.tween_callback(Callable(self, "_change_bg_to_tutorial"))
    tween.tween_property(main_bg, "modulate:a", 1.0, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _on_close_button_pressed() -> void:
    # Enable buttons
    start_button.disabled = false
    tutorial_button.disabled = false
    # Play page turn sound when closing
    if page_turn_sound:
        page_turn_sound.play()
    # Fade out overlay and background, then restore
    var tween := create_tween()
    tween.tween_property(tutorial_overlay, "modulate:a", 0.0, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_callback(Callable(self, "_hide_tutorial_overlay"))
    tween.tween_property(main_bg, "modulate:a", 0.0, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_callback(Callable(self, "_restore_bg_to_original"))
    tween.tween_property(main_bg, "modulate:a", 1.0, 0.3)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _show_tutorial_overlay():
    if tutorial_overlay:
        tutorial_overlay.visible = true
        var tween := create_tween()
        tween.tween_property(
            tutorial_overlay, "modulate:a", 1.0, 0.4
        ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _hide_tutorial_overlay():
    if tutorial_overlay:
        tutorial_overlay.visible = false

func _change_bg_to_tutorial():
    main_bg.texture = tutorial_bg_texture

func _restore_bg_to_original():
    main_bg.texture = original_bg_texture

func _connect_hover_signals() -> void:
    for button_name in ["start_button", "tutorial_button"]:
        var btn = get_node(button_name)
        if btn:
            btn.connect("mouse_entered", Callable(self, "_on_button_hovered"))

func _on_button_hovered() -> void:
    if hover_sound:
        hover_sound.play()

func _process(_delta: float) -> void:
    pass