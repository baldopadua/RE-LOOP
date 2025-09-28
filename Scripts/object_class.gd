extends Area2D
class_name object_class

@export var object_name: String = "Generic Object"
@export var object_type: GlobalVariables.object_types
@export var is_pickupable: bool = true
@export var is_enterable: bool = false
@export var usable_targets: Array[String] = [] 
@export var max_state_threshold: int
@export var min_state_threshold: int
@export var current_state: int
var is_reachable: bool = false
var player_char: CharacterBody2D = null
var player_arrow_owner: CharacterBody2D
var glow_light: PointLight2D = null
var hover_text_label: RichTextLabel = null
var interact_text_label: RichTextLabel = null
var is_text_visible: bool = false

func _ready():
	print(object_name + " instantiated!")
	# Wait a frame to ensure all nodes are ready, then get reference to text labels
	call_deferred("setup_text_labels")

# Setup text labels after scene is ready
func setup_text_labels():
	if has_node("hover_text"):
		hover_text_label = get_node("hover_text")
		print("Found hover_text for: ", object_name)
		hover_text_label.visible = false
		# Don't override modulate - keep the GUI-set color
		hover_text_label.text = ""
	else:
		print("No hover_text found for: ", object_name)
		
	if has_node("interact_text"):
		interact_text_label = get_node("interact_text")
		print("Found interact_text for: ", object_name)
		interact_text_label.visible = false
		# Don't override modulate - keep the GUI-set color
		interact_text_label.text = ""
	else:
		print("No interact_text found for: ", object_name)

# Function to show hover text
func show_hover_text(text: String = ""):
	print("show_hover_text called for ", object_name, " with text: ", text)
	if not hover_text_label and has_node("hover_text"):
		hover_text_label = get_node("hover_text")
	
	if hover_text_label:
		if text != "":
			hover_text_label.text = text
		hover_text_label.visible = true
		# Don't override modulate - keep the GUI-set color
		is_text_visible = true
		print("Hover text shown: ", hover_text_label.text)
	else:
		print("No hover_text_label available for ", object_name)

# Function to show interact text
func show_interact_text(text: String = ""):
	print("show_interact_text called for ", object_name, " with text: ", text)
	if not interact_text_label and has_node("interact_text"):
		interact_text_label = get_node("interact_text")
	
	if interact_text_label:
		if text != "":
			interact_text_label.text = text
		interact_text_label.visible = true
		# Don't override modulate - keep the GUI-set color (red)
		is_text_visible = true
		print("Interact text shown: ", interact_text_label.text)
	else:
		print("No interact_text_label available for ", object_name)

# Legacy function for backward compatibility - now uses hover_text
func show_text(text: String = ""):
	show_hover_text(text)

# Function to hide all text
func hide_text():
	if hover_text_label:
		hover_text_label.visible = false
	if interact_text_label:
		interact_text_label.visible = false
	is_text_visible = false
	print("All text hidden for: ", object_name)

# Tinanggal ko muna ung static type ng body, but it should be CharacteerBody2D
# Nag e-error kasi kapag naka staticly typed ewan pa kung bakit
# Both body_entered tsaka body_exit ko tinanggal


func _on_body_exited(body) -> void:
	handle_body_exited(body)
	
func handle_body_exited(body):
	
	# IF NOT PLAYER SCENE OR BEING PICKED UP DISABLE BODY ENTER AND EXIT
	if body != player_char:
		return
	
	print("BODY EXITED: %s for object: %s" % [str(body), object_name])
	
	# Tool behavior if out of rangea
	if object_type == GlobalVariables.object_types.TOOL:
		is_reachable = false
		player_char = null
		body.available_object = null
		#print("Out of Object Range")
		
		# DELETE POINTLIGHT
		if glow_light:
			glow_light.queue_free()
			glow_light = null
		
	# Interatable behavior if out of range
	if object_type == GlobalVariables.object_types.NONTOOL:
		is_reachable = false
		player_char = null
		if body.interactable_objects.has(self):
			body.interactable_objects.erase(self)
		
		# Hide text when exiting area
		print("Calling on_hover_exit for: ", object_name)
		on_hover_exit()  # Add this line back!
		
		# DELETE POINTLIGHT for enterable objects
		if is_enterable and glow_light:
			glow_light.queue_free()
			glow_light = null

