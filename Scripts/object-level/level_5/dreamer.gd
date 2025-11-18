extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var dreamer_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var player = $"../PlayerScene"
@onready var sound_manager = get_parent().get_node("SoundManager")

# Keystone Objects
@onready var soda = $"../soda"
@onready var science_project = $"../science_project" 
@onready var rocket = $"../rocket"
@onready var rocket_animated_sprite: AnimatedSprite2D = rocket.get_node("AnimatedSprite2D")
@onready var timer = $"../Timer"
@onready var temp_timer = $"../temp_timer"
@onready var vending = $"../vending"
@onready var vending_sprite: AnimatedSprite2D = vending.get_node("AnimatedSprite2D")

var area_entered_objects : Array = []
var previous_state: int = 1

var is_soda_dispensed: bool = false
var is_dream_reached: bool = false
var is_in_vending: bool = false
var is_in_science: bool = false

func _process(_delta: float) -> void:
	update_dreamer_state()
	check_and_start_rocket()

func update_dreamer_state():
	# Update pickupability: Only skeletal_remains is pickupable
	if current_state == 3:
		is_pickupable = true
	else:
		is_pickupable = false
	
	# Handle state changes with sound effects and animations
	if current_state != previous_state:
		# Sync vending machine animation to dreamer state
		if current_state == 1:
			vending_sprite.set_animation("past")
		elif current_state == 2:
			vending_sprite.set_animation("present")
		elif current_state == 3:
			vending_sprite.set_animation("future")
		else:
			vending_sprite.set_animation("climax")
		match [previous_state, current_state]:
			[1, 2]:
				# Kid to depressed_salaryman
				if sound_manager:
					sound_manager.play_sfx("depress_man")
				dreamer_animated_sprite.play("depressed_salaryman")
				science_project.set_animation("depressed_salaryman")
			[2, 3]:
				# Depressed_salaryman to skeletal_remains
				if sound_manager:
					sound_manager.play_sfx("skeleton_collapse")
				dreamer_animated_sprite.play("skeletal_remains")
				science_project.set_animation("skeletal_remains")
				await dreamer_animated_sprite.animation_finished
			[3, 1]:
				# Skeletal_remains to kid (loop or reset, if needed)
				if sound_manager:
					sound_manager.play_sfx("happy_kid")
				dreamer_animated_sprite.play("kid")
				science_project.set_animation("kid")
				await dreamer_animated_sprite.animation_finished
				# Only kid can buy soda
				if is_in_vending and not is_soda_dispensed:
					if sound_manager:
						sound_manager.play_sfx("vending_machine")
					is_soda_dispensed = true
					soda.visible = true
					soda.is_pickupable = true
		# Dispense soda if state changed to kid and already in vending
		if current_state == 1 and is_in_vending and not is_soda_dispensed:
			if sound_manager:
				sound_manager.play_sfx("vending_machine")
			is_soda_dispensed = true
			soda.visible = true
			soda.is_pickupable = true

		previous_state = current_state

func _on_add_cur_state(_direction) -> void:
	# Sync vending machine animation to dreamer state
	if current_state == 1:
		vending_sprite.set_animation("past")
	elif current_state == 2:
		vending_sprite.set_animation("present")
	elif current_state == 3:
		vending_sprite.set_animation("future")
	else:
		vending_sprite.set_animation("climax")
	
	if current_state == 1:
		if sound_manager:
			sound_manager.play_sfx("happy_kid")
		dreamer_animated_sprite.play("kid")
		science_project.set_animation("kid")
	elif current_state == 2:
		if sound_manager:
			sound_manager.play_sfx("depress_man")
		dreamer_animated_sprite.play("depressed_salaryman")
		science_project.set_animation("depressed_salaryman")
	elif current_state == 3:
		dreamer_animated_sprite.play("skeletal_remains")
		science_project.set_animation("skeletal_remains")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	# Only skeletal_remains is pickupable
	if dreamer_animated_sprite.animation == "skeletal_remains":
		is_pickupable = true
	else:
		is_pickupable = false

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# GUARD: ignore null area or parent to avoid "invalid access to property 'name' on null instance"
	if area == null:
		return
	var parent = get_parent()
	if parent == null:
		return

	# VENDING MACHINE
	if area.name == "vending" and parent.name != "object_position":
		is_in_vending = true
		# Dispense soda if dreamer is kid and soda hasn't been dispensed yet
		if current_state == 1 and not is_soda_dispensed:
			if sound_manager:
				sound_manager.play_sfx("vending_machine")
			is_soda_dispensed = true
			soda.visible = true
			soda.is_pickupable = true
	# SCIENCE PROJECT
	elif area.name == "science_project" and parent.name != "object_position":
		is_in_science = true

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# GUARD: ignore null area or parent to avoid "invalid access to property 'name' on null instance"
	if area == null:
		return
	var parent = get_parent()
	if parent == null:
		return

	# VENDING MACHINE
	if area.name == "vending" and parent.name != "object_position":
		is_in_vending = false
	# SCIENCE PROJECT
	elif area.name == "science_project" and parent.name != "object_position":
		is_in_science = false

func interact(_obj):
	#if obj.object_name == "vending" and obj in area_entered_objects:
		#pass
	return false

func set_rocket():
	# Play rocket blastoff sound when building the rocket
	if sound_manager:
		sound_manager.play_sfx("rocket_blastoff")
		
	rocket.visible = true
	rocket_animated_sprite.play("rocket_ship")
	science_project.visible = false
	await rocket_animated_sprite.animation_finished
	# Set dreamer animation to astronaut
	if sound_manager:
		sound_manager.play_sfx("astronaut_transform")
	dreamer_animated_sprite.play("astronaut")
	soda.visible = false
	soda.is_pickupable = false

	# Zoom to rocket when astronaut animation plays
	ui_handler.hide_game_ui_elements()
	player.get_node("Camera2D").emit_signal("cam_zoom", 2.0)
	player.get_node("Camera2D").emit_signal("reveal_bars")
	player.get_node("Camera2D").emit_signal("pan_to_pos", rocket.global_position)
	
	await get_tree().create_timer(1.0).timeout

	# Stop player and play animation of kid going into rocket...
	GlobalVariables.player_stopped = true
	# Kunyare nag play na yung animation ni player na getting in the ship
	temp_timer.start(3.0)
	temp_timer.timeout.connect(func():
		temp_timer.stop()
		visible = false
		GlobalVariables.player_stopped = false
		# Start Countdown
		rocket.rocket_start()
	)

func check_and_start_rocket():
	# Check if all three objects are in the same place and rocket hasn't started
	if rocket.visible:
		return # Already started
	# All must be visible and pickupable (soda), and dreamer must be kid
	if soda.visible and soda.is_pickupable and current_state == 1 and science_project.visible:
		# Check if all are close enough (same area)
		var dist1 = global_position.distance_to(soda.global_position)
		var dist2 = global_position.distance_to(science_project.global_position)
		var dist3 = soda.global_position.distance_to(science_project.global_position)
		var threshold = 48 # adjust as needed for "same place"
		if dist1 < threshold and dist2 < threshold and dist3 < threshold:
			set_rocket()

# TODO: make function that will add vending and science_project to usable_objects when a certain criteria is met
# TODO: When rocket is interactable, and the kid is dropped in there, the position of the kid ends up being weird
