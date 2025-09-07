extends Control

@onready var ui_handler = $UiHandler

func _ready():
	#ui_handler.show_only_children(ui_handler.ui_layout, ["overlay"])
	ui_handler.show_main_menu()
	ui_handler.show_cursor()
	_connect_main_menu_buttons()

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

func _on_main_menu_button_pressed(button_type):
	if button_type == "start" and ui_handler.sound_manager:
		ui_handler.sound_manager.stop_music("main_bgm")
		ui_handler.remove_main_menu()
		# TODO: Add start game logic here
		pass
	elif button_type == "tutorial":
		ui_handler.hide_main_menu()
		# TODO: Show tutorial overlay logic here
		pass
	elif button_type == "credits":
		ui_handler.hide_main_menu()
		# TODO: Show credits overlay logic here
		pass




