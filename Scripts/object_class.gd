extends Area2D
class_name object_class

# OBJECTS can be
# 1. Picked Up
# 2. Throwables
# 3. Tools

@export var object_name: String = "Generic Object"
@export var is_pickupable: bool = true
@export var usable_targets: Array[String] = [] 
@export var max_state_threshold: int
@export var min_state_threshold: int
@export var current_state: int
var is_reachable: bool = false
var player_char: CharacterBody2D = null
var player_arrow_owner: CharacterBody2D
var glow_light: PointLight2D = null

func _ready():
	print(object_name + " instantiated!")

# Tinanggal ko muna ung static type ng body, but it should be CharacterBody2D
# Nag e-error kasi kapag naka staticly typed ewan pa kung bakit
# Both body_entered tsaka body_exit ko tinanggal

func _on_body_entered(body) -> void:
	handle_body_entered(body)

func handle_body_entered(body):
	#print("BODY: %s" % str(body))
	if body.name != "PlayerScene":
		return
		
	# PICKING UP THINGS
	if is_pickupable and not body.is_holding_object:
		#print("Player can pick up %s" % object_name)
		
		# CREATE POINT LIGHT
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
	if not is_pickupable and body.is_holding_object:
		#print("%s is interactable" % object_name)
		is_reachable = true
		player_char = body
		#body.available_interactable_object = self
		body.interactable_objects.append(self)
		#print(body.interactable_objects)

func _on_body_exited(body) -> void:
	handle_body_exited(body)
	
func handle_body_exited(body):
	#print("BODY: %s" % str(body))
	if body != player_char:
		return
	
	# Tool behavior if out of rangea
	if is_pickupable:
		is_reachable = false
		player_char = null
		body.available_object = null
		#print("Out of Object Range")
		
		# DELETE POINTLIGHT
		if glow_light:
			glow_light.queue_free()
			glow_light = null
		
	# Interatable behavior if out of range
	if not is_pickupable:
		is_reachable = false
		player_char = null
		#body.available_interactable_object = null
		if body.interactable_objects.has(self):
			body.interactable_objects.erase(self)
		#print("Out of Interactable Range")

func set_flipped(flip: bool):
	if has_node("item_sprite"):   
		$item_sprite.flip_h = flip
	
func get_obj_name():
	return object_name
