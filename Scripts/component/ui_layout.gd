extends Control



@onready var credits_button = $main_menu/credits_button
var animated_icon: AnimatedSprite2D = null

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready() -> void:
	if credits_button and credits_button.has_node("credits_animated_icon"):
		animated_icon = credits_button.get_node("credits_animated_icon")
	if credits_button:
		setup_credits_button()

# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME.
func _process(_delta: float) -> void:
	pass

func setup_credits_button():
	if credits_button:
		# ENSURE MOUSE_FILTER IS CORRECT
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


