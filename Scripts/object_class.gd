extends Area2D
class_name object_class

@warning_ignore("unused_signal")
signal rotate_object(direction)

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
@onready var outline_shader = preload("res://Shaders/object_outline.gdshader")
var mat = ShaderMaterial.new()
var shader_sprite = null

# TOOL STACK ARRAY (e.g.: Stacking Rocks)
var tool_stack: Array = []
var is_stacked: bool = false
var stack_base_object: object_class = null

func _ready():
	print(object_name + " instantiated!")
	call_deferred("setup_text_labels")
	
	# FIND SPRITE2D or ANIMATEDSPRITE2D
	if object_type == GlobalVariables.object_types.TOOL:
		for child in get_children():
			if child is Sprite2D or child is AnimatedSprite2D:
				mat.shader = outline_shader
				shader_sprite = child
				break
	configure_collision_for_stacking()

# CONFIGURE THE OBJECT'S COLLISION SHAPE FOR PROPER STACKING BEHAVIOR
func configure_collision_for_stacking():
	if has_node("CollisionShape2D"):
		var collision = get_node("CollisionShape2D")
		# Ensure collision is enabled by default
		collision.disabled = false

# WHEN AN OBJECT IS ADDED TO A STACk
func join_stack(base_object):
	is_stacked = true
	stack_base_object = base_object
	
	# Adjust collision to avoid physics issues when stacked
	if has_node("CollisionShape2D"):
		var collision = get_node("CollisionShape2D")
		collision.disabled = true

# WHEN AN OBJECT IS REMOVED FROM A STACK
func leave_stack():
	is_stacked = false
	stack_base_object = null
	
	if has_node("CollisionShape2D"):
		var collision = get_node("CollisionShape2D")
		collision.disabled = false

# ADD AN OBJECT TO THIS OBJECT'S STACK
func add_to_stack(object_to_add):
	if object_to_add is object_class:
		tool_stack.push_back(object_to_add)
		object_to_add.join_stack(self)
		# ENSURE ALL OBJECTS IN THE STACK ARE PICKUPABLE AFTER DROP
		for obj in tool_stack:
			obj.is_pickupable = true
		return true
	return false

# REMOVE AN OBJECT FROM THIS OBJECT'S STACK
func remove_from_stack():
	if tool_stack.size() > 0:
		var popped = tool_stack.pop_back()
		popped.leave_stack()
		# ENSURE ALL REMAINING OBJECTS IN THE STACK ARE PICKUPABLE
		for obj in tool_stack:
			obj.is_pickupable = true
		return popped
	return null


# Setup text labels after scene is ready
func setup_text_labels():
	if has_node("hover_text"):
		hover_text_label = get_node("hover_text")
		hover_text_label.visible = false
		hover_text_label.text = ""
	

	if has_node("interact_text"):
		interact_text_label = get_node("interact_text")
		interact_text_label.visible = false
		interact_text_label.text = ""
	
# FUNCTION TO SHOW HOVER TEXT
func show_hover_text(text: String = ""):
	if not hover_text_label and has_node("hover_text"):
		hover_text_label = get_node("hover_text")
	
	if hover_text_label:
		if text != "":
			hover_text_label.text = text
		hover_text_label.visible = true
		
		is_text_visible = true

# FUNCTION TO SHOW INTERACT TEXT
func show_interact_text(text: String = ""):
	print("show_interact_text called for ", object_name, " with text: ", text)
	if not interact_text_label and has_node("interact_text"):
		interact_text_label = get_node("interact_text")
	
	if interact_text_label:
		if text != "":
			interact_text_label.text = text
		interact_text_label.visible = true
		
		is_text_visible = true
		print("Interact text shown: ", interact_text_label.text)
	

func show_text(text: String = ""):
	show_hover_text(text)

# Function to hide all text
func hide_text():
	if hover_text_label:
		hover_text_label.visible = false
	if interact_text_label:
		interact_text_label.visible = false
	is_text_visible = false
	
