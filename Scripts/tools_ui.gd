extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$home_button.connect("mouse_entered", Callable(self, "_on_home_button_mouse_entered"))
	$home_button.connect("mouse_exited", Callable(self, "_on_home_button_mouse_exited"))
	$home_button.connect("pressed", Callable(self, "_on_home_button_pressed"))


func _on_home_button_mouse_entered() -> void:
	$hover_sound.play()
	var tween := create_tween()
	tween.tween_property($home_button, "scale", Vector2(1.05, 1.05), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_home_button_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property($home_button, "scale", Vector2(1, 1), 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	GlobalVariables.set_custom_cursor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
