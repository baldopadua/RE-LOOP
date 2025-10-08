extends Control

var current_level: String = "level_1"  # Default to level_1 level
var connected_level_handler: Node = null
@onready var plooy_hint = $plooy_hint

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start plooy animation
	if plooy_hint:
		plooy_hint.play()
	
	# Set initial timer label visibility to false
	if hint_2_timer and hint_2_timer.has_node("timer_label"):
		hint_2_timer.get_node("timer_label").visible = false
	if solution_timer and solution_timer.has_node("timer_label"):
		solution_timer.get_node("timer_label").visible = false
	
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

# Update timer displays
func _update_timer_displays():
	# Update hint 2 timer display
	if hint_2_timer and hint_2_timer.time_left > 0:
		var label = hint_2_timer.get_node("timer_label")
		if label:
			label.text = str(ceil(hint_2_timer.time_left))
			
	# Update solution timer display
	if solution_timer and solution_timer.time_left > 0:
		var label = solution_timer.get_node("timer_label")
		if label:
			label.text = str(ceil(solution_timer.time_left))

# Helper function to fade out elements
func fade_out_elements(elements: Array[Node]) -> void:
	var tween = create_tween()
	for element in elements:
		if element:
			tween.parallel().tween_property(element, "modulate", Color(1, 1, 1, 0), 0.5)
			
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
	# Hide all level hint containers first
	for level in range(1, 13):  # Assuming 12 levels
		var container = get_node_or_null("level_" + str(level) + "_hint")
		if container:
			container.visible = false
	
	# Show current level's hint container and dynamically look for available hints
	var current_container = get_node_or_null(current_level + "_hint")
	if current_container:
		current_container.visible = true
		
		# Check if this is a new level without progress
		if not hint_progress.has(current_level):
			hint_progress[current_level] = "hard"
		
		var last_difficulty = hint_progress[current_level]
		update_hint_text(last_difficulty)
		
		# Update status bar position based on difficulty
		if hint_status_bar:
			match last_difficulty:
				"hard":
					hint_status_bar.position = hint_1_mark.position
					# Only start hint_2_timer if we're on hard difficulty and timer isn't running
					if hint_2_timer and hint_2_timer.time_left <= 0:
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
			hint_2_timer.get_node("timer_label").visible = last_difficulty == "hard"
		if solution_timer and solution_timer.has_node("timer_label"):
			solution_timer.get_node("timer_label").visible = last_difficulty == "medium"

func _check_for_level_handler():
	# Always check for new level handlers since levels get destroyed/recreated
	var current_handler = find_level_handler()
	if current_handler and current_handler != connected_level_handler:
		connect_to_level_handler()
	
	# Update current level from level_handler's current_level_number
	if connected_level_handler and is_instance_valid(connected_level_handler):
		var level_number = connected_level_handler.current_level_number
		if level_number > 0:
			var new_level = "level_" + str(level_number)
			if new_level != current_level:
				# Level changed - reset hint progress and UI
				current_level = new_level
				_reset_hint_state()
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
		hint_2_lock.modulate.a = 1
		hint_2_overlay.modulate.a = 1
	if solution_lock and solution_overlay:
		solution_lock.modulate.a = 1
		solution_overlay.modulate.a = 1
	
	# Reset and hide timer labels
	if hint_2_timer:
		hint_2_timer.stop()
		if hint_2_timer.has_node("timer_label"):
			hint_2_timer.get_node("timer_label").visible = false
	if solution_timer:
		solution_timer.stop()
		if solution_timer.has_node("timer_label"):
			solution_timer.get_node("timer_label").visible = false

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
	visible = true
	
func hide_hint():
	visible = false



