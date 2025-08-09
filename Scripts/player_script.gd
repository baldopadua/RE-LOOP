extends CharacterBody2D

var player_directions = GlobalVariables.player_direction
@export var direction: GlobalVariables.player_direction

const angle_per_move := 30 # The that will be added everytime player rotates
var is_moving: bool = false
var tween: Tween
var transition_time = GlobalVariables.transition_time
var object_pos: Marker2D = null
var held_object: object_class = null
var origi_object_pos: Vector2
var is_holding_object : bool = false
var available_object : object_class = null
var available_interactable_object : object_class = null

# TODO: Change this later to animated sprite
@onready var sprite = $Sprite2D

func _ready() -> void:
	object_pos = get_node("object_position")

func _input(event: InputEvent) -> void:
	# MOVEMENT
	if event.is_action_pressed("move_right") and round(rad_to_deg(rotation)) < 180.0 and not is_moving:
		direction = player_directions.RIGHT
		rotate_player()
	elif event.is_action_pressed("move_left") and round(rad_to_deg(rotation)) > -180.0 and not is_moving:
		direction = player_directions.LEFT
		rotate_player()
	# MAX TURNS REACHED
	elif (event.is_action_pressed("move_right") or event.is_action_pressed("move_left")) and (round(rad_to_deg(rotation)) == 180.0 or round(rad_to_deg(rotation)) == -180.0) and not is_moving:
		print("MAX TURNS REACHED!")
		
	# OBJECT INTERACTION
	if event.is_action_pressed("interact") and available_object != null:
		item_pick_up()
	# Drop Objects
	elif event.is_action_pressed("drop") and is_holding_object:
		item_drop()
	# Interact with Objects using Tools
	# TODO: Guys baka meron kayo mas efficient solution, may apo na sa tuhod yung if else ko ;-;
	elif event.is_action_pressed("interact") and is_holding_object and available_interactable_object != null:
		print("Interact with this")

func _tween_finished():
	tween.kill()
	is_moving = false
	pass

# Movement of Player
func rotate_player():
	# Asynchrnously start the scene transition here
	# Some async func to start reversing or forwarding time
	
	# Player is moving and create a tween to smooth animation
	is_moving = true
	tween = create_tween()
	
	# Connect tween_finished if not yet connected
	if not tween.is_connected("finished", _tween_finished):
		tween.connect("finished", _tween_finished)
		
	# Rotate based on direction
	var rotation_tween: float
	if direction == player_directions.RIGHT:
		rotation_tween = rotation + deg_to_rad(angle_per_move)
		sprite.flip_h = false
	else:
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		sprite.flip_h = true
		
	# set the tween
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
func _process(delta):
	pass

# Reparent the object to mark2D of the player
func _deferred_reparent(obj) -> void:
	obj.reparent(object_pos)
	obj.position = Vector2.ZERO   
	held_object = obj
	update_held_object_direction()

func update_held_object_direction():
	if held_object:
		# Flip the object's position based on player direction
		if sprite.flip_h:
			object_pos.position.x = -abs(origi_object_pos.x)
			if held_object.has_method("set_flipped"):
				held_object.set_flipped(true)
		else:
			object_pos.position.x = abs(origi_object_pos.x)
			if held_object.has_method("set_flipped"):
				held_object.set_flipped(false)
		
		# Ensure filling bar stays visible when changing direction
		if "on_pickup" in held_object:
			held_object.on_pickup()

func item_pick_up() -> void:
	if not is_holding_object and available_object.is_reachable:
		# Call on_pickup if the object supports it (e.g., bucket)
		if "on_pickup" in available_object:
			available_object.on_pickup()
		# Pause fill if the object supports it (e.g., bucket)
		if "pause_fill" in available_object:
			available_object.pause_fill()
		# Defer/Delay the reparenting to avoid error
		# during physics callback or something
		call_deferred("_deferred_reparent", available_object)
		
		# The player is currently holding an object
		is_holding_object = true
		print("Object picked up: " + available_object.object_name)

func item_drop() -> void:
	# reparent to parent of this player which is the main game
	if held_object:
		# Call on_putdown if the object supports it (e.g., bucket)
		if "on_putdown" in held_object:
			held_object.on_putdown()
		held_object.position = position
		held_object.reparent(get_parent())
		held_object = null
		is_holding_object = false
		print("Object dropped")
