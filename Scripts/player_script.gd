extends CharacterBody2D 

signal player_finished_moving
@warning_ignore("unused_signal")
signal near_obj

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

# Changed from Sprite2D to AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D
@onready var object_drop_position := $object_drop_position
@onready var object_drop_position2ndlayer := $object_drop_position2ndlayer
@onready var sound_manager = $SoundManager
@onready var level_handler = $"../CanvasLayer/LevelHandler"
var area_handler: Node2D
var time_indicator: AnimatedSprite2D

var ui_handler: Node = null

#	Camera for Cam Shake
#@onready var camera2d : Camera2D = $"../Camera2D"
@onready var camera2d : Camera2D = $Camera2D
var cameraShakeNoise : FastNoiseLite

#	To Intensity of Cam Shake
var to_intensity : float = 0.0

func _ready() -> void:
	if GlobalVariables.is_restarting:
		GlobalVariables.is_restarting = false
		sound_manager.play_reset_level_sfx()
		# PLAY RESTART SFX AND CUTSCENES
	object_pos = get_node("object_position")
	sprite.play("idle")
	# Try to get UiHandler under MainScene
	var root = get_tree().root
	if root.has_node("MainScene/CanvasLayerUi/UiHandler"):
		ui_handler = root.get_node("MainScene/CanvasLayerUi/UiHandler")
	# MAP HANDLER
	area_handler = get_parent().get_node("AreaHandler") 
	
	cameraShakeNoise = FastNoiseLite.new()

func _input(event: InputEvent) -> void:
	# MOVEMENT round(rad_to_deg(rotation)) < 180.0
	if event.is_action_pressed("move_right") and not is_moving and not GlobalVariables.player_stopped:
		direction = player_directions.CLOCKWISE
		prev_deg = round(rad_to_deg(rotation))
		rotate_player()
		sound_manager.adjust_sfx_pitch_scale("time_manip", 0.03)
		sound_manager.adjust_sfx_pitch_scale("clank", 0.03)
		sound_manager.play_sfx("time_manip")
		sound_manager.play_sfx("clank")
	elif event.is_action_pressed("move_left") and not is_moving and not GlobalVariables.player_stopped:
		prev_deg = round(rad_to_deg(rotation))
		direction = player_directions.COUNTERCLOCKWISE
		rotate_player()
		sound_manager.adjust_sfx_pitch_scale("time_manip", -0.03)
		sound_manager.adjust_sfx_pitch_scale("clank", -0.03)
		sound_manager.play_sfx("time_manip")
		sound_manager.play_sfx("clank")
		
	# OBJECT INTERACTION AND DROP
	if event.is_action_pressed("interact"):
		# PICK UP ITEMS
		if available_object != null and not is_moving:
			item_pick_up()
			sprite.play("idle")
		# TRY INTERACTING WITH OBJECTS WHILE HOLDING SOMETHING
		elif is_holding_object and interactable_objects.size() != 0 and not is_moving:
			for obj in interactable_objects:
				if obj.object_name in held_object.usable_targets:
					# Returns true
					if held_object.interact(obj):
						sound_manager.play_sfx("pickup")
						held_object = null
						is_holding_object = false
						sprite.play("idle")
					# Returns false
					else:
						item_drop()
					break
				else:
					item_drop()
		# INTERACT WITH NON-PICKUPABLE OBJECTS (like lobby entrances) WHEN NOT HOLDING ANYTHING
		elif not is_holding_object and interactable_objects.size() != 0 and not is_moving:
			for obj in interactable_objects:
				if not obj.is_pickupable and obj.has_method("interact"):
					obj.interact(obj)  # Pass the object itself
					sound_manager.play_sfx("pickup")
					break
		# DROP ITEMS
		elif is_holding_object and not is_moving:
			item_drop()
			sprite.play("idle")

