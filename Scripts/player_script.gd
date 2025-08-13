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
var previous_clock_area: int = 12
var prev_deg: float = 0.0
var available_object_last_pos: Vector2
var moves: int = 0

# MAPS
@onready var map1: TileMapLayer = $"../map1"
@onready var map2: TileMapLayer = $"../map2"
@onready var map3: TileMapLayer = $"../map3"
@onready var map4: TileMapLayer = $"../map4"
var maps_dict: Dictionary

# SFX
@onready var time_sfx: Object = $"../time_manip"
@onready var clank_sfx: Object = $"../clank"
@onready var bell_sfx: Object = $"../bell"
@onready var shwoop_sfx: Object = $"../shwoop"
@onready var reverse_ahh_sfx: Object = $"../cinematic_ah"
@onready var tick_tock_sfx: Object = $"../tick_tock"

# Changed from Sprite2D to AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D
@onready var object_drop_position := $object_drop_position
var time_indicator: AnimatedSprite2D

func _ready() -> void:
	if GlobalVariables.is_restarting:
		GlobalVariables.is_restarting = false
		GlobalVariables.restart_level_sfx_vfx([shwoop_sfx, tick_tock_sfx, reverse_ahh_sfx])
		# PLAY RESTART SFX AND CUTSCENES
	object_pos = get_node("object_position")
	maps_dict = {
		12: map1,
		3: map2,
		6: map3,
		9: map4
	}
	sprite.play("idle")
	time_indicator = get_parent().get_parent().get_parent().get_node("CanvasLayerGameUi").get_node("game_ui_elements").get_node("ui_frame").get_node("time_indicator")
	time_indicator.animation = "clockwise_time_indicator"
	time_indicator.frame = moves

func _input(event: InputEvent) -> void:
	# MOVEMENT round(rad_to_deg(rotation)) < 180.0
	if event.is_action_pressed("move_right") and not is_moving and not GlobalVariables.player_stopped:
		direction = player_directions.CLOCKWISE
		prev_deg = round(rad_to_deg(rotation))
		rotate_player()
		GlobalVariables.play_sfx(time_sfx, player_directions.CLOCKWISE)
		GlobalVariables.play_sfx(clank_sfx, player_directions.CLOCKWISE)
	elif event.is_action_pressed("move_left") and not is_moving and not GlobalVariables.player_stopped:
		prev_deg = round(rad_to_deg(rotation))
		direction = player_directions.COUNTERCLOCKWISE
		rotate_player()
		GlobalVariables.play_sfx(time_sfx, player_directions.COUNTERCLOCKWISE)
		GlobalVariables.play_sfx(clank_sfx, player_directions.COUNTERCLOCKWISE)
		
	# OBJECT INTERACTION AND DROP
	if event.is_action_pressed("interact"):
		# PICK UP ITEMS
		if available_object != null and not is_moving:
			item_pick_up()
			sprite.play("idle")
		# TRY INTERACTING WITH OBJECTS
		elif is_holding_object and interactable_objects.size() != 0 and not is_moving:
			for obj in interactable_objects:
				if obj.object_name in held_object.usable_targets:
					held_object.interact(obj)
					held_object = null
					is_holding_object = false
					sprite.play("idle")
					break
		# DROP ITEMS
		elif is_holding_object and not is_moving:
			item_drop()
			sprite.play("idle")
		
	# Interact with Objects using Tools
	elif event.is_action_pressed("interact") and is_holding_object and interactable_objects != null and not is_moving:
		for obj in interactable_objects:
			if obj.object_name in held_object.usable_targets:
				held_object.interact(obj)
				held_object = null
				is_holding_object = false
				sprite.play("idle")
				break

