extends Control

var current_level: String = "level_1"  
var connected_level_handler: Node = null
@onready var plooy_hint = $plooy_hint
var hint_progress = {}  # DICTIONARY TO STORE PROGRESS PER LEVEL

# status bars are under hint_box/hint_dialog_empty
@onready var hint_1_status_bar = $hint_box/hint_dialog_empty/hint_1_status_bar
@onready var hint_2_status_bar = $hint_box/hint_dialog_empty/hint_2_status_bar
@onready var solution_status_bar = $hint_box/hint_dialog_empty/solution_status_bar
# timers/locks/overlays are under hint_box/hint_box_empty
@onready var hint_2_timer = $hint_box/hint_box_empty/hint_2/hint_2_timer
@onready var hint_2_lock = $hint_box/hint_box_empty/hint_2/hint_2_lock
@onready var hint_2_overlay = $hint_box/hint_box_empty/hint_2/hint_2_overlay
@onready var solution_timer = $hint_box/hint_box_empty/solution/solution_timer
@onready var solution_lock = $hint_box/hint_box_empty/solution/solution_lock
@onready var solution_overlay = $hint_box/hint_box_empty/solution/solution_overlay
@onready var skip_level_button = $hint_box/skip_level
@onready var enable_skip_button = get_node("/root/MainScene/CanvasLayerUi/UiHandler/ui_logic/overlay/settings/settings_box/enable_skip_toggle")

@onready var orig_hint_1_modulate: Color = hint_1_status_bar.modulate
@onready var orig_hint_2_modulate: Color = hint_2_status_bar.modulate
@onready var orig_solution_modulate: Color = solution_status_bar.modulate

var ui_handler = null

func _ready() -> void:
	if plooy_hint:
		plooy_hint.play()
	
	# Use global path to UiHandler to avoid parent traversal issues
	ui_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler")
	call_deferred("_init_timer_labels")
	connect_to_level_handler()
	
	# SET UP A TIMER TO PERIODICALLY CHECK FOR NEW LEVEL HANDLERS AND UPDATE CURRENT LEVEL
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_check_for_level_handler)
	timer.autostart = true
	add_child(timer)
	
	# CONNECT HINT TIMERS
	if hint_2_timer:
		hint_2_timer.timeout.connect(_on_hint_2_timer_timeout)
	if solution_timer:
		solution_timer.timeout.connect(_on_solution_timer_timeout)
	
	# UPDATE TIMER DISPLAY EVERY SECOND
	var update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_update_timer_displays)
	update_timer.autostart = true
	add_child(update_timer)

	if skip_level_button:
		skip_level_button.visible = false
		skip_level_button.disabled = true
		skip_level_button.pressed.connect(_on_skip_level_pressed)
	
	print("skip_level_button:", skip_level_button)
	print("enable_skip_button:", enable_skip_button)

func _init_timer_labels() -> void:
	if hint_2_timer and hint_2_timer.has_node("timer_label"):
		var label = hint_2_timer.get_node("timer_label") 
		label.visible = false
		label.modulate.a = 0
	
	if solution_timer and solution_timer.has_node("timer_label"):
		var label = solution_timer.get_node("timer_label")
		label.visible = false 
		label.modulate.a = 0

# UPDATE TIMER DISPLAYS
func _update_timer_displays():
	if hint_2_timer:
		var label = hint_2_timer.get_node("timer_label")
		if label:
			if label.visible:
				if hint_2_timer.time_left > 0:
					label.text = format_time(hint_2_timer.time_left)
				else:
					label.text = format_time(hint_2_timer.wait_time)
			
	# UPDATE SOLUTION TIMER DISPLAY
	if solution_timer:
		var label = solution_timer.get_node("timer_label")
		if label:
			if label.visible:
				if solution_timer.time_left > 0:
					label.text = format_time(solution_timer.time_left)
				else:
					label.text = format_time(solution_timer.wait_time)

# HELPER FUNCTION TO FORMAT TIME AS MM:SS
func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60.0)
	var remaining_seconds = int(seconds) % 60
	return "%d:%02d" % [minutes, remaining_seconds]

