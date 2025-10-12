extends Control

@onready var comics_container = $comics_container
@onready var cutscene_labels = $cutscene_labels
@onready var press_to_continue = $press_to_continue
@onready var ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")

var current_level: int = 0
var on_continue_callback: Callable

func _ready() -> void:
	hide_all_comics()
	press_to_continue.pressed.connect(_on_continue_pressed)

func _process(_delta: float) -> void:
	pass

func show_level_cutscene(level_number: int, continue_callback: Callable = Callable()):
	current_level = level_number
	on_continue_callback = continue_callback
	
	hide_all_comics()
	
	# SHOW THE SPECIFIC COMIC FOR THIS LEVEL
	var comic_node_name = "comics_level_" + str(level_number)
	if comics_container.has_node(comic_node_name):
		var comic_node = comics_container.get_node(comic_node_name)
		comic_node.visible = true
	
	cutscene_labels.text = "Level " + str(level_number) + " Story"
	visible = true

func hide_all_comics():
	for i in range(1, 13):  # LEVELS 1-12
		var comic_node_name = "comics_level_" + str(i)
		if comics_container.has_node(comic_node_name):
			var comic_node = comics_container.get_node(comic_node_name)
			comic_node.visible = false

func _on_continue_pressed():
	visible = false

	if ui_handler:
		ui_handler.remove_cursor()
		ui_handler.show_game_ui_after_cutscene()
	
	
	if on_continue_callback.is_valid():
		on_continue_callback.call()

func hide_cutscene():
	visible = false
	
	scale = Vector2(1.0, 1.0)
	
	if ui_handler:
		ui_handler.remove_cursor()
		ui_handler.show_game_ui_after_cutscene()
