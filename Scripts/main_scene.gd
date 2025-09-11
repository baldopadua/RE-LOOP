extends Control

@onready var ui_handler = $CanvasLayerUi/UiHandler
@onready var transition_handler = $TransitionHandler
@onready var game_scene: Node = $GameScene


func _ready():
	#ui_handler.show_only_children(ui_handler.ui_layout, ["overlay"])
	ui_handler.show_main_menu()
	ui_handler.show_cursor()
	transition_handler.show_main_to_game_transition()
	_connect_main_menu_buttons()
	_connect_overlay_close_button()
	_connect_game_ui_elements_buttons()
	$GameScene.visible= false;
	$GameScene.process_mode = Node.PROCESS_MODE_DISABLED

func _connect_main_menu_buttons():
	if ui_handler.ui_layout.has_node("main_menu"):
		var main_menu = ui_handler.ui_layout.get_node("main_menu")
		# Start Button
		if main_menu.has_node("start_button"):
			var start_btn = main_menu.get_node("start_button")
			if not start_btn.is_connected("pressed", Callable(self, "_on_main_menu_button_pressed")):
				start_btn.connect("pressed", Callable(self, "_on_main_menu_button_pressed").bind("start"))
		# Tutorial Button
		if main_menu.has_node("tutorial_button"):
			var tutorial_btn = main_menu.get_node("tutorial_button")
			if not tutorial_btn.is_connected("pressed", Callable(self, "_on_main_menu_button_pressed")):
				tutorial_btn.connect("pressed", Callable(self, "_on_main_menu_button_pressed").bind("tutorial"))
		# Credits Button
		if main_menu.has_node("credits_button"):
			var credits_btn = main_menu.get_node("credits_button")
			if not credits_btn.is_connected("pressed", Callable(self, "_on_main_menu_button_pressed")):
				credits_btn.connect("pressed", Callable(self, "_on_main_menu_button_pressed").bind("credits"))

func _connect_game_ui_elements_buttons():
	if ui_handler.ui_layout.has_node("game_ui_elements"):
		var game_ui = ui_handler.ui_layout.get_node("game_ui_elements")
		# Tutorial Button
		if game_ui.has_node("tutorial_button"):
			var tutorial_btn = game_ui.get_node("tutorial_button")
			if not tutorial_btn.is_connected("pressed", Callable(self, "_on_game_ui_elements_button_pressed")):
				tutorial_btn.connect("pressed", Callable(self, "_on_game_ui_elements_button_pressed").bind("tutorial"))
		# Hint Button
		if game_ui.has_node("hint_button"):
			var hint_btn = game_ui.get_node("hint_button")
			if not hint_btn.is_connected("pressed", Callable(self, "_on_game_ui_elements_button_pressed")):
				hint_btn.connect("pressed", Callable(self, "_on_game_ui_elements_button_pressed").bind("hint"))

func _connect_overlay_close_button():
	if ui_handler.ui_layout.has_node("overlay"):
		var overlay = ui_handler.ui_layout.get_node("overlay")
		if overlay.has_node("close_button"):
			var close_btn = overlay.get_node("close_button")
			if not close_btn.is_connected("pressed", Callable(self, "_on_overlay_close_button_pressed")):
				close_btn.connect("pressed", Callable(self, "_on_overlay_close_button_pressed").bind(close_btn))

func _on_overlay_close_button_pressed(close_btn):
	ui_handler.sound_manager.play_ui("page_turn")
	ui_handler.close_overlay_button(close_btn)
	ui_handler.unhide_main_menu()

func _on_main_menu_button_pressed(button_type):
	if ui_handler.sound_manager:
		if button_type == "start":
			ui_handler.sound_manager.play_ui("click")
			ui_handler.remove_cursor()
			ui_handler.remove_main_menu()
			transition_handler.visible = true 
			transition_handler.show_main_to_game_transition()
			await get_tree().create_timer(4.5).timeout 
			transition_handler.visible = false 
			$GameScene.visible= true;
			$GameScene.process_mode = Node.PROCESS_MODE_INHERIT
			ui_handler.show_game_ui_elements()
		elif button_type == "tutorial":
			ui_handler.sound_manager.play_ui("page_turn")
			ui_handler.hide_main_menu()
			ui_handler.show_overlay_tutorial()
		elif button_type == "credits":
			ui_handler.sound_manager.play_ui("page_turn")
			ui_handler.hide_main_menu()
			ui_handler.show_overlay_credits()
			ui_handler.hide_main_menu()
			ui_handler.show_overlay_credits()

func _on_game_ui_elements_button_pressed(button_type):
	if ui_handler.sound_manager:
		if button_type == "tutorial":
			ui_handler.sound_manager.play_ui("page_turn")
			ui_handler.show_overlay_tutorial()
		elif button_type == "hint":
			ui_handler.sound_manager.play_ui("page_turn")
			ui_handler.show_overlay_hint()