func _tween_finished():
	# RESET THE SFX PITCH SCALE WHEN REACHING BOTH ENDS
	if round(rad_to_deg(rotation)) == 360.0 or round(rad_to_deg(rotation)) == -360.0 or round(rad_to_deg(rotation)) == 0.0:
		time_sfx.pitch_scale = 1.0
		clank_sfx.pitch_scale = 1.0
	
	# SWITCH THE MONOLITH
	# INITIAL VALUE NO ENERGY and # POSITIVE MEANS CLOCKWISE
	if GlobalVariables.is_looping:
		if moves >= 0:
			time_indicator.animation = "clockwise_time_indicator"
			time_indicator.frame = moves
			time_indicator.pause()
		# ANYTHING LOWER THAN 0, NEGATIVE, MEANS COUNTERCLOCKWISE
		else:
			time_indicator.animation = "counterclockwise_time_indicator"
			time_indicator.frame = abs(moves)
			time_indicator.pause()
	
	# RESET THE LEVEL IF LOOPED
	if (round(rad_to_deg(rotation)) == 0.0 or round(rad_to_deg(rotation)) == 360.0 or round(rad_to_deg(rotation)) == -360.0) and (prev_deg == 330.0 or prev_deg == -330.0) and GlobalVariables.is_looping:
		GlobalVariables.is_restarting = true
		GlobalVariables.restart_level(get_parent().get_parent())
	
	# RESET THE ANGLE TO 30
	if round(rad_to_deg(rotation)) == 390.0 and direction == player_directions.CLOCKWISE:
		rotation = deg_to_rad(30.0)
	elif round(rad_to_deg(rotation)) == -390.0 and direction == player_directions.COUNTERCLOCKWISE:
		rotation = deg_to_rad(-30.0)
	
	#print(round(rad_to_deg(rotation)))
	
	# CHECKS IF DEGREES IS IN ANOTHER AREA
	if round(rad_to_deg(rotation)) in deg_to_time and GlobalVariables.is_looping:
		#print(deg_to_time[round(rad_to_deg(rotation))])
		
		# KAPAG WALA NA SA PREVIOUS CLOCK AREA ADD CURRENT STATES
		if deg_to_time[round(rad_to_deg(rotation))] != entered_clock_area:
			# INCREMENT/DECREMENT THE STATE OF ALL OBJECTS DEPENDING ON DIRECTION
			for obj in get_parent().objects:
				# IF OBJECT_CLASS AND IS IN THE LEVEL SCENE NOT PLAYER
				if obj is object_class and (obj.get_parent().name == "level_2" or obj.get_parent().name != "object_position"):
					#print("PARENT: ", obj.get_parent())
					if direction == player_directions.CLOCKWISE and obj.current_state < obj.max_state_threshold: 
						obj.current_state += 1
					elif direction == player_directions.COUNTERCLOCKWISE and obj.current_state > obj.min_state_threshold:  
						obj.current_state -= 1
			# SET THE ENTERED CLOCK AREA TO AREA KUNG NASAN PLAYER
			maps_dict[entered_clock_area].visible = false
			previous_clock_area = entered_clock_area
			entered_clock_area = deg_to_time[round(rad_to_deg(rotation))]
			maps_dict[entered_clock_area].visible = true
			
	
	#for obj in get_parent().get_children():
		#if obj is object_class:
			#print(obj.name, " STATE: ", obj.current_state)
	
	tween.kill()
	is_moving = false
	sprite.play("idle")

# Movement of Player
func rotate_player():
	sprite.play("walk")
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
		moves += 1
	else:
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		sprite.flip_h = true
		moves -= 1
		
	# set the tween
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
func _process(_delta):
	pass

# Reparent the object to mark2D of the player
func _deferred_reparent(obj) -> void:
	obj.reparent(object_pos)
	
	# TWEEN TO ADD BOUNCE WHEN PICKING UP
	var tween_pickup = create_tween()
	var screen_center = Vector2.ZERO   
	tween_pickup.tween_property(obj, "position", screen_center, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween_pickup.finished
	tween_pickup.kill()
	 
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
			
func item_pick_up() -> void:
	if not is_holding_object and available_object.is_reachable and not is_moving:
		# Defer/Delay the reparenting to avoid error
		# during physics callback or something
		call_deferred("_deferred_reparent", available_object)
		
		# The player is currently holding an object
		is_holding_object = true
		print("Object picked up: " + available_object.object_name)

func item_drop() -> void:
	# reparent to parent of this player which is the main game
	if held_object and not is_moving:
		
		# TWEEN TO ADD BOUNCE WHEN DROPPING DOWN
		var tween_pickup = create_tween()
		var screen_center = Vector2(0,50.0)  
		tween_pickup.tween_property(held_object, "position", screen_center, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await tween_pickup.finished
		tween_pickup.kill()
			
		held_object.reparent(get_parent())
		held_object = null
		is_holding_object = false
		print("Object dropped")
		interactable_objects.clear()
