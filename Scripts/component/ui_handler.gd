extends Control

@onready var sound_manager = get_node("SoundManager")
@onready var ui_layout = $ui_layout

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready() -> void:
	_connect_hover_sound(self)


# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME.
func _process(_delta: float) -> void:
	pass
	
# RECURSIVELY GET ALL NODES UNDER THIS NODE (INCLUDING NESTED)
func _get_all_nodes(parent: Node) -> Array:
	var nodes = []
	for child in parent.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	return nodes

# SHOW ONLY THE NODES WITH NAMES IN NODE_NAMES, HIDE OTHERS
func show_nodes(node_names: Array) -> void:
	var all_nodes = _get_all_nodes(self)
	for node in all_nodes:
		if node.has_method("set_visible"):
			node.visible = node.name in node_names

# SHOW ONLY ONE NODE BY NAME, HIDE OTHERS
func show_node(node_name: String) -> void:
	show_nodes([node_name])

# SHOW CURSOR
func show_cursor():
	if has_node("custom_cursor"):
		$custom_cursor.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# AUTO-PLAY ALL ANIMATEDSPRITE2D NODES THAT ARE VISIBLE UNDER PARENT
func auto_play_visible_sprites(parent: Node) -> void:
	for node in _get_all_nodes(parent):
		if node is AnimatedSprite2D and node.visible:
			if node.has_method("play"):
				node.play()

# SHOW ONLY THE DIRECT CHILDREN WHOSE NAMES ARE IN NODE_NAMES, HIDE OTHERS
func show_only_nodes(node_names: Array) -> void:
	for child in get_children():
		if child.name in node_names:
			if child.has_method("set_visible"):
				child.visible = true
		else:
			if child.has_method("set_visible"):
				child.visible = false

# SHOW ONLY THE DIRECT CHILDREN OF A GIVEN PARENT WHOSE NAMES ARE IN NODE_NAMES, HIDE OTHERS
func show_only_children(parent: Node, node_names: Array) -> void:
	for child in parent.get_children():
		if child.name in node_names:
			if child.has_method("set_visible"):
				child.visible = true
		else:
			if child.has_method("set_visible"):
				child.visible = false

# HIDE ALL CHILDREN OF A GIVEN PARENT NODE
func hide_all_children(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("set_visible"):
			child.visible = false
			
# RECURSIVELY CONNECT HOVER SOUND TO ALL TEXTUREBUTTON NODES UNDER PARENT
func _connect_hover_sound(parent: Node) -> void:
	for child in parent.get_children():
		if child is TextureButton:
			child.connect("mouse_entered", Callable(self, "_on_button_hovered").bind(child))
		_connect_hover_sound(child)

# ON BUTTON HOVERED
func _on_button_hovered(_button):
	if sound_manager:
		sound_manager.play_ui("hover")

# SHOW MAIN MENU
func show_main_menu():
	if sound_manager:
		sound_manager.play_music("main_bgm")
	# HIDE ALL CHILDREN OF BACKGROUND AND MAIN_MENU FIRST
	if $background:
		hide_all_children($background)
		$background.visible = true
		# SHOW ONLY GAME_ANIMATED_BG INSIDE BACKGROUND
		if $background.has_node("game_animated_bg"):
			var bg_anim = $background.get_node("game_animated_bg")
			bg_anim.visible = true
			if bg_anim.has_method("play"):
				bg_anim.play("default")
	# USE NEW HIERARCHY FOR MAIN_MENU
	if ui_layout.has_node("main_menu"):
		var main_menu = ui_layout.get_node("main_menu")
		hide_all_children(main_menu)
		main_menu.visible = true
		for child in main_menu.get_children():
			if child.has_method("set_visible"):
				child.visible = true
		auto_play_visible_sprites(main_menu)
	# ONLY SHOW BACKGROUND AND UI_LAYOUT, HIDE OTHER DIRECT CHILDREN
	show_only_nodes(["background", "ui_layout"])
	# ONLY SHOW MAIN_MENU INSIDE UI_LAYOUT, HIDE OTHERS
	for child in ui_layout.get_children():
		if child.name == "main_menu":
			if child.has_method("set_visible"):
				child.visible = true
		else:
			if child.has_method("set_visible"):
				child.visible = false

