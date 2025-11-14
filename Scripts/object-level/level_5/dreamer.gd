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
@onready var timer = $"../Timer"
@onready var temp_timer = $"../temp_timer"

var area_entered_objects : Array = []
var previous_state: int = 1

var is_soda_dispensed: bool = false
var is_dream_reached: bool = false
var is_in_vending: bool = false
var is_in_science: bool = false

func _process(_delta: float) -> void:
	update_dreamer_state()

func update_dreamer_state():
	# Update pickupability
	if current_state == 1:
		is_pickupable = true
	else:
		is_pickupable = false
	
	# Handle state changes with sound effects
	if current_state != previous_state:
		match [previous_state, current_state]:
			[1, 2]:
				# Skeletal remains to kid
				if sound_manager and sound_manager.sfx.has("happy_kid"):
					sound_manager.play_sfx("happy_kid")
				dreamer_animated_sprite.play("kid")
				await dreamer_animated_sprite.animation_finished
				if is_in_vending and not is_soda_dispensed:
					if sound_manager and sound_manager.sfx.has("vending_machine"):
						sound_manager.play_sfx("vending_machine")
					is_soda_dispensed = true
					soda.visible = true
					soda.is_pickupable = true
			[2, 3]:
				# Kid to adult (astronaut or salaryman)
				if is_in_science:
					if science_project.is_dreamer_here and science_project.is_soda_here:
						is_dream_reached = true
					else:
						is_dream_reached = false
				
				if is_dream_reached:
					if sound_manager and sound_manager.sfx.has("happy_kid"):
						sound_manager.play_sfx("happy_kid")
					dreamer_animated_sprite.play("astronaut")
					set_rocket()
				else:
					if sound_manager and sound_manager.sfx.has("depress_man"):
						sound_manager.play_sfx("depress_man")
					dreamer_animated_sprite.play("depressed_salaryman")
		
		previous_state = current_state

func _on_add_cur_state(_direction) -> void:
	if current_state == 1:
		dreamer_animated_sprite.play("skeletal_remains")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if dreamer_animated_sprite.animation == "skeletal_remains":
		is_pickupable = true
	elif dreamer_animated_sprite.animation == "kid" or dreamer_animated_sprite.animation == "depressed_salaryman" or dreamer_animated_sprite.animation == "astronaut":
		is_pickupable = false

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# VENDING MACHINE
	if area.name == "vending" and get_parent().name != "object_position":
		is_in_vending = true
	# SCIENCE PROJECT
	elif area.name == "science_project" and get_parent().name != "object_position":
		is_in_science = true

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# VENDING MACHINE
	if area.name == "vending" and get_parent().name == "object_position":
		is_in_vending = false
	# SCIENCE PROJECT
	elif area.name == "science_project" and get_parent().name == "object_position":
		is_in_science = true

func interact(_obj):
	#if obj.object_name == "vending" and obj in area_entered_objects:
		#pass
	return false

func set_rocket():
	rocket.visible = true
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

# TODO: make function that will add vending and science_project to usable_objects when a certain criteria is met
# TODO: When rocket is interactable, and the kid is dropped in there, the position of the kid ends up being weird