# Tinanggal ko muna ung static type ng body, but it should be CharacteerBody2D
# Nag e-error kasi kapag naka staticly typed ewan pa kung bakit
# Both body_entered tsaka body_exit ko tinanggal


func _on_body_exited(body) -> void:
	handle_body_exited(body)
	
func handle_body_exited(body):
	# IF NOT PLAYER SCENE OR BEING PICKED UP DISABLE BODY ENTER AND EXIT
	if body != player_char:
		return
	
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
			
		# REMOVE OUTLINE
		shader_sprite.material = null
		
	# Interatable behavior if out of range
	if object_type == GlobalVariables.object_types.NONTOOL:
		is_reachable = false
		player_char = null
		if body.interactable_objects.has(self):
			body.interactable_objects.erase(self)
		
		# Hide text when exiting area
		on_hover_exit() # Add this line back!
		
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
	
	# If this object is part of a stack and not the base object,
	# redirect interaction to the base stack object
	if is_stacked and stack_base_object != null:
		stack_base_object.handle_body_entered(body)
		return
	
	# PICKING UP THINGS
	if is_pickupable and not body.is_holding_object and object_type == GlobalVariables.object_types.TOOL:
		#print("Player can pick up %s" % object_name)
		# ADD OBJECT OUTLINE
		shader_sprite.material = mat
		
		print(shader_sprite.material)
		
		## CREATE POINT LIGHT (OLD METHOD FOR PICKUPABLES)
		#glow_light = PointLight2D.new()
		#glow_light.position = Vector2(0, 0)
#
		## CREATE GRADIENT
		#var gradient = Gradient.new()
		#gradient.set_color(0, Color.YELLOW)
		#gradient.set_color(1, Color.TRANSPARENT)
		#gradient.offsets[1] = 0.5
#
		## CREATE TEXTURE FROM GRADIENT
		#var gradient_texture = GradientTexture2D.new()
		#gradient_texture.gradient = gradient
		#gradient_texture.fill = GradientTexture2D.FILL_RADIAL
		#gradient_texture.fill_from = Vector2(0.5, 0.5)
#
		## ASSIGN TO LIGHT
		#glow_light.texture = gradient_texture
		#glow_light.energy = 1.5
#
		#add_child(glow_light)
		
		is_reachable = true
		player_char = body
		body.available_object = self
		
		# Emit signal that player is near an object to play animation
		body.near_obj.emit()
		
	# INTERACTING WHILE CARRYING PICKUPABLE THINGS
	if not is_pickupable and body.is_holding_object and object_type == GlobalVariables.object_types.NONTOOL:
		#print("%s is interactable" % object_name)
		is_reachable = true
		player_char = body
		#body.available_interactable_object = self
		body.interactable_objects.append(self)
	
		# If this nontool is usable for the held object
		if self.object_name in body.held_object.usable_targets:
			body.near_obj.emit()

	# INTERACTING WITH NON-PICKUPABLE OBJECTS WHEN NOT HOLDING ANYTHING (for lobby entrances)
	if not is_pickupable and not body.is_holding_object and object_type == GlobalVariables.object_types.NONTOOL:
		# Always set reachable and player_char for proper cleanup on exit
		is_reachable = true
		player_char = body

		body.interactable_objects.append(self)
		on_hover_enter()
		  
		# ADD GLOW for enterable objects when player enters area
		if is_enterable:
			# Check if this level is completed to determine glow color
			var level_number = get_level_number_from_name()
			var level_handler = get_level_handler()
			
			if level_handler and level_number > 0:
				if level_handler.completed_levels.has(level_number):
					# Green glow for completed levels
					create_glow_light_to_lobby(Color.GREEN)
				elif is_level_accessible(level_number, level_handler):
					# Yellow glow for accessible but incomplete levels
					create_glow_light_to_lobby(Color.YELLOW)
				else:
					# Red glow for locked levels
					create_glow_light_to_lobby(Color.RED)
			else:
				# Default red glow if no level handler or invalid level
				create_glow_light_to_lobby(Color.RED)

