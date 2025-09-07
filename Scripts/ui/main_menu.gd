extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_credits_button()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setup_credits_button():
	if has_node("credits_button"):
		var btn = $credits_button
		var entered = Callable(self, "_on_credits_button_mouse_entered")
		var exited = Callable(self, "_on_credits_button_mouse_exited")
		if not btn.is_connected("mouse_entered", entered):
			btn.connect("mouse_entered", entered)
		if not btn.is_connected("mouse_exited", exited):
			btn.connect("mouse_exited", exited)
		# Set default animation
		if btn.has_node("credits_animated_icon"):
			var icon = btn.get_node("credits_animated_icon")
			icon.animation = "default"

func _on_credits_button_mouse_entered():
	if has_node("credits_button"):
		var btn = $credits_button
		if btn.has_node("credits_animated_icon"):
			var icon = btn.get_node("credits_animated_icon")
			icon.animation = "hover"

func _on_credits_button_mouse_exited():
	if has_node("credits_button"):
		var btn = $credits_button
		if btn.has_node("credits_animated_icon"):
			var icon = btn.get_node("credits_animated_icon")
			icon.animation = "default"