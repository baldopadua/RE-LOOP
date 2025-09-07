extends Control

func _ready():
	# Show game_animated_bg, main_menu, and custom_cursor via UiHandler
	var ui_handler = $UiHandler
	ui_handler.show_nodes(["game_animated_bg", "main_menu", "custom_cursor"])
	# If you want to show only one node, use:
	# ui_handler.show_node("game_animated_bg")
	ui_handler.show_main_menu()
	ui_handler.show_cursor()

