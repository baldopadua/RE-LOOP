extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_start_button()

# Connects the start button's pressed signal to the _on_start_button_pressed function.
func _connect_start_button() -> void:
	var start_button := get_node("start_button")
	if not start_button:
		return
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/levels/level_1_scene.tscn")

# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
