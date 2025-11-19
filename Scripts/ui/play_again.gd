extends Control

var ui_handler = null
var processing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get reference to ui_handler
	ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")
	if not ui_handler:
		print("ERROR: play_again.gd could not find UiHandler")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_no_pressed() -> void:
	# Prevent multiple clicks
	if processing:
		print("Already processing - ignoring click")
		return

	processing = true
	print("=== PLAY AGAIN: NO - Closing dialog ===")

	# Disable buttons (they're in box/yes and box/no)
	var box = get_node_or_null("box")
	if box:
		var yes_button = box.get_node_or_null("yes")
		var no_button = box.get_node_or_null("no")
		if yes_button:
			yes_button.disabled = true
		if no_button:
			no_button.disabled = true

	# Play click sound
	if ui_handler and ui_handler.sound_manager:
		ui_handler.sound_manager.play_ui("click")

	# Hide the play_again dialog
	visible = false

	# Hide the overlay
	var overlay = get_parent()
	if overlay:
		overlay.visible = false

	# Remove cursor
	if ui_handler:
		ui_handler.remove_cursor()

	await get_tree().create_timer(0.3).timeout

	# Go to lobby (level 12 is completed, so go to hub)
	if ui_handler:
		print("Navigating to lobby...")
		ui_handler._navigate_to_lobby()

	processing = false

func _on_yes_pressed() -> void:
	# Prevent multiple clicks
	if processing:
		print("Already processing - ignoring click")
		return

	processing = true
	print("=== PLAY AGAIN: YES - Resetting game ===")

	# Disable buttons (they're in box/yes and box/no)
	var box = get_node_or_null("box")
	if box:
		var yes_button = box.get_node_or_null("yes")
		var no_button = box.get_node_or_null("no")
		if yes_button:
			yes_button.disabled = true
		if no_button:
			no_button.disabled = true

	# Play click sound
	if ui_handler and ui_handler.sound_manager:
		ui_handler.sound_manager.play_ui("click")

	# COMPLETELY hide the play_again dialog and overlay
	visible = false

	var overlay = get_parent()
	if overlay:
		overlay.visible = false
		# Also hide the entire ui_logic overlay system
		var ui_logic = overlay.get_parent()
		if ui_logic and ui_logic.has_node("overlay"):
			ui_logic.get_node("overlay").visible = false
			print("Hid overlay completely")

	# Remove cursor
	if ui_handler:
		ui_handler.remove_cursor()

	await get_tree().create_timer(0.3).timeout

	# Reset game state and return to main menu
	if ui_handler:
		print("Resetting game state...")
		ui_handler._reset_all_game_state()
		await get_tree().create_timer(0.5).timeout
		print("Returning to main menu...")
		ui_handler._return_to_main_menu()

	processing = false
