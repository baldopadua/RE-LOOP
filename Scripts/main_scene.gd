extends Control

var new_cursor = preload("res://Assets/Loopling.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the mouse cursor to the custom image
	Input.set_custom_mouse_cursor(new_cursor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
