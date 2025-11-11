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

	# Define required previous levels per level_number.
	# An empty array means the level is always accessible.
	var requirements := {
		1: [],
		2: [1],
		3: [1, 2],
		4: [1, 2, 3],
		5: [1, 2, 3, 4],
		6: [1, 2, 3, 4, 5],
		7: [1, 2, 3, 4, 5, 6],
		8: [1, 2, 3, 4, 5, 6, 7],
		9: [1, 2, 3, 4, 5, 6, 7, 8],
		10: [1, 2, 3, 4, 5, 6, 7, 8, 9],
		11: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
		12: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
	}

	if not requirements.has(level_number):
		print("Level ", level_number, " not implemented yet")
		return false

	for req_level in requirements[level_number]:
		if not level_handler.completed_levels.has(req_level):
			return false

	return true

func get_level_number_from_name() -> int:
	# convert StringName to String to allow indexing/substr operations
	var node_name_str := str(name)
	# If name starts with "enter_", parse the remainder as an integer (handles enter_10, enter_11, enter_12 correctly)
	if node_name_str.begins_with("enter_"):
		var num_str := node_name_str.substr(6, node_name_str.length() - 6) # substring after "enter_"
		if num_str.is_valid_int():
			return int(num_str)
	# Fallback: extract trailing digits (robust for other naming)
	var digits := ""
	for i in range(node_name_str.length() - 1, -1, -1):
		var c := node_name_str.substr(i, 1)
		# use ASCII comparison to detect digits (avoid non-existent is_digit())
		if c >= "0" and c <= "9":
			digits = c + digits
		else:
			break
	if digits != "":
		return int(digits)
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
	glow_light.position = Vector2.ZERO

	# CREATE GRADIENT with proper color intensity
	var gradient = Gradient.new()
	gradient.set_color(0, Color(color.r, color.g, color.b, 1.0))
	gradient.set_color(1, Color(color.r, color.g, color.b, 0.0))
	gradient.offsets = [0.0, 1.0]

	# CREATE TEXTURE FROM GRADIENT (radial)
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)

	# Determine square texture size from CollisionShape2D if available
	var collision_node = get_node_or_null("CollisionShape2D")
	var size_px = 64.0
	if collision_node and collision_node.shape:
		var s = collision_node.shape
		var base_dim = 64.0
		# For capsule: use diameter (2 * radius) so glow stays circular, not stretched along capsule height
		if s is CapsuleShape2D:
			var radius = s.radius
			base_dim = radius * 2.0
		# CircleShape2D: diameter
		elif s.has_property("radius"):
			var r = s.radius
			base_dim = r * 2.0
		# Rectangle-like: take the smaller side to create a circle that fits inside the rect (avoid elongated glow)
		elif s.has_property("extents"):
			var ext = s.extents
			base_dim = min(ext.x * 2.0, ext.y * 2.0)
		else:
			base_dim = 64.0
		# add padding so glow isn't clipped
		var padding := 1.3
		size_px = max(8.0, ceil(base_dim * padding))
	else:
		size_px = 64.0

	# Ensure integer sizes and square texture for perfect circle
	var tex_size = int(size_px)
	gradient_texture.width = tex_size
	gradient_texture.height = tex_size

	# ASSIGN TO LIGHT
	glow_light.texture = gradient_texture
	glow_light.energy = 1.0
	glow_light.texture_scale = 1.0
	glow_light.color = color

	# Parent the glow to the CollisionShape2D if it exists so the glow sits at the collider
	if collision_node:
		collision_node.add_child(glow_light)
		glow_light.position = Vector2.ZERO
	else:
		add_child(glow_light)
		glow_light.position = Vector2.ZERO

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
