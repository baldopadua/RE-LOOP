extends Control

@onready var tutorial_button := $ui_frame/tutorial_button
@onready var tutorial_scene_packed := preload("res://Scenes/ui/tutorial.tscn")
@onready var page_turn_sound := $ui_frame/page_turn_sound
var tutorial_instance: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ui_frame/time_indicator.play()
	if tutorial_button:
		tutorial_button.disabled = false
		tutorial_button.mouse_filter = Control.MOUSE_FILTER_STOP
		tutorial_button.connect("pressed", Callable(self, "_on_tutorial_button_pressed"))

func _on_tutorial_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	if tutorial_instance == null:
		tutorial_instance = tutorial_scene_packed.instantiate()
		add_child(tutorial_instance)
		tutorial_instance.z_index = 100  # Ensure it's on top
	else:
		tutorial_instance.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