# HELPER FUNCTION TO FADE OUT ELEMENTS
func fade_out_elements(elements: Array[Node]) -> void:
	for element in elements:
		if not element:
			continue
			
		# CREATE SHAKE ANIMATION
		var shake_tween = create_tween()
		var original_pos = element.position
		var shake_strength = 5.0
		var shake_duration = 0.05
		var shake_count = 4
		
		# ADD MULTIPLE SHAKE MOVEMENTS
		for i in range(shake_count):
			# SHAKE RIGHT
			shake_tween.tween_property(element, "position", 
				original_pos + Vector2(shake_strength, 0), shake_duration)
			# SHAKE LEFT
			shake_tween.tween_property(element, "position", 
				original_pos + Vector2(-shake_strength, 0), shake_duration)
		# RETURN TO ORIGINAL POSITION
		shake_tween.tween_property(element, "position", original_pos, shake_duration)
		await shake_tween.finished
		# FADE OUT
		var fade_tween = create_tween()
		fade_tween.tween_property(element, "modulate", Color(1, 1, 1, 0), 0.3)
			
# HANDLE HINT 2 TIMER COMPLETION
func _on_hint_2_timer_timeout():
	hint_2_timer.stop()
	if hint_2_timer.has_node("timer_label"):
		hint_2_timer.get_node("timer_label").visible = false
	
	hint_progress[current_level] = "medium"
	
	fade_out_elements([hint_2_lock, hint_2_overlay])
	
	# TWEEN: previous (hint1) -> BLACK, hint2 -> original color
	var tween = create_tween()
	tween.tween_property(hint_1_status_bar, "modulate", Color(0, 0, 0, 1), 0.5)
	tween.tween_property(hint_2_status_bar, "modulate", orig_hint_2_modulate, 0.5)
	
	update_hint_text("medium")
	if solution_timer:
		if solution_timer.has_node("timer_label"):
			solution_timer.get_node("timer_label").visible = true
		solution_timer.start()

	if ui_handler:
		ui_handler.shake_hint_button()

# HANDLE SOLUTION TIMER COMPLETION
func _on_solution_timer_timeout():
	solution_timer.stop()
	if solution_timer.has_node("timer_label"):
		solution_timer.get_node("timer_label").visible = false

	hint_progress[current_level] = "easy"
	
	fade_out_elements([solution_lock, solution_overlay])
	
	# TWEEN: previous (hint2) -> BLACK, solution -> original color
	var tween = create_tween()
	tween.tween_property(hint_2_status_bar, "modulate", Color(0, 0, 0, 1), 0.5)
	tween.tween_property(solution_status_bar, "modulate", orig_solution_modulate, 0.5)
	
	update_hint_text("easy")

	if ui_handler:
		ui_handler.shake_hint_button()

func update_hint_text(difficulty: String):
	for level in range(1, 13):  
		var level_hint = $hint_box/hint_dialog_empty.get_node_or_null("level_" + str(level) + "_hint")
		if level_hint:
			for hint in level_hint.get_children():
				hint.visible = false
			var hint_node = level_hint.get_node_or_null("hint_%d_%s" % [level, difficulty])
			if hint_node:
				hint_node.visible = true
	# skip_level visibility handled by _on_enable_skip_toggled

