extends Control

@onready var comics_container = $comics_container
@onready var cutscene_labels = $cutscene_labels
@onready var press_to_continue = $press_to_continue

var current_level: int = 0
var on_continue_callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide all comic panels initially
	hide_all_comics()
	# Connect the continue button
	press_to_continue.pressed.connect(_on_continue_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_level_cutscene(level_number: int, continue_callback: Callable = Callable()):
	current_level = level_number
	on_continue_callback = continue_callback
	
	# Hide all comics first
	hide_all_comics()
	
	# Show the specific comic for this level
	var comic_node_name = "comics_level_" + str(level_number)
	if comics_container.has_node(comic_node_name):
		var comic_node = comics_container.get_node(comic_node_name)
		comic_node.visible = true
	
	# Update the label text
	cutscene_labels.text = "Level " + str(level_number) + " Story"
	
	# Make the cutscene visible
	visible = true

func hide_all_comics():
	for i in range(1, 13):  # Levels 1-12
		var comic_node_name = "comics_level_" + str(i)
		if comics_container.has_node(comic_node_name):
			var comic_node = comics_container.get_node(comic_node_name)
			comic_node.visible = false

func _on_continue_pressed():
	# Hide the cutscene
	visible = false
	
	# Restore game UI through ui_handler
	var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
	if ui_handler:
		ui_handler.show_game_ui_after_cutscene()
	
	# Call the continue callback if provided
	if on_continue_callback.is_valid():
		on_continue_callback.call()

func hide_cutscene():
	visible = false
	
	# Restore game UI through ui_handler
	var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
	if ui_handler:
		ui_handler.show_game_ui_after_cutscene()
