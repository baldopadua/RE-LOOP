extends Control

@onready var tutorial_button := $ui_frame/tutorial_button
@onready var tutorial_scene_packed := preload("res://Scenes/ui/tutorial.tscn")
@onready var page_turn_sound := $ui_frame/page_turn_sound
var tutorial_instance: Control = null

func _ready() -> void:
	_setup_tutorial_button()

func _setup_tutorial_button() -> void:
	if tutorial_button:
		tutorial_button.disabled = false
		tutorial_button.mouse_filter = Control.MOUSE_FILTER_STOP
		tutorial_button.pressed.connect(_on_tutorial_button_pressed)

func _on_tutorial_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	if tutorial_instance == null:
		tutorial_instance = tutorial_scene_packed.instantiate()
		add_child(tutorial_instance)
		tutorial_instance.z_index = 100
	else:
		tutorial_instance.visible = true

func _process(_delta: float) -> void:
	pass
