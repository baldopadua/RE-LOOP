extends Control

@onready var tutorial_button := $ui_frame/tutorial_button
@onready var tutorial_scene_packed := preload("res://Scenes/ui/tutorial.tscn")
@onready var page_turn_sound := $ui_frame/page_turn_sound
@onready var hint_button := $ui_frame/hint_button
var tutorial_instance: Control = null

func _ready() -> void:
	_setup_tutorial_button()
	_setup_hint_button()

func _setup_tutorial_button() -> void:
	if tutorial_button:
		tutorial_button.disabled = false
		tutorial_button.mouse_filter = Control.MOUSE_FILTER_STOP
		tutorial_button.pressed.connect(_on_tutorial_button_pressed)

func _setup_hint_button() -> void:
	if hint_button:
		hint_button.disabled = false
		hint_button.mouse_filter = Control.MOUSE_FILTER_STOP
		hint_button.pressed.connect(_on_hint_button_pressed)

func _on_tutorial_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	if tutorial_instance == null:
		tutorial_instance = tutorial_scene_packed.instantiate()
		add_child(tutorial_instance)
		tutorial_instance.z_index = 100
	else:
		tutorial_instance.visible = true

func _on_hint_button_pressed() -> void:
	var hint_node = $ui_frame.get_node("hint")
	if page_turn_sound:
		page_turn_sound.play()
	if hint_node:
		hint_node.show_hint_overlay()

func _process(_delta: float) -> void:
	pass
