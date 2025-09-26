extends Control

var current_level: String = "level_1"  # Default to level_1 level
var connected_level_handler: Node = null
@onready var hint_image = $hint_image
@onready var hint_container_1 = $hint_image/hint_container_1
@onready var hint_container_2 = $hint_image/hint_container_2
@onready var hint_container_3 = $hint_image/hint_container_3
@onready var hint_container_4 = $hint_image/hint_container_4
@onready var plooy_hint = $hint_image/plooy_hint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start plooy animation
	if plooy_hint:
		plooy_hint.play()
	
	# Initial connection attempt
	connect_to_level_handler()
	
	# Set up a timer to periodically check for new level handlers and update current level
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_check_for_level_handler)
	timer.autostart = true
	add_child(timer)

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
				current_level = new_level
				print("Hint: Level updated to ", current_level)

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
	hint_image.visible = true
	print("Hint: Showing hint for current level: ", current_level)
	show_appropriate_container()
	
	# Ensure plooy is playing
	if plooy_hint:
		plooy_hint.play()

func hide_hint():
	visible = false
	hint_image.visible = false

func show_appropriate_container():
	# Hide all containers first
	hint_container_1.visible = false
	hint_container_2.visible = false
	hint_container_3.visible = false
	hint_container_4.visible = false
	
	# Show the appropriate container based on current level
	match current_level:
		"level_1":
			hint_container_1.visible = true
		"level_2":
			hint_container_2.visible = true
		"level_3":
			hint_container_3.visible = true
		"level_4":
			hint_container_4.visible = true
		_:
			# Default to level_1 if unknown level
			hint_container_1.visible = true
		