func _on_body_entered(body) -> void:
	handle_body_entered(body)

func handle_body_entered(body):
	
	# IF NOT PLAYER SCENE OR BEING PICKED UP DISABLE BODY ENTER AND EXIT
	if body.name != "PlayerScene":
		return
	
	print("BODY ENTERED: %s for object: %s" % [str(body), object_name])
	
	# PICKING UP THINGS
	if is_pickupable and not body.is_holding_object and object_type == GlobalVariables.object_types.TOOL:
		#print("Player can pick up %s" % object_name)
		
		# CREATE POINT LIGHT (OLD METHOD FOR PICKUPABLES)
		glow_light = PointLight2D.new()
		glow_light.position = Vector2(0, 0)

		# CREATE GRADIENT
		var gradient = Gradient.new()
		gradient.set_color(0, Color.YELLOW)
		gradient.set_color(1, Color.TRANSPARENT)
		gradient.offsets[1] = 0.5

		# CREATE TEXTURE FROM GRADIENT
		var gradient_texture = GradientTexture2D.new()
		gradient_texture.gradient = gradient
		gradient_texture.fill = GradientTexture2D.FILL_RADIAL
		gradient_texture.fill_from = Vector2(0.5, 0.5)

		# ASSIGN TO LIGHT
		glow_light.texture = gradient_texture
		glow_light.energy = 1.5

		add_child(glow_light)
		
		is_reachable = true
		player_char = body
		body.available_object = self
		
	# INTERACTING WHILE CARRYING PICKUPABLE THINGS
	if not is_pickupable and body.is_holding_object and object_type == GlobalVariables.object_types.NONTOOL:
		#print("%s is interactable" % object_name)
		is_reachable = true
		player_char = body
		#body.available_interactable_object = self
		body.interactable_objects.append(self)
		#print(body.interactable_objects)

	# INTERACTING WITH NON-PICKUPABLE OBJECTS WHEN NOT HOLDING ANYTHING (for lobby entrances)
	if not is_pickupable and not body.is_holding_object and object_type == GlobalVariables.object_types.NONTOOL:
		print("Processing non-pickupable interaction for: ", object_name)
		# Always set reachable and player_char for proper cleanup on exit
		is_reachable = true
		player_char = body
		
		# Check if this is a level entrance and if it's accessible
		if is_enterable:
			var level_number = get_level_number_from_name()
			var level_handler = get_level_handler()
			
			print("Level entrance detected - Level: ", level_number, " Handler found: ", level_handler != null)
		
		body.interactable_objects.append(self)
		print("Calling on_hover_enter for: ", object_name)
		on_hover_enter()  # Add this line back!
		  
		
		# ADD GLOW for enterable objects when player enters area
		if is_enterable:
			# Check if this level is completed to determine glow color
			var level_number = get_level_number_from_name()
			var level_handler = get_level_handler()
			
			if level_handler and level_number > 0 and level_handler.completed_levels.has(level_number):
				# Green glow for completed levels
				create_glow_light_to_lobby(Color.GREEN)
			elif level_handler and is_level_accessible(level_number, level_handler):
				# Yellow glow for accessible but incomplete levels
				create_glow_light_to_lobby(Color.YELLOW)
			else:
				# Red glow for locked levels
				create_glow_light_to_lobby(Color.RED)

