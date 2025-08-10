extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$home_button.connect("mouse_entered", Callable(self, "_on_home_button_mouse_entered"))
	$home_button.connect("pressed", Callable(self, "_on_home_button_pressed"))


func _on_home_button_mouse_entered() -> void:
	$hover_sound.play()


func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
