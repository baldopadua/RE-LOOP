extends Control

@onready var tutorial_overlay := $tutorial_overlay
@onready var close_button := $tutorial_overlay/close_button
@onready var page_turn_sound := $tutorial_overlay/page_turn_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_overlay.visible = true
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_close_button_pressed() -> void:
	if page_turn_sound:
		page_turn_sound.play()
	await get_tree().create_timer(0.5).timeout
	var parent = get_parent()
	if parent and parent.name == "MainScene":
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	else:
		queue_free()