func is_level_accessible(level_number: int, level_handler) -> bool:
	if not level_handler:
		print("No level handler provided")
		return false
	
	match level_number:
		1:
			# Level 1 is always accessible
			return true
		2:
			# Level 2 requires Level 1 to be completed
			# var accessible = level_handler.completed_levels.has(1)
			# return accessible
			return true
		3:
			# Level 3 requires Level 1 AND Level 2 to be completed
			# var accessible = level_handler.completed_levels.has(1) and level_handler.completed_levels.has(2)
			# return accessible
			return true
		4:
			# Level 4 requires Level 1, 2, AND 3 to be completed
			# var accessible = level_handler.completed_levels.has(1) and level_handler.completed_levels.has(2) and level_handler.completed_levels.has(3)
			# return accessible
			return true
		5:
			# Level 5 requires previous levels to be completed
			# var accessible = level_handler.completed_levels.has(1) and level_handler.completed_levels.has(2) and level_handler.completed_levels.has(3) and level_handler.completed_levels.has(4)
			# return accessible
			return true
		6:
			# Level 6 requires previous levels to be completed
			# var accessible = level_handler.completed_levels.has(5)
			# return accessible
			return true
		7:
			# Level 7 requires previous levels to be completed
			return true
		8:
			# Level 8 requires previous levels to be completed
			return true
		9:
			# Level 9 requires previous levels to be completed
			return true
		10:
			# Level 10 requires previous levels to be completed
			return true
		11:
			# Level 11 requires previous levels to be completed
			return true
		12:
			# Level 12 requires previous levels to be completed
			return true
		_:
			print("Level ", level_number, " not implemented yet")
			return false

func get_level_number_from_name() -> int:
	var node_name = name # Use the node's name instead of object_name
	if "enter_1" in node_name:
		return 1
	elif "enter_2" in node_name:
		return 2
	elif "enter_3" in node_name:
		return 3
	elif "enter_4" in node_name:
		return 4
	elif "enter_5" in node_name:
		return 5
	elif "enter_6" in node_name:
		return 6
	elif "enter_7" in node_name:
		return 7
	elif "enter_8" in node_name:
		return 8
	elif "enter_9" in node_name:
		return 9
	elif "enter_10" in node_name:
		return 10
	elif "enter_11" in node_name:
		return 11
	elif "enter_12" in node_name:
		return 12
	return 0

func get_level_handler():
	# For lobby entrance objects, try the direct parent path first
	var handler = get_node_or_null("../CanvasLayer/LevelHandler")
	if handler:
		return handler
	
	# Try finding it through the parent scene directly
	var parent_scene = get_parent()
	if parent_scene and parent_scene.has_node("CanvasLayer/LevelHandler"):
		handler = parent_scene.get_node("CanvasLayer/LevelHandler")
		return handler
	
	# If not found, try to search in the scene tree
	var current_scene = get_tree().current_scene
	if current_scene:
		handler = current_scene.find_child("LevelHandler", true, false)
		if handler:
			return handler
	
	print("No level handler found!")
	return null

func set_level_completion_visual(is_completed: bool):
	# Change sprite color - use the correct node name from the scene
	var level_number = get_level_number_from_name()
	var level_handler = get_level_handler()
	
	
	if has_node("Sprite2D2"):
		var sprite = $Sprite2D2
		
		if is_completed:
			sprite.modulate = Color.GREEN
		elif level_handler and is_level_accessible(level_number, level_handler):
			sprite.modulate = Color.WHITE
		else:
			sprite.modulate = Color.DARK_GRAY
	elif has_node("item_sprite"):
		var sprite = $item_sprite
		
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
	gradient_texture.width = 64
	gradient_texture.height = 64
	# ASSIGN TO LIGHT with smaller scale and lower energy
	glow_light.texture = gradient_texture
	glow_light.energy = 1.0
	glow_light.texture_scale = 0.8
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