func show_appropriate_container():
	print("show_appropriate_container: current_level =", current_level)
	# ...existing code...
	if connected_level_handler and connected_level_handler.is_lobby:
		return
		
	for level in range(1, 13): 
		var container = $hint_box/hint_dialog_empty.get_node_or_null("level_" + str(level) + "_hint")
		if container:
			container.visible = false
	
	var current_container = $hint_box/hint_dialog_empty.get_node_or_null(current_level + "_hint")
	if current_container:
		current_container.visible = true
		# Ensure all child labels are hidden except the correct one
		for hint in current_container.get_children():
			hint.visible = false
		
		if not hint_progress.has(current_level):
			hint_progress[current_level] = "hard"
		
		var last_difficulty = hint_progress[current_level]
		update_hint_text(last_difficulty)
		
		# SET STATUS-BAR COLORS BASED ON LAST DIFFICULTY (use BLACK for finished)
		if hint_1_status_bar and hint_2_status_bar and solution_status_bar:
			match last_difficulty:
				"hard":
					# hint1 normal, others black
					hint_1_status_bar.modulate = orig_hint_1_modulate
					hint_2_status_bar.modulate = Color(0, 0, 0, 1)
					solution_status_bar.modulate = Color(0, 0, 0, 1)
					if hint_2_timer and hint_2_timer.time_left <= 0 and not connected_level_handler.is_lobby:
						hint_2_timer.start()
				"medium":
					# hint1 black, hint2 normal, solution black
					hint_1_status_bar.modulate = Color(0, 0, 0, 1)
					hint_2_status_bar.modulate = orig_hint_2_modulate
					solution_status_bar.modulate = Color(0, 0, 0, 1)
					if hint_2_lock and hint_2_overlay:
						hint_2_lock.modulate.a = 0
						hint_2_overlay.modulate.a = 0
					if solution_timer and solution_timer.time_left <= 0:
						solution_timer.start()
				"easy":
					# hint1 black, hint2 black, solution normal
					hint_1_status_bar.modulate = Color(0, 0, 0, 1)
					hint_2_status_bar.modulate = Color(0, 0, 0, 1)
					solution_status_bar.modulate = orig_solution_modulate
					if hint_2_lock and hint_2_overlay:
						hint_2_lock.modulate.a = 0
						hint_2_overlay.modulate.a = 0
					if solution_lock and solution_overlay:
						solution_lock.modulate.a = 0
						solution_overlay.modulate.a = 0
		
		# SHOW TIMER LABELS BASED ON CURRENT DIFFICULTY
		if hint_2_timer and hint_2_timer.has_node("timer_label"):
			var label = hint_2_timer.get_node("timer_label")
			if label:
				if hint_2_timer.time_left > 0:
					label.text = format_time(hint_2_timer.time_left)
				else:
					label.text = format_time(hint_2_timer.wait_time)
				
		if solution_timer and solution_timer.has_node("timer_label"):
			var label = solution_timer.get_node("timer_label")
			if label:
				if solution_timer.time_left > 0:
					label.text = format_time(solution_timer.time_left)
				else:
					label.text = format_time(solution_timer.wait_time)

		# Also ensure skip_level button is updated
		if skip_level_button:
			# Only show if enable_skip is toggled ON
			if enable_skip_button and enable_skip_button.button_pressed:
				skip_level_button.visible = true
				skip_level_button.disabled = false
			else:
				skip_level_button.visible = false
				skip_level_button.disabled = true

func _check_for_level_handler():
	# ALWAYS CHECK FOR NEW LEVEL HANDLERS SINCE LEVELS GET DESTROYED/RECREATED
	var current_handler = find_level_handler()
	if current_handler and current_handler != connected_level_handler:
		connect_to_level_handler()
	
	# UPDATE CURRENT LEVEL FROM LEVEL_HANDLER'S CURRENT_LEVEL_NUMBER
	if connected_level_handler and is_instance_valid(connected_level_handler):
		if connected_level_handler.is_lobby:
			return
			
		var level_number = connected_level_handler.current_level_number
		# ONLY UPDATE IF WE'RE NOT IN LOBBY (LEVEL_NUMBER > 0)
		if level_number > 0:
			var new_level = "level_" + str(level_number)
			if new_level != current_level:
				print("Hint: Changing current_level from", current_level, "to", new_level)
				current_level = new_level
				_reset_hint_state()
				show_appropriate_container()
				print("Hint: Level updated to ", current_level)

func _reset_hint_state():
	hint_progress[current_level] = "hard"
	
	# RESET UI ELEMENTS: hint1 normal, others black
	if hint_1_status_bar:
		hint_1_status_bar.modulate = orig_hint_1_modulate
	if hint_2_status_bar:
		hint_2_status_bar.modulate = Color(0, 0, 0, 1)
	if solution_status_bar:
		solution_status_bar.modulate = Color(0, 0, 0, 1)
	
	# RESET OVERLAYS VISIBILITY
	if hint_2_lock and hint_2_overlay:
		hint_2_lock.modulate = Color(1, 1, 1, 1)
		hint_2_overlay.modulate = Color(1, 1, 1, 1)
	if solution_lock and solution_overlay:
		solution_lock.modulate = Color(1, 1, 1, 1)
		solution_overlay.modulate = Color(1, 1, 1, 1)
	
	# RESET TIMERS AND ENSURE LABELS ARE HIDDEN
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

	if skip_level_button:
		if enable_skip_button and enable_skip_button.button_pressed:
			skip_level_button.visible = true
			skip_level_button.disabled = false
		else:
			skip_level_button.visible = false
			skip_level_button.disabled = true

func find_level_handler() -> Node:
	# SEARCH THE ENTIRE SCENE TREE FOR THE LEVEL_HANDLER SCRIPT
	var root = get_tree().current_scene
	if not root:
		root = get_tree().root
	return _search_for_level_handler(root)