func _tween_finished():
	# RESET THE SFX PITCH SCALE WHEN REACHING BOTH ENDS
	if round(rad_to_deg(rotation)) == 360.0 or round(rad_to_deg(rotation)) == -360.0 or round(rad_to_deg(rotation)) == 0.0:
		sound_manager.set_sfx_pitch_scale("time_manip", 1.0)
		sound_manager.set_sfx_pitch_scale("clank", 1.0)
	
	# SWITCH THE TIME INDICATOR
	# INITIAL VALUE NO ENERGY and # POSITIVE MEANS CLOCKWISE
	if GlobalVariables.is_looping and ui_handler:
		if moves >= 0:
			ui_handler.set_time_indicator_animation("clockwise_time_indicator")
			if moves > 0:
				for i in range(moves):
					ui_handler.move_time_indicator_frame(true)
			ui_handler.time_indicator.pause()
		else:
			ui_handler.set_time_indicator_animation("counterclockwise_time_indicator")
			if abs(moves) > 0:
				for i in range(abs(moves)):
					ui_handler.move_time_indicator_frame(true)
			ui_handler.time_indicator.pause()
	
	# RESET THE LEVEL IF LOOPED
	#if (round(rad_to_deg(rotation)) == 0.0 or round(rad_to_deg(rotation)) == 360.0 or round(rad_to_deg(rotation)) == -360.0) and (prev_deg == 330.0 or prev_deg == -330.0) and GlobalVariables.is_looping:
		#GlobalVariables.is_restarting = true
		#level_handler.restart_level(get_parent().get_parent())
		#ui_handler.show_last_frame_then_reset()
		
	# RESET LEVEL IN 12TH MOVE
	if (moves == 12 or moves == -12) and GlobalVariables.is_looping:
		GlobalVariables.is_restarting = true
		level_handler.restart_level(get_parent().get_parent())
		ui_handler.show_last_frame_then_reset()
		
	
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
					if direction == player_directions.CLOCKWISE and obj.current_state < obj.max_state_threshold and obj.visible: 
						obj.current_state += 1
						# use signal if there is
						if GlobalVariables.hasSignal(obj, "add_cur_state"):
							obj.add_cur_state.emit(direction)
					elif direction == player_directions.COUNTERCLOCKWISE and obj.current_state > obj.min_state_threshold and obj.visible:  
						obj.current_state -= 1
						if GlobalVariables.hasSignal(obj, "add_cur_state"):
							obj.add_cur_state.emit(direction)
			# SET THE ENTERED CLOCK AREA TO AREA KUNG NASAN PLAYER
			#maps_dict[entered_clock_area].visible = false
			previous_clock_area = entered_clock_area
			entered_clock_area = deg_to_time[round(rad_to_deg(rotation))]
			# UPDATE MAP IN THE AREA HANDLER
			if area_handler:
				area_handler.show_map_for_clock_area(entered_clock_area)
			#maps_dict[entered_clock_area].visible = true
	
	tween.kill()
	is_moving = false
	player_finished_moving.emit()
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
		to_intensity += 0.2
	else:
		rotation_tween = rotation - deg_to_rad(angle_per_move)
		sprite.flip_h = true
		moves -= 1
		to_intensity -= 0.2
		
	# set the tween
	tween.tween_property(self, "rotation", rotation_tween, transition_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	#print(moves)
	
	#	Shakes the camera
	if GlobalVariables.is_looping and (moves > 8 or moves < -8):
		shake_camera(float(moves), to_intensity, 0.5)

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
		var popped_object = null
		if available_object and available_object.object_type == GlobalVariables.object_types.TOOL:
			var stack_size = available_object.tool_stack.size()
			# Find all objects at the 2nd layer position
			var second_layer_indices = []
			for i in range(stack_size):
				var obj = available_object.tool_stack[i]
				if obj.global_position == object_drop_position2ndlayer.global_position:
					second_layer_indices.append(i)
			second_layer_indices.reverse()
			if second_layer_indices.size() > 0:
				# Only pick up objects at the 2nd layer if any exist
				for i in second_layer_indices:
					popped_object = available_object.tool_stack.pop_at(i)
					break
			elif stack_size > 0:
				# Only if there are no objects at the 2nd layer, pick up from the first layer
				popped_object = available_object.tool_stack.pop_back()
			# INCREASE ROTATION OF AVAIL OBJ FIRST
			available_object.position += Vector2(10,0)
			# DECREASE ROTATION OF EVERY OBJ IN STACK
			if available_object.tool_stack.size() > 0:
				for obj in available_object.tool_stack:
					obj.position += Vector2(10,0)
		
		if popped_object:
			popped_object.is_pickupable = false
			held_object = popped_object
			popped_object.reparent(object_pos)	 
			update_held_object_direction()
			print("Object picked up: " + held_object.object_name)
		elif available_object and (not available_object.object_type == GlobalVariables.object_types.TOOL or available_object.tool_stack.size() < 1):
			available_object.is_pickupable = false
			held_object = available_object
			available_object.reparent(object_pos)	 
			update_held_object_direction()
			print("Object picked up: " + held_object.object_name)
		else:
			return
		
		# TWEEN TO ADD BOUNCE WHEN PICKING UP
		var tween_pickup = create_tween()
		var screen_center = Vector2.ZERO   
		tween_pickup.tween_property(held_object, "position", screen_center, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween_pickup.finished
		tween_pickup.kill()
		
		sound_manager.play_sfx("pickup")
		# The player is currently holding an object
		is_holding_object = true

func item_drop() -> void:
	if held_object and not is_moving:
		# GET DROP POSITION - USE THE OBJECT_DROP_POSITION AS BASE
		var drop_position = object_drop_position.global_position
		
		# CHECK IF WE'RE DROPPING ON AN INTERACTABLE OBJECT (like soil)
		if interactable_objects.size() > 0:
			for interactable in interactable_objects:
				if interactable.object_type == GlobalVariables.object_types.NONTOOL:
					if held_object.has_method("interact"):
						var interaction_success = held_object.interact(interactable)
						if interaction_success:
							held_object = null
							is_holding_object = false
							interactable_objects.clear()
							sound_manager.play_sfx("pickup")
							print("Object interacted successfully")
							return
		
		# CHECK IF WE'RE STACKING ON ANOTHER OBJECT (only for pickupable tools)
		if available_object and available_object.object_type == GlobalVariables.object_types.TOOL and available_object.is_pickupable:
			handle_stack_drop(available_object)
		else:
			handle_normal_drop(drop_position)
		
		sound_manager.play_sfx("pickup")
		held_object = null
		is_holding_object = false
		interactable_objects.clear()
		print("Object dropped")

# HANDLE DROPPING AN OBJECT ONTO A STACK
func handle_stack_drop(target_object) -> void:
	if held_object:
		target_object.tool_stack.push_back(held_object)
		var stack_size = target_object.tool_stack.size()
		var stack_position = get_stack_layer_position(stack_size, target_object)
		stack_position += Vector2(randf_range(-2, 2), randf_range(-1, 1))
		var stack_tween = create_tween()
		stack_tween.tween_property(held_object, "global_position", stack_position, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		held_object.is_pickupable = true
		held_object.reparent(get_parent())
		held_object.z_index = target_object.z_index + 1
		adjust_stack_visuals(target_object)
		# Ensure all objects in the stack are pickupable after drop
		for obj in target_object.tool_stack:
			obj.is_pickupable = true

func get_stack_layer_position(stack_size: int, _target_object) -> Vector2:
	if stack_size <= 3:
		return object_drop_position.global_position
	else:
		return object_drop_position2ndlayer.global_position

# HANDLE NORMAL OBJECT DROP TO THE GROUND/SCENE
func handle_normal_drop(drop_position) -> void:
	if held_object:
		var final_position = find_valid_drop_position(drop_position)
		
		# TWEEN FOR BOUNCE EFFECT
		var drop_tween = create_tween()
		drop_tween.tween_property(held_object, "global_position", final_position, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		# UPDATE OBJECT PROPERTIES
		held_object.is_pickupable = true	
		held_object.reparent(get_parent())

func find_valid_drop_position(base_position: Vector2) -> Vector2:
	# BASE DROP RADIUS AND SPACING
	var drop_radius = 40
	var spacing = 15
	var nearby_objects = []
	
	# FIND ALL EXISTING OBJECTS NEAR THE DROP POINT
	for obj in get_parent().get_children():
		if obj is object_class and obj != held_object:
			var distance = obj.global_position.distance_to(base_position)
			if distance < drop_radius:
				nearby_objects.append(obj)
	
	# IF NO NEARBY OBJECTS, USE THE BASE POSITION
	if nearby_objects.size() == 0:
		return base_position
	
	
	var offset_multiplier = 1.0
	var max_attempts = 8 
	var attempt = 0
	var test_position = base_position
	
	while attempt < max_attempts:
		var overlap = false
		
		
		for obj in nearby_objects:
			var distance = obj.global_position.distance_to(test_position)
			if distance < spacing:
				overlap = true
				break
		
		if not overlap:
			return test_position
		
		var angle = attempt * (PI/4) 
		offset_multiplier = 1.0 + (float(attempt) / 4.0) 
		test_position = base_position + Vector2(
			cos(angle) * spacing * offset_multiplier,
			sin(angle) * spacing * offset_multiplier
		)
		attempt += 1
	
	return test_position

# ADJUST THE VISUAL APPEARANCE OF A STACK OF OBJECTS
func adjust_stack_visuals(stack_base_object) -> void:
	# ENSURE EACH OBJECT IN STACK HAS PROPER LAYERING AND SLIGHT POSITIONAL ADJUSTMENTS
	var stack = stack_base_object.tool_stack
	for i in range(stack.size()):
		var obj = stack[i]
		if is_instance_valid(obj):
			obj.z_index = stack_base_object.z_index + i + 1
			# APPLY SLIGHT OFFSET BASED ON STACK POSITION
			var offset = Vector2(i * 2, -i * 5)
			
			# CREATE A SMALL TWEEN TO ADJUST THE POSITION WITH A SLIGHT DELAY
			var adjust_tween = create_tween()
			adjust_tween.tween_property(obj, "position", stack_base_object.position + offset, 0.1)
			adjust_tween.tween_interval(0.05) 
			
			# MAKE EACH OBJECT IN THE STACK SLIGHTLY SMALLER/OFFSET FOR VISUAL CLARITY
			if obj.has_node("CollisionShape2D"):
				obj.get_node("CollisionShape2D").disabled = (i > 0)  
			
			# IF OBJECT HAS SPRITE, ADJUST IT
			if obj.has_node("item_sprite"):
				var obj_sprite = obj.get_node("item_sprite")
				if i > 0:  
					obj_sprite.scale = Vector2(0.9, 0.9)
					obj_sprite.modulate.a = 0.9

func _on_near_obj() -> void:
	sprite.play("antenna")


func start_camera_shake(intensity : float):
	if cameraShakeNoise and camera2d:
		var camera_offset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity
		camera2d.offset.x = camera_offset
		camera2d.offset.y = camera_offset

func shake_camera(intensity_from : float, intensity_to : float, duration : float):
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(start_camera_shake, intensity_from, intensity_to, duration)
