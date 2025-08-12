extends Control

@onready var credits_button := $credits_button
@onready var credits_overlay := $credits_overlay
@onready var close_button := $credits_overlay/close_button
@onready var credits_animated_icon := $credits_button/credits_animated_icon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$credits_button/credits_animated_icon.play("default")
	credits_button.connect("pressed", Callable(self, "_on_credits_button_pressed"))
	close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))
	credits_button.connect("mouse_entered", Callable(self, "_on_credits_button_hovered"))
	credits_button.connect("mouse_exited", Callable(self, "_on_credits_button_unhovered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_credits_button_pressed() -> void:
	credits_overlay.visible = true
	var main_scene = get_tree().current_scene
	if main_scene:
		if main_scene.has_node("gametitle"):
			main_scene.get_node("gametitle").visible = false
		if main_scene.has_node("start_button"):
			main_scene.get_node("start_button").visible = false
		if main_scene.has_node("tutorial_button"):
			main_scene.get_node("tutorial_button").visible = false
	if credits_animated_icon:
		credits_animated_icon.visible = false


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")

func _on_credits_button_hovered() -> void:
	if credits_animated_icon:
		var current_frame = credits_animated_icon.frame
		credits_animated_icon.play("hover")
		credits_animated_icon.frame = current_frame

func _on_credits_button_unhovered() -> void:
	if credits_animated_icon:
		var current_frame = credits_animated_icon.frame
		credits_animated_icon.play("default")
		credits_animated_icon.frame = current_frame
