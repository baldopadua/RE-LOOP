extends Control

@onready var hover_sound := $hover_sound
@onready var click_sound := $click_sound
@onready var main_bgm := $main_bgm

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
    

func _connect_start_button() -> void:
    var start_button := get_node("start_button")
    if not start_button:
        return
    start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_file("res://Scenes/levels/level_1_scene.tscn")

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