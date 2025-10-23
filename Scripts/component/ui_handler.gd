extends Control

@onready var sound_manager = get_node("SoundManager")
@onready var ui_logic = $ui_logic
@onready var background = $background
@onready var time_indicator = $ui_logic/game_ui_elements/time_indicator
@onready var cutscene = $cutscene
var hint_button = null 

var bg_node: Node = null
var main_menu: Node = null
var player: Node = null
var last_anim_type: String = ""

var nodes = []
var all_nodes = _get_all_nodes(self)

func _ready() -> void:
	_connect_hover_sound(self)
	hint_button = ui_logic.get_node_or_null("game_ui_elements/hint_button")  

func _process(_delta: float) -> void:
	pass
	
# RECURSIVELY GET ALL NODES UNDER THIS NODE (INCLUDING NESTED)
func _get_all_nodes(parent: Node) -> Array:
	
	for child in parent.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	return nodes

# SHOW ONLY THE NODES WITH NAMES IN NODE_NAMES, HIDE OTHERS
func show_nodes(node_names: Array) -> void:
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
	show_background("game_animated_bg")
	# USE NEW HIERARCHY FOR MAIN_MENU
	if ui_logic.has_node("main_menu"):
		main_menu = ui_logic.get_node("main_menu")
		hide_all_children(main_menu)
		main_menu.visible = true
		for child in main_menu.get_children():
			if child.has_method("set_visible"):
				child.visible = true
		auto_play_visible_sprites(main_menu)
	# ONLY SHOW BACKGROUND AND UI_logic, HIDE OTHER DIRECT CHILDREN
	show_only_nodes(["background", "ui_logic"])
	# ONLY SHOW MAIN_MENU INSIDE UI_logic, HIDE OTHERS
	for child in ui_logic.get_children():
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
	if ui_logic.has_node("overlay"):
		var overlay = ui_logic.get_node("overlay")
		if overlay.has_node("close_button"):
			var close_btn = overlay.get_node("close_button")
			close_btn.visible = true

func show_overlay_tutorial():
	if ui_logic.has_node("overlay"):
		var overlay = ui_logic.get_node("overlay")
		if overlay.has_node("tutorial"):
			var tutorial = overlay.get_node("tutorial")
			ui_logic.animate_overlay_open_from_right(tutorial)
			overlay.visible = true
			hide_all_children(overlay)
			tutorial.visible = true
			show_close_button()

func show_overlay_credits():
	if ui_logic.has_node("overlay"):
		var overlay = ui_logic.get_node("overlay")
		overlay.visible = true
		hide_all_children(overlay)
		if overlay.has_node("credits"):
			var credits = overlay.get_node("credits")
			var button = ui_logic.credits_button
			var tween = ui_logic.popup_overlay_from_button(button, credits)
			credits.visible = true
			if tween:
				await tween.finished
			show_close_button()

func close_overlay_button(_node):
	var overlay = ui_logic.get_node_or_null("overlay")
	if not overlay:
		return
	
	# FIND WHICH OVERLAY CHILD IS VISIBLE
	var visible_child = null
	for child in overlay.get_children():
		if child.visible and child.name != "close_button":
			visible_child = child
			break
	
	# SPECIAL HANDLING FOR HINT OVERLAY
	if visible_child and visible_child.name == "hint":
		
		var hint_bg = visible_child.get_node_or_null("hint_bg")
		var hint_dialog = visible_child.get_node_or_null("hint_dialog")
		var hint_2_timer = hint_dialog.get_node_or_null("hint_2/hint_2_timer") if hint_dialog else null
		var solution_timer = hint_dialog.get_node_or_null("solution/solution_timer") if hint_dialog else null
		
		if hint_bg:
			hint_bg.visible = false
		if hint_dialog:
			hint_dialog.visible = false
			
		if hint_2_timer and hint_2_timer.has_node("timer_label"):
			hint_2_timer.get_node("timer_label").visible = false
			hint_2_timer.get_node("timer_label").modulate.a = 0
		if solution_timer and solution_timer.has_node("timer_label"):
			solution_timer.get_node("timer_label").visible = false
			solution_timer.get_node("timer_label").modulate.a = 0
	
	# HIDE VISIBLE OVERLAY AND CLOSE BUTTON
	if visible_child:
		visible_child.visible = false
	if overlay.has_node("close_button"):
		overlay.get_node("close_button").visible = false
	
	overlay.visible = false
	
func show_game_ui_elements():
	if ui_logic.has_node("game_ui_elements"):
		var game_ui = ui_logic.get_node("game_ui_elements")
		hide_all_children(game_ui)
		game_ui.visible = true
		for child in game_ui.get_children():
			if child.has_method("set_visible"):
				child.visible = true
		
	# ONLY SHOW BACKGROUND AND UI_logic, HIDE OTHER DIRECT CHILDREN
	show_only_nodes(["background", "ui_logic"])
	# ONLY SHOW game_ui_elements INSIDE UI_logic, HIDE OTHERS
	for child in ui_logic.get_children():
		if child.name == "game_ui_elements":
			if child.has_method("set_visible"):
				child.visible = true
		else:
			if child.has_method("set_visible"):
				child.visible = false


