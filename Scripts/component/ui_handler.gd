extends Control

@onready var sound_manager = get_node("SoundManager")
@onready var ui_layout = $ui_layout
@onready var background = $background
@onready var time_indicator = $ui_layout/game_ui_elements/time_indicator

var bg_node: Node = null
var main_menu: Node = null
var player = null
var last_anim_type: String = ""

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready() -> void:
	_connect_hover_sound(self)
	# Find player node if exists
	if get_tree().get_root().has_node("PlayerScene"):
		player = get_tree().get_root().get_node("PlayerScene")
	


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

# REMOVE CURSOR
func remove_cursor():
	if has_node("custom_cursor"):
		$custom_cursor.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

# SHOW SPECIFIC BACKGROUND CHILD BY NAME
func show_background(bg_name: String) -> void:
	if background:
		hide_all_children(background)
		background.visible = true
		if background.has_node(bg_name):
			bg_node = background.get_node(bg_name)
			bg_node.visible = true
			if bg_node is AnimatedSprite2D and bg_node.has_method("play"):
				bg_node.play("default")

func hide_background(bg_name: String) -> void:
	if background and background.has_node(bg_name):
		bg_node = background.get_node(bg_name)
		bg_node.visible = false

# ---------------------SHOW/HIDE/REMOVE MAIN MENU
func show_main_menu():
	if sound_manager:
		sound_manager.play_music("main_bgm")
	# SHOW ONLY SPECIFIC BACKGROUND
	show_background("game_animated_bg")
	# USE NEW HIERARCHY FOR MAIN_MENU
	if ui_layout.has_node("main_menu"):
		main_menu = ui_layout.get_node("main_menu")
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
				child.visible = false

func remove_main_menu():
	if main_menu:
		sound_manager.stop_music("main_bgm")
		background.queue_free()
		main_menu.visible=false
		main_menu.queue_free()

func hide_main_menu():
	if main_menu:
		main_menu.visible = false
		main_menu.visible = false

func unhide_main_menu():
	if main_menu:
		main_menu.visible = true
		main_menu.visible = true

# --------------------------OVERLAY 
func show_close_button():
	if ui_layout.has_node("overlay"):
		var overlay = ui_layout.get_node("overlay")
		if overlay.has_node("close_button"):
			var close_btn = overlay.get_node("close_button")
			close_btn.visible = true

func show_overlay_tutorial():
	if ui_layout.has_node("overlay"):
		var overlay = ui_layout.get_node("overlay")
		overlay.visible = true
		hide_all_children(overlay)
		if overlay.has_node("tutorial"):
			var tutorial = overlay.get_node("tutorial")
			tutorial.visible = true
			show_close_button()

func show_overlay_credits():
	if ui_layout.has_node("overlay"):
		var overlay = ui_layout.get_node("overlay")
		overlay.visible = true
		hide_all_children(overlay)
		if overlay.has_node("credits"):
			var credits = overlay.get_node("credits")
			credits.visible = true
			show_close_button()

func close_overlay_button(node):
	var overlay = null
	if ui_layout.has_node("overlay"):
		overlay = ui_layout.get_node("overlay")
	if not overlay:
		return
	var current = node.get_parent()
	while current and current != overlay:
		var to_free = current
		current = current.get_parent()
		to_free.visible = false
		to_free.queue_free()
	overlay.visible = false

func show_game_ui_elements():
	if ui_layout.has_node("game_ui_elements"):
		var game_ui = ui_layout.get_node("game_ui_elements")
		hide_all_children(game_ui)
		game_ui.visible = true
		for child in game_ui.get_children():
			if child.has_method("set_visible"):
				child.visible = true
		
	# ONLY SHOW BACKGROUND AND UI_LAYOUT, HIDE OTHER DIRECT CHILDREN
	show_only_nodes(["background", "ui_layout"])
	# ONLY SHOW game_ui_elements INSIDE UI_LAYOUT, HIDE OTHERS
	for child in ui_layout.get_children():
		if child.name == "game_ui_elements":
			if child.has_method("set_visible"):
				child.visible = true
		else:
			if child.has_method("set_visible"):
				child.visible = false

# TIME INDICATOR LOGIC
func refresh_time_indicator():
	if ui_layout.has_node("game_ui_elements"):
		var game_ui = ui_layout.get_node("game_ui_elements")
		if game_ui.has_node("time_indicator"):
			time_indicator = game_ui.get_node("time_indicator")

# Set the animation type: "clockwise_time_indicator", "counterclockwise_time_indicator", "fixed"
func set_time_indicator_animation(anim_type: String) -> void:
	refresh_time_indicator()
	if time_indicator and time_indicator.is_visible_in_tree():
		time_indicator.animation = anim_type
		time_indicator.frame = 0
		time_indicator.pause()

# Move the time indicator frame forward or backward
func move_time_indicator_frame(forward: bool = true) -> void:
	refresh_time_indicator()
	if not time_indicator or not time_indicator.is_visible_in_tree():
		return
	# Only move if player is present in the same node
	var frame_count = time_indicator.sprite_frames.get_frame_count(time_indicator.animation)
	if frame_count <= 1:
		return
	var current_frame = time_indicator.frame
	if forward:
		current_frame += 1
		if current_frame >= frame_count:
			current_frame = frame_count - 1
	else:
		current_frame -= 1
		if current_frame < 0:
			current_frame = 0
	time_indicator.frame = current_frame
	time_indicator.pause()

# Reset time indicator to first frame
func reset_time_indicator() -> void:
	refresh_time_indicator()
	if time_indicator:
		time_indicator.frame = 0

func update_time_indicator_by_move(move: int) -> void:
	refresh_time_indicator()
	if not time_indicator or not time_indicator.is_visible_in_tree():
		return
	var anim_type = "clockwise_time_indicator" if move >= 0 else "counterclockwise_time_indicator"
	if anim_type != last_anim_type:
		time_indicator.animation = anim_type
		last_anim_type = anim_type
	var frame = abs(move) % 12
	time_indicator.frame = frame

func set_time_indicator_fixed() -> void:
	refresh_time_indicator()
	if time_indicator:
		print("[DEBUG] set_time_indicator_fixed: time_indicator before set:", time_indicator)
		time_indicator.animation = "fixed"
		time_indicator.frame = 0
		print("[DEBUG] set_time_indicator_fixed: time_indicator set to fixed, frame 0.")




