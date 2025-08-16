extends Control

@onready var tutorial_button := $ui_frame/tutorial_button
@onready var page_turn_sound := $ui_frame/page_turn_sound
@onready var hint_button := $ui_frame/hint_button
@onready var tutorial_node := $ui_frame/tutorial

func _ready() -> void:
	_setup_buttons()

func _setup_buttons() -> void:
	if tutorial_button:
		tutorial_button.disabled = false
		tutorial_button.mouse_filter = Control.MOUSE_FILTER_STOP
		tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	if hint_button:
		hint_button.disabled = false
		hint_button.mouse_filter = Control.MOUSE_FILTER_STOP
		hint_button.pressed.connect(_on_hint_button_pressed)

func _on_tutorial_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	if tutorial_node:
		tutorial_node.visible = true

func _on_hint_button_pressed() -> void:
	var hint_node = $ui_frame.get_node("hint")
	if page_turn_sound:
		page_turn_sound.play()
	if hint_node:
		hint_node.show_hint_overlay()

func _process(_delta: float) -> void:
	pass