func show_overlay_hint():
	if not ui_logic or not ui_logic.has_node("overlay"):
		return
		
	var overlay = ui_logic.get_node("overlay")
	if not overlay.has_node("hint"):
		return
		
	# SHOW OVERLAY
	overlay.visible = true
	hide_all_children(overlay)
	
	# SHOW HINT AND CHECK ALL REQUIRED NODES
	var hint = overlay.get_node("hint")
	hint.visible = true
	
	var hint_bg = hint.get_node_or_null("hint_bg")
	var hint_dialog = hint.get_node_or_null("hint_dialog")
	
	if hint_bg:
		hint_bg.visible = true
	
	if hint_dialog:
		hint_dialog.visible = true
		
		# Get the current level difficulty from hint component
		var current_level = hint.current_level
		var current_diff = "hard"
		if hint.hint_progress.has(current_level):
			current_diff = hint.hint_progress[current_level]
		
		# SHOW APPROPRIATE TIMER LABELS BASED ON DIFFICULTY
		if hint_dialog.has_node("hint_2/hint_2_timer/timer_label"):
			var timer_label = hint_dialog.get_node("hint_2/hint_2_timer/timer_label")
			timer_label.modulate.a = 1
			timer_label.visible = current_diff == "hard"
			
		if hint_dialog.has_node("solution/solution_timer/timer_label"):
			var solution_label = hint_dialog.get_node("solution/solution_timer/timer_label")
			solution_label.modulate.a = 1
			solution_label.visible = current_diff == "medium"
			
		var status_bar = hint_dialog.get_node_or_null("hint_status_bar")
		if status_bar:
			status_bar.visible = true
	
	hint.show_appropriate_container()
	show_close_button()

# --------------------------------------TIME INDICATOR LOGIC
func refresh_time_indicator():
	if ui_logic.has_node("game_ui_elements"):
		var game_ui = ui_logic.get_node("game_ui_elements")
		if game_ui.has_node("time_indicator"):
			time_indicator = game_ui.get_node("time_indicator")

# SET THE ANIMATION TYPE: "CLOCKWISE_TIME_INDICATOR", "COUNTERCLOCKWISE_TIME_INDICATOR", "FIXED"
func set_time_indicator_animation(anim_type: String) -> void:
	refresh_time_indicator()
	if time_indicator and time_indicator.is_visible_in_tree():
		time_indicator.animation = anim_type
		time_indicator.frame = 0
		time_indicator.pause()

# MOVE THE TIME INDICATOR FRAME FORWARD OR BACKWARD
func move_time_indicator_frame(forward: bool = true) -> void:
	refresh_time_indicator()
	if not time_indicator or not time_indicator.is_visible_in_tree():
		return
	# ONLY MOVE IF PLAYER IS PRESENT IN THE SAME NODE
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

# RESET TIME INDICATOR TO FIRST FRAME
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

func show_last_frame_then_reset():
	time_indicator.frame = 12
	await get_tree().create_timer(0.5).timeout  
	time_indicator.frame = 0

func set_time_indicator_fixed() -> void:
	refresh_time_indicator()
	if time_indicator:
		time_indicator.animation = "fixed"
		time_indicator.frame = 0
		
func set_default_time_indicator() -> void:
	refresh_time_indicator()
	await get_tree().create_timer(0.5).timeout
	if time_indicator:
		time_indicator.animation = "clockwise_time_indicator"
		time_indicator.frame = 0

# -------------------------------------------CUTSCENE FUNCTIONS
func show_level_cutscene(level_number: int, continue_callback: Callable = Callable()):
	if cutscene:
		hide_game_ui_during_cutscene()
		show_cursor()
		if sound_manager:
			sound_manager.play_ui("page_turn")
		cutscene.show_level_cutscene(level_number, continue_callback)

func hide_level_cutscene():
	if cutscene:
		cutscene.hide_cutscene()
		remove_cursor()

# HIDE GAME UI ELEMENTS DURING CUTSCENE
func hide_game_ui_during_cutscene():
	if ui_logic and ui_logic.has_node("game_ui_elements"):
		var game_ui = ui_logic.get_node("game_ui_elements")
		game_ui.visible = false

# SHOW GAME UI ELEMENTS AFTER CUTSCENE
func show_game_ui_after_cutscene():
	if ui_logic and ui_logic.has_node("game_ui_elements"):
		var game_ui = ui_logic.get_node("game_ui_elements")
		game_ui.visible = true

# HINT NOTIFICATION 
func shake_hint_button():
	
	if not hint_button:
		return
	
	# STORE ORIGINAL TEXTURE AND SWITCH TO HOVER TEXTURE
	var original_texture = hint_button.texture_normal
	hint_button.texture_normal = hint_button.texture_hover
	
	# CREATE REPEATING SHAKE ANIMATION
	for repeat in range(3): 
		var shake_tween = create_tween()
		var original_pos = hint_button.position
		var shake_strength = 5.0
		var shake_duration = 0.05 
		var shake_count = 4
		
		# ADD MULTIPLE SHAKE MOVEMENTS
		for i in range(shake_count):
			# SHAKE RIGHT
			shake_tween.tween_property(hint_button, "position", 
				original_pos + Vector2(shake_strength, 0), shake_duration)
			# SHAKE LEFT
			shake_tween.tween_property(hint_button, "position", 
				original_pos + Vector2(-shake_strength, 0), shake_duration)
		
		# RETURN TO ORIGINAL POSITION
		shake_tween.tween_property(hint_button, "position", original_pos, shake_duration)
		
		# ADD PAUSE BETWEEN REPETITIONS
		shake_tween.tween_interval(0.3)  
		await shake_tween.finished
	
	# RESET TEXTURE AFTER ALL SHAKES ARE DONE
	hint_button.texture_normal = original_texture
