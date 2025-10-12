extends Control

var current_level: String = "level_1"  
var connected_level_handler: Node = null
@onready var plooy_hint = $plooy_hint
var hint_progress = {}  # DICTIONARY TO STORE PROGRESS PER LEVEL
# Example: hint_progress = { "level_1": "medium", "level_2": "easy" }

# REFERENCE NODES FOR EASIER ACCESS
@onready var hint_status_bar = $hint_dialog/hint_status_bar
@onready var hint_2_timer = $hint_dialog/hint_2/hint_2_timer
@onready var hint_2_lock = $hint_dialog/hint_2/hint_2_lock
@onready var hint_2_overlay = $hint_dialog/hint_2/hint_2_overlay
@onready var solution_timer = $hint_dialog/solution/solution_timer
@onready var solution_lock = $hint_dialog/solution/solution_lock
@onready var solution_overlay = $hint_dialog/solution/solution_overlay

# STORE MARKERS FOR BAR MOVEMENT
@onready var hint_1_mark = $hint_dialog/hint_1_mark
@onready var hint_2_mark = $hint_dialog/hint_2_mark
@onready var solution_mark = $hint_dialog/solution_mark

var ui_handler = null

func _ready() -> void:
	if plooy_hint:
		plooy_hint.play()
	
	ui_handler = get_parent().get_parent().get_parent()
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
	
	var bar_tween = create_tween()
	bar_tween.tween_property(hint_status_bar, "position", hint_2_mark.position, 0.5)
	
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
	
	var bar_tween = create_tween()
	bar_tween.tween_property(hint_status_bar, "position", solution_mark.position, 0.5)
	
	update_hint_text("easy")

	if ui_handler:
		ui_handler.shake_hint_button()

func update_hint_text(difficulty: String):
	for level in range(1, 13):  
		var level_hint = get_node_or_null("level_" + str(level) + "_hint")
		if level_hint:
			for hint in level_hint.get_children():
				hint.visible = false
			
			var hint_node = level_hint.get_node_or_null("hint_1_" + difficulty)
			if hint_node:
				hint_node.visible = true

func show_appropriate_container():
	if connected_level_handler and connected_level_handler.is_lobby:
		return
		
	for level in range(1, 13): 
		var container = get_node_or_null("level_" + str(level) + "_hint")
		if container:
			container.visible = false
	
	var current_container = get_node_or_null(current_level + "_hint")
	if current_container:
		current_container.visible = true
		
		if not hint_progress.has(current_level):
			hint_progress[current_level] = "hard"
		
		var last_difficulty = hint_progress[current_level]
		update_hint_text(last_difficulty)
		
		if hint_status_bar:
			match last_difficulty:
				"hard":
					hint_status_bar.position = hint_1_mark.position
					if hint_2_timer and hint_2_timer.time_left <= 0 and not connected_level_handler.is_lobby:
						hint_2_timer.start()
				"medium":
					hint_status_bar.position = hint_2_mark.position
					if hint_2_lock and hint_2_overlay:
						hint_2_lock.modulate.a = 0
						hint_2_overlay.modulate.a = 0
					if solution_timer and solution_timer.time_left <= 0:
						solution_timer.start()
				"easy":
					hint_status_bar.position = solution_mark.position
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
				# LEVEL CHANGED - RESET HINT PROGRESS AND UI
				current_level = new_level
				_reset_hint_state()
				show_appropriate_container()
				print("Hint: Level updated to ", current_level)

# RESET HINT PROGRESS AND UI STATE WHEN CHANGING LEVELS
func _reset_hint_state():
	hint_progress[current_level] = "hard"
	
	# RESET UI ELEMENTS
	if hint_status_bar:
		hint_status_bar.position = hint_1_mark.position
	
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

func find_level_handler() -> Node:
	# SEARCH THE ENTIRE SCENE TREE FOR THE LEVEL_HANDLER SCRIPT
	var root = get_tree().current_scene
	if not root:
		root = get_tree().root
	
	return _search_for_level_handler(root)

func _search_for_level_handler(node: Node) -> Node:
	if node.get_script():
		var script_path = node.get_script().get_path()
		if "level_handler.gd" in script_path:
			return node
	
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
		if current_diff == "hard" and hint_2_timer and hint_2_timer.time_left <= 0:
			hint_2_timer.start()
		elif current_diff == "medium" and solution_timer and solution_timer.time_left <= 0:
			solution_timer.start()
func hide_hint():
	visible = false



