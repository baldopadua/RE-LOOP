extends CharacterBody2D

var player_directions = GlobalVariables.player_direction
@export var direction: GlobalVariables.player_direction
@export var player_clock_position: int = 0 # Default to 0, nasa top

const angle_per_move := 30 # The that will be added everytime player rotates
var is_moving: bool = false
var tween: Tween
var transition_time = GlobalVariables.transition_time
var object_pos: Marker2D = null
var held_object: object_class = null
var origi_object_pos: Vector2
var is_holding_object : bool = false
var available_object : object_class = null
#var available_interactable_object : object_class = null
var interactable_objects: Array = []
# DETERMINES IF THE DEGREES IS PASOK sa 3,6,9,12 CLOCK TIME
var deg_to_time: Dictionary = {
	0.0: 12,
	360.0: 12,
	-360.0: 12,
	30.0: 12,
	-30.0: 12,
	60.0: 12,
	-60.0: 12,
	90.0: 3,
	-90.0: 3,
	120.0: 3,
	-120.0: 3,
	150.0: 3,
	-150.0: 3,
	180.0: 6,
	-180.0: 6,
	210.0: 6,
	-210.0: 6,
	240.0: 6,
	-240.0: 6,
	270.0: 9,
	-270.0: 9,
	300.0: 9,
	-300.0: 9,
	330.0: 9,
	-330.0: 9,
}
var entered_clock_area: int = 12

# SFX
@onready var time_sfx: Object = $"../time_manip"
@onready var clank_sfx: Object = $"../clank"

# TODO: Change this later to animated sprite
@onready var sprite = $Sprite2D

func _ready() -> void:
	object_pos = get_node("object_position")
	print(type_string(typeof(time_sfx)))

func _input(event: InputEvent) -> void:
	# MOVEMENT round(rad_to_deg(rotation)) < 180.0
	if event.is_action_pressed("move_right") and not is_moving and not GlobalVariables.player_stopped:
		direction = player_directions.CLOCKWISE
		rotate_player()
		GlobalVariables.play_sfx(time_sfx, player_directions.CLOCKWISE)
		GlobalVariables.play_sfx(clank_sfx, player_directions.CLOCKWISE)
	elif event.is_action_pressed("move_left") and not is_moving and not GlobalVariables.player_stopped:
		direction = player_directions.COUNTERCLOCKWISE
		rotate_player()
		GlobalVariables.play_sfx(time_sfx, player_directions.COUNTERCLOCKWISE)
		GlobalVariables.play_sfx(clank_sfx, player_directions.COUNTERCLOCKWISE)
	# MAX TURNS REACHED
	elif (event.is_action_pressed("move_right") or event.is_action_pressed("move_left")) and (round(rad_to_deg(rotation)) == 180.0 or round(rad_to_deg(rotation)) == -180.0) and not is_moving and not GlobalVariables.player_stopped:
		print("MAX TURNS REACHED!")
		
	# OBJECT INTERACTION
	if event.is_action_pressed("interact") and available_object != null and not is_moving:
		item_pick_up()
	# Drop Objects
	elif event.is_action_pressed("drop") and is_holding_object and not is_moving:
		item_drop()
	# Interact with Objects using Tools
	elif event.is_action_pressed("interact") and is_holding_object and interactable_objects != null and not is_moving:
		for obj in interactable_objects:
			if obj.object_name in held_object.usable_targets:
				held_object.interact(obj)
				held_object = null
				is_holding_object = false
				break

func _tween_finished():
	
	# RESET THE SFX PITCH SCALE WHEN REACHING BOTH ENDS
	if round(rad_to_deg(rotation)) == 360.0 or round(rad_to_deg(rotation)) == -360.0 or round(rad_to_deg(rotation)) == 0.0:
		time_sfx.pitch_scale = 1.0
		clank_sfx.pitch_scale = 1.0
	
	# RESET THE ANGLE TO 30
	if round(rad_to_deg(rotation)) == 390.0 and direction == player_directions.CLOCKWISE:
		rotation = deg_to_rad(30.0)
	elif round(rad_to_deg(rotation)) == -390.0 and direction == player_directions.COUNTERCLOCKWISE:
		rotation = deg_to_rad(-30.0)
	
	print(round(rad_to_deg(rotation)))
	
	# CHECKS IF DEGREES IS IN ANOTHER AREA
	if round(rad_to_deg(rotation)) in deg_to_time:
		#print(deg_to_time[round(rad_to_deg(rotation))])
		# KAPAG WALA NA SA PREVIOUS CLOCK AREA ADD CURRENT STATES
		if deg_to_time[round(rad_to_deg(rotation))] != entered_clock_area:
			# INCREMENT/DECREMENT THE STATE OF ALL OBJECTS DEPENDING ON DIRECTION
			for obj in get_parent().get_children():
				# IF OBJECT_CLASS YUNG OBJECT AND MORE THAN OR EQUAL SA 90.0 YUNG NATRAVEL
				if obj is object_class:
					if direction == player_directions.CLOCKWISE and obj.current_state < obj.max_state_threshold: 
						obj.current_state += 1
					elif direction == player_directions.COUNTERCLOCKWISE and obj.current_state > obj.min_state_threshold:  
						obj.current_state -= 1
			# SET THE ENTERED CLOCK AREA TO AREA KUNG NASAN PLAYER
			entered_clock_area = deg_to_time[round(rad_to_deg(rotation))]
		
	for obj in get_parent().get_children():
		if obj is object_class:
			print(obj.name, " STATE: ", obj.current_state)
	tween.kill()
	is_moving = false

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
	if direction == player_directions.CLOCKWISE:
		rotation_tween = rotation + deg_to_rad(angle_per_move)
		sprite.flip_h = false
	else:
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		sprite.flip_h = true
		
	# set the tween
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
func _process(_delta):
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
