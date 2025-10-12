extends Control

var current_level: String = "level_1"  # Default to level_1 level
var connected_level_handler: Node = null
@onready var plooy_hint = $plooy_hint

# Remove this line since we'll initialize in _ready
# var ui_handler = get_parent().get_parent().get_parent()

# Add hint progress tracking
var hint_progress = {}  # Dictionary to store progress per level
# Example: hint_progress = { "level_1": "medium", "level_2": "easy" }

# Reference nodes for easier access
@onready var hint_status_bar = $hint_dialog/hint_status_bar
@onready var hint_2_timer = $hint_dialog/hint_2/hint_2_timer
@onready var hint_2_lock = $hint_dialog/hint_2/hint_2_lock
@onready var hint_2_overlay = $hint_dialog/hint_2/hint_2_overlay
@onready var solution_timer = $hint_dialog/solution/solution_timer
@onready var solution_lock = $hint_dialog/solution/solution_lock
@onready var solution_overlay = $hint_dialog/solution/solution_overlay

# Store markers for bar movement
@onready var hint_1_mark = $hint_dialog/hint_1_mark
@onready var hint_2_mark = $hint_dialog/hint_2_mark
@onready var solution_mark = $hint_dialog/solution_mark

var ui_handler = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start plooy animation
	if plooy_hint:
		plooy_hint.play()
	
	# Initialize ui_handler reference here instead
	ui_handler = get_parent().get_parent().get_parent()
	
	# Set initial timer label visibility using deferred call to ensure it works
	call_deferred("_init_timer_labels")
	
	# Initial connection attempt
	connect_to_level_handler()
	
	# Set up a timer to periodically check for new level handlers and update current level
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_check_for_level_handler)
	timer.autostart = true
	add_child(timer)
	
	# Connect hint timers
	if hint_2_timer:
		hint_2_timer.timeout.connect(_on_hint_2_timer_timeout)
	if solution_timer:
		solution_timer.timeout.connect(_on_solution_timer_timeout)
	
	# Update timer display every second
	var update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_update_timer_displays)
	update_timer.autostart = true
	add_child(update_timer)

# New function to initialize timer labels
func _init_timer_labels() -> void:
	if hint_2_timer and hint_2_timer.has_node("timer_label"):
		var label = hint_2_timer.get_node("timer_label") 
		label.visible = false
		label.modulate.a = 0
	
	if solution_timer and solution_timer.has_node("timer_label"):
		var label = solution_timer.get_node("timer_label")
		label.visible = false 
		label.modulate.a = 0

# Update timer displays
func _update_timer_displays():
	# Update hint 2 timer display 
	if hint_2_timer:
		var label = hint_2_timer.get_node("timer_label")
		if label:
			# Only update text if the label is actually visible
			if label.visible:
				if hint_2_timer.time_left > 0:
					label.text = format_time(hint_2_timer.time_left)
				else:
					# Show wait_time when timer is not running
					label.text = format_time(hint_2_timer.wait_time)
			
	# Update solution timer display
	if solution_timer:
		var label = solution_timer.get_node("timer_label")
		if label:
			# Only update text if the label is actually visible
			if label.visible:
				if solution_timer.time_left > 0:
					label.text = format_time(solution_timer.time_left)
				else:
					# Show wait_time when timer is not running
					label.text = format_time(solution_timer.wait_time)

# Helper function to format time as MM:SS
func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60.0)
	var remaining_seconds = int(seconds) % 60
	return "%d:%02d" % [minutes, remaining_seconds]

# Helper function to fade out elements
func fade_out_elements(elements: Array[Node]) -> void:
	for element in elements:
		if not element:
			continue
			
		# Create shake animation
		var shake_tween = create_tween()
		var original_pos = element.position
		var shake_strength = 5.0
		var shake_duration = 0.05
		var shake_count = 4
		
		# Add multiple shake movements
		for i in range(shake_count):
			# Shake right
			shake_tween.tween_property(element, "position", 
				original_pos + Vector2(shake_strength, 0), shake_duration)
			# Shake left
			shake_tween.tween_property(element, "position", 
				original_pos + Vector2(-shake_strength, 0), shake_duration)
		
		# Return to original position
		shake_tween.tween_property(element, "position", original_pos, shake_duration)
		
		# Wait for shake to finish before fading
		await shake_tween.finished
		
		# Fade out
		var fade_tween = create_tween()
		fade_tween.tween_property(element, "modulate", Color(1, 1, 1, 0), 0.3)
			
