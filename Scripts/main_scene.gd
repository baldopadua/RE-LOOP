extends Control

@onready var ui_handler = $UiHandler

func _ready():
	# If you want to show only one node, use:
	# ui_handler.show_node("game_animated_bg")
	ui_handler.show_main_menu()
	ui_handler.show_cursor()