func is_level_accessible(level_number: int, level_handler) -> bool:
	if not level_handler:
		return false
		
	match level_number:
		1:
			# Level 1 is always accessible
			return true
		2:
			# Level 2 requires Level 1 to be completed
			return level_handler.completed_levels.has(1)
		3:
			# Level 3 requires Level 1 AND Level 2 to be completed
			return level_handler.completed_levels.has(1) and level_handler.completed_levels.has(2)
		4:
			# Level 4 requires Level 1, 2, AND 3 to be completed
			return level_handler.completed_levels.has(1) and level_handler.completed_levels.has(2) and level_handler.completed_levels.has(3)
		_:
			return false

func get_level_number_from_name() -> int:
	var node_name = name  # Use the node's name instead of object_name
	if "enter_1" in node_name:
		return 1
	elif "enter_2" in node_name:
		return 2
	elif "enter_3" in node_name:
		return 3
	elif "enter_4" in node_name:
		return 4
	return 0

func get_level_handler():
	# First check if it's a direct child of this object
	var handler = get_node_or_null("LevelHandler")
	if handler:
		return handler
	
	# Try multiple possible paths to find the level handler
	var possible_paths = [
		"CanvasLayer/LevelHandler",
		"../CanvasLayer/LevelHandler", 
		str(get_parent().get_path()) + "/CanvasLayer/LevelHandler"
	]
	
	for path in possible_paths:
		handler = get_node_or_null(path)
		if handler:
			return handler
	
	# If not found, try to search in the scene tree
	var current_scene = get_tree().current_scene
	if current_scene:
		handler = current_scene.find_child("LevelHandler", true, false)
		return handler
	
	return null

func set_level_completion_visual(is_completed: bool):
	# Change sprite color - use the correct node name from the scene
	if has_node("Sprite2D2"):
		var sprite = $Sprite2D2
		var level_number = get_level_number_from_name()
		var level_handler = get_level_handler()
		
		if is_completed:
			sprite.modulate = Color.GREEN  # Make sprite green when completed
		elif level_handler and is_level_accessible(level_number, level_handler):
			sprite.modulate = Color.WHITE  # Keep original color when accessible but not completed
		else:
			sprite.modulate = Color.DARK_GRAY  # Make sprite dark gray when locked
	elif has_node("item_sprite"):  # Fallback for other objects
		var sprite = $item_sprite
		var level_number = get_level_number_from_name()
		var level_handler = get_level_handler()
		
		if is_completed:
			sprite.modulate = Color.GREEN
		elif level_handler and is_level_accessible(level_number, level_handler):
			sprite.modulate = Color.WHITE
		else:
			sprite.modulate = Color.DARK_GRAY

func create_glow_light_to_lobby(color: Color = Color.YELLOW):
	# Remove existing glow light first
	if glow_light:
		glow_light.queue_free()
		glow_light = null
		
	glow_light = PointLight2D.new()
	glow_light.position = Vector2(0, 0)

	# CREATE GRADIENT with proper color intensity
	var gradient = Gradient.new()
	gradient.set_color(0, Color(color.r, color.g, color.b, 1.0))  
	gradient.set_color(1, Color(color.r, color.g, color.b, 0.0)) 
	gradient.offsets = [0.0, 1.0] 

	# CREATE TEXTURE FROM GRADIENT - SMALLER SIZE
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.width = 64  # Reduced from 128
	gradient_texture.height = 64  # Reduced from 128

	# ASSIGN TO LIGHT with smaller scale and lower energy
	glow_light.texture = gradient_texture
	glow_light.energy = 1.0  # Reduced from 2.0
	glow_light.texture_scale = 0.8  # Reduced from 2.0
	glow_light.color = color

	add_child(glow_light)
	
func set_flipped(flip: bool):
	if has_node("item_sprite"):   
		$item_sprite.flip_h = flip

func get_obj_name():
	return object_name

# Function to handle hover behavior
func on_hover_enter():
	# Override in extended classes for specific hover behavior
	pass

# Function to handle hover exit
func on_hover_exit():
	# Override in extended classes for specific hover exit behavior
	if is_text_visible:
		hide_text()