# Handle hint 2 timer completion
func _on_hint_2_timer_timeout():
	# Stop the timer and hide its label
	hint_2_timer.stop()
	if hint_2_timer.has_node("timer_label"):
		hint_2_timer.get_node("timer_label").visible = false
	
	# Save progress
	hint_progress[current_level] = "medium"
	
	# Fade out hint 2 elements
	fade_out_elements([hint_2_lock, hint_2_overlay])
	
	# Move status bar to hint 2 mark
	var bar_tween = create_tween()
	bar_tween.tween_property(hint_status_bar, "position", hint_2_mark.position, 0.5)
	
	# Update hint text and start solution timer
	update_hint_text("medium")
	if solution_timer:
		# Make solution timer label visible and start timer
		if solution_timer.has_node("timer_label"):
			solution_timer.get_node("timer_label").visible = true
		solution_timer.start()

	
	if ui_handler:
		ui_handler.shake_hint_button()

# Handle solution timer completion
func _on_solution_timer_timeout():
	# Stop the timer and hide its label
	solution_timer.stop()
	if solution_timer.has_node("timer_label"):
		solution_timer.get_node("timer_label").visible = false

	# Save progress
	hint_progress[current_level] = "easy"
	
	# Fade out solution elements
	fade_out_elements([solution_lock, solution_overlay])
	
	# Move status bar to solution mark
	var bar_tween = create_tween()
	bar_tween.tween_property(hint_status_bar, "position", solution_mark.position, 0.5)
	
	# Update hint text
	update_hint_text("easy")

	
	if ui_handler:
		ui_handler.shake_hint_button()

func update_hint_text(difficulty: String):
	# Hide all hint texts
	for level in range(1, 13):  # Assuming 12 levels
		var level_hint = get_node_or_null("level_" + str(level) + "_hint")
		if level_hint:
			for hint in level_hint.get_children():
				hint.visible = false
			
			# Show appropriate difficulty hint
			var hint_node = level_hint.get_node_or_null("hint_1_" + difficulty)
			if hint_node:
				hint_node.visible = true

func show_appropriate_container():
	# Don't show any hints in lobby
	if connected_level_handler and connected_level_handler.is_lobby:
		return
		
	# Hide all level hint containers first
	for level in range(1, 13):  # Assuming 12 levels
		var container = get_node_or_null("level_" + str(level) + "_hint")
		if container:
			container.visible = false
	
	# Show current level's hint container and dynamically look for available hints
	var current_container = get_node_or_null(current_level + "_hint")
	if current_container:
		current_container.visible = true
		
		# Initialize progress for new level
		if not hint_progress.has(current_level):
			hint_progress[current_level] = "hard"
		
		var last_difficulty = hint_progress[current_level]
		update_hint_text(last_difficulty)
		
		# Only proceed with UI updates if not in lobby
		if hint_status_bar:
			match last_difficulty:
				"hard":
					hint_status_bar.position = hint_1_mark.position
					# Only start hint_2_timer if in a level and on hard difficulty
					if hint_2_timer and hint_2_timer.time_left <= 0 and not connected_level_handler.is_lobby:
						hint_2_timer.start()
				"medium":
					hint_status_bar.position = hint_2_mark.position
					if hint_2_lock and hint_2_overlay:
						hint_2_lock.modulate.a = 0
						hint_2_overlay.modulate.a = 0
					# Only start solution timer if we're on medium and timer isn't running
					if solution_timer and solution_timer.time_left <= 0:
						solution_timer.start()
				"easy":
					hint_status_bar.position = solution_mark.position
					# Make both hint 2 and solution elements invisible
					if hint_2_lock and hint_2_overlay:
						hint_2_lock.modulate.a = 0
						hint_2_overlay.modulate.a = 0
					if solution_lock and solution_overlay:
						solution_lock.modulate.a = 0
						solution_overlay.modulate.a = 0
		
		# Show timer labels based on current difficulty
		if hint_2_timer and hint_2_timer.has_node("timer_label"):
			# Don't make timer label visible here - let overlay control this
			# Just update the text content
			var label = hint_2_timer.get_node("timer_label")
			if label:
				if hint_2_timer.time_left > 0:
					label.text = format_time(hint_2_timer.time_left)
				else:
					label.text = format_time(hint_2_timer.wait_time)
				
		if solution_timer and solution_timer.has_node("timer_label"):
			# Don't make timer label visible here - let overlay control this
			# Just update the text content
			var label = solution_timer.get_node("timer_label")
			if label:
				if solution_timer.time_left > 0:
					label.text = format_time(solution_timer.time_left)
				else:
					label.text = format_time(solution_timer.wait_time)