func _search_for_level_handler(node: Node) -> Node:
	if node.get_script():
		var script_path = node.get_script().get_path()
		# print("Checking node:", node.name, "Script path:", script_path)
		if "level_handler.gd" in script_path:
			return node
	for child in node.get_children():
		var result = _search_for_level_handler(child)
		if result:
			return result
	
	return null

func connect_to_level_handler():
	var level_handler = find_level_handler()
	print("connect_to_level_handler: found level_handler =", level_handler)
	if level_handler:
		connected_level_handler = level_handler
		# Connect to the new signal for hint level changes
		if not level_handler.is_connected("hint_level_changed", Callable(self, "_on_hint_level_changed")):
			level_handler.connect("hint_level_changed", Callable(self, "_on_hint_level_changed"))
	else:
		print("Hint: No level handler found")

func _on_hint_level_changed(level_number: int) -> void:
	if level_number > 0:
		var new_level = "level_" + str(level_number)
		if new_level != current_level:
			print("Hint: Signal - Changing current_level from", current_level, "to", new_level)
			current_level = new_level
			_reset_hint_state()
			show_appropriate_container()
	else:
		if current_level != "lobby":
			current_level = "lobby"
			_reset_hint_state()
			show_appropriate_container()

func _process(_delta: float) -> void:
	pass

func find_level_handler_upwards() -> Node:
	var node = get_parent()
	while node:
		if node.has_signal("level_instantiated"):
			return node
		node = node.get_parent()
	return null

func show_hint():
	if connected_level_handler and connected_level_handler.is_lobby:
		return
		
	visible = true

	# ONLY START TIMERS IF WE'RE NOT IN LOBBY, BUT DON'T MAKE TIMER LABELS VISIBLE YET
	if connected_level_handler and connected_level_handler.current_level_number > 0:
		var current_diff = hint_progress.get(current_level, "hard")
		print("show_hint: current_level =", current_level, "difficulty =", current_diff)
		if current_diff == "hard" and hint_2_timer and hint_2_timer.time_left <= 0:
			hint_2_timer.start()
		elif current_diff == "medium" and solution_timer and solution_timer.time_left <= 0:
			solution_timer.start()

	visible = false

func hide_hint():
	visible = false

func _on_skip_level_pressed():
	# Find the overlay node and hide it
	var overlay = get_parent()
	while overlay and overlay.name != "overlay":
		overlay = overlay.get_parent()
	if overlay:
		overlay.visible = false
	# Hide the hint itself
	visible = false
	# Optionally hide the close button if present
	if overlay and overlay.has_node("close_button"):
		overlay.get_node("close_button").visible = false

	# Trigger skip level signal on the handler
	if connected_level_handler and connected_level_handler.has_method("request_skip_level"):
		connected_level_handler.request_skip_level()


func _on_enable_skip_toggle_toggled(toggled_on: bool) -> void:

	if skip_level_button:
		skip_level_button.visible = toggled_on
		skip_level_button.disabled = not toggled_on
		skip_level_button.modulate = Color(1, 1, 0, 1) if toggled_on else Color(0.9368433, 0.8956263, 1, 1)
	if enable_skip_button:
		enable_skip_button.modulate = Color(1, 1, 0, 1) if toggled_on else Color(0.9368433, 0.8956263, 1, 1)
	# Only auto-show hint overlay if hint system is active (not lobby, level > 0)
	if toggled_on and ui_handler:
		var hint_btn = null
		if ui_handler.ui_logic and ui_handler.ui_logic.has_node("game_ui_elements/hint_button"):
			hint_btn = ui_handler.ui_logic.get_node("game_ui_elements/hint_button")
		# Check if hint system is active
		var level_handler = get_tree().root.get_node_or_null("MainScene/CanvasLayerUi/UiHandler").get_node_or_null("level_handler") if get_tree().root.has_node("MainScene/CanvasLayerUi/UiHandler") else null
		var hint_active = false
		if level_handler and level_handler.has_method("is_lobby") and level_handler.has_method("current_level_number"):
			hint_active = not level_handler.is_lobby and level_handler.current_level_number > 0
		elif connected_level_handler:
			hint_active = not connected_level_handler.is_lobby and connected_level_handler.current_level_number > 0
		if hint_btn and hint_btn.visible and hint_active:
			var ui_logic = ui_handler.ui_logic
			var overlay = ui_logic.get_node_or_null("overlay")
			if overlay:
				if overlay.has_node("settings"):
					overlay.get_node("settings").visible = false
				overlay.visible = false
			if ui_handler.has_method("show_overlay_hint"):
				ui_handler.show_overlay_hint()
