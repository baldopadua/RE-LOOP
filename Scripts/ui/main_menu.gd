extends Control

@onready var credits_button = $credits_button
@onready var animated_icon = credits_button.get_node("credits_animated_icon") if credits_button.has_node("credits_animated_icon") else null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_credits_button()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setup_credits_button():
	if credits_button:
		# Ensure mouse_filter is correct
		credits_button.mouse_filter = Control.MOUSE_FILTER_STOP
		var enter_cb = Callable(self, "_on_credits_button_mouse_entered")
		var exit_cb = Callable(self, "_on_credits_button_mouse_exited")
		if not credits_button.is_connected("mouse_entered", enter_cb):
			credits_button.connect("mouse_entered", enter_cb)
		if not credits_button.is_connected("mouse_exited", exit_cb):
			credits_button.connect("mouse_exited", exit_cb)
		if animated_icon:
			animated_icon.animation = "default"
			animated_icon.play()

func _on_credits_button_mouse_entered():
	if animated_icon:
		var current_frame = animated_icon.frame
		animated_icon.animation = "hover"
		animated_icon.frame = current_frame
		animated_icon.play()

func _on_credits_button_mouse_exited():
	if animated_icon:
		var current_frame = animated_icon.frame
		animated_icon.animation = "default"
		animated_icon.frame = current_frame
		animated_icon.play()