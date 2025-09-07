extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# Recursively get all nodes under this node (including nested)
func _get_all_nodes(parent: Node) -> Array:
	var nodes = []
	for child in parent.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	return nodes

# Show only the nodes with names in node_names, hide others
func show_nodes(node_names: Array) -> void:
	var all_nodes = _get_all_nodes(self)
	for node in all_nodes:
		if node.has_method("set_visible"):
			node.visible = node.name in node_names

# Show only one node by name, hide others
func show_node(node_name: String) -> void:
	show_nodes([node_name])

# Hide all children of a given parent node
func hide_all_children(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("set_visible"):
			child.visible = false

func show_cursor():
	if has_node("custom_cursor"):
		$custom_cursor.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func show_main_menu():
	# Hide all children of background and main_menu first
	if $background:
		hide_all_children($background)
		$background.visible = true
		# Show only game_animated_bg inside background
		if $background.has_node("game_animated_bg"):
			var bg_anim = $background.get_node("game_animated_bg")
			bg_anim.visible = true
			if bg_anim.has_method("play"):
				bg_anim.play("default")
	if $main_menu:
		hide_all_children($main_menu)
		$main_menu.visible = true
		# Show all children of main_menu
		for child in $main_menu.get_children():
			if child.has_method("set_visible"):
				child.visible = true
		# Setup credits button animation
		setup_credits_button()
		# Play credits_animated_icon animation
		if $main_menu.has_node("credits_button"):
			var btn = $main_menu.get_node("credits_button")
			if btn.has_node("credits_animated_icon"):
				var icon = btn.get_node("credits_animated_icon")
				icon.visible = true
				if icon.has_method("play"):
					icon.play("default")
	# Hide other direct children (custom_cursor no longer handled here)
	for child in get_children():
		if child.name not in ["background", "main_menu"]:
			if child.has_method("set_visible"):
				child.visible = false

func setup_credits_button():
	if $main_menu.has_node("credits_button"):
		var btn = $main_menu.get_node("credits_button")
		var entered_callable = Callable(self, "_on_credits_button_mouse_entered")
		var exited_callable = Callable(self, "_on_credits_button_mouse_exited")
		if not btn.is_connected("mouse_entered", entered_callable):
			btn.connect("mouse_entered", entered_callable)
		if not btn.is_connected("mouse_exited", exited_callable):
			btn.connect("mouse_exited", exited_callable)
		# Set default animation
		if btn.has_node("credits_animated_icon"):
			btn.get_node("credits_animated_icon").animation = "default"

func _on_credits_button_mouse_entered():
	var btn = $main_menu.get_node("credits_button")
	if btn.has_node("credits_animated_icon"):
		btn.get_node("credits_animated_icon").animation = "hover"

func _on_credits_button_mouse_exited():
	var btn = $main_menu.get_node("credits_button")
	if btn.has_node("credits_animated_icon"):
		btn.get_node("credits_animated_icon").animation = "default"