func _check_for_level_handler():
	# Always check for new level handlers since levels get destroyed/recreated
	var current_handler = find_level_handler()
	if current_handler and current_handler != connected_level_handler:
		connect_to_level_handler()
	
	# Update current level from level_handler's current_level_number
	if connected_level_handler and is_instance_valid(connected_level_handler):
		# Skip processing if we're in lobby
		if connected_level_handler.is_lobby:
			return
			
		var level_number = connected_level_handler.current_level_number
		# Only update if we're not in lobby (level_number > 0)
		if level_number > 0:
			var new_level = "level_" + str(level_number)
			if new_level != current_level:
				# Level changed - reset hint progress and UI
				current_level = new_level
				_reset_hint_state()
				show_appropriate_container()
				print("Hint: Level updated to ", current_level)

# Reset hint progress and UI state when changing levels
func _reset_hint_state():
	# Clear progress for new level
	hint_progress[current_level] = "hard"
	
	# Reset UI elements
	if hint_status_bar:
		hint_status_bar.position = hint_1_mark.position
	
	# Reset overlays visibility
	if hint_2_lock and hint_2_overlay:
		hint_2_lock.modulate = Color(1, 1, 1, 1)
		hint_2_overlay.modulate = Color(1, 1, 1, 1)
	if solution_lock and solution_overlay:
		solution_lock.modulate = Color(1, 1, 1, 1)
		solution_overlay.modulate = Color(1, 1, 1, 1)
	
	# Reset timers and ensure labels are hidden
	if hint_2_timer:
		hint_2_timer.stop()
		if hint_2_timer.has_node("timer_label"):
			var label = hint_2_timer.get_node("timer_label")
			label.visible = false
			label.modulate.a = 0
			label.text = format_time(hint_2_timer.wait_time)
			
	if solution_timer:
		solution_timer.stop()
		if solution_timer.has_node("timer_label"):
			var label = solution_timer.get_node("timer_label")
			label.visible = false
			label.modulate.a = 0
			label.text = format_time(solution_timer.wait_time)

func find_level_handler() -> Node:
	# Search the entire scene tree for the level_handler script
	var root = get_tree().current_scene
	if not root:
		root = get_tree().root
	
	return _search_for_level_handler(root)

func _search_for_level_handler(node: Node) -> Node:
	# Check if this node has the level_handler script
	if node.get_script():
		var script_path = node.get_script().get_path()
		if "level_handler.gd" in script_path:
			return node
	
	# Search through all children recursively
	for child in node.get_children():
		var result = _search_for_level_handler(child)
		if result:
			return result
	
	return null

func connect_to_level_handler():
	var level_handler = find_level_handler()
	if level_handler:
		connected_level_handler = level_handler
	else:
		print("Hint: No level handler found")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func find_level_handler_upwards() -> Node:
	# Searches up the scene tree for a node with the "level_instantiated" signal
	var node = get_parent()
	while node:
		if node.has_signal("level_instantiated"):
			return node
		node = node.get_parent()
	return null

func show_hint():
	# Don't show hints in lobby
	if connected_level_handler and connected_level_handler.is_lobby:
		return
		
	visible = true
	# Only start timers if we're not in lobby, but don't make timer labels visible yet
	if connected_level_handler and connected_level_handler.current_level_number > 0:
		var current_diff = hint_progress.get(current_level, "hard")
		if current_diff == "hard" and hint_2_timer and hint_2_timer.time_left <= 0:
			hint_2_timer.start()
		elif current_diff == "medium" and solution_timer and solution_timer.time_left <= 0:
			solution_timer.start()
func hide_hint():
	visible = false



