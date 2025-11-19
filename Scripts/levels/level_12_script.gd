extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene
@onready var count_down = $count_down
@onready var timer = $Timer

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

signal level_12_completed 

var object_positions = [
	Vector2(144, -253),
	Vector2(254, -144),
	Vector2(287, 2.0),
	Vector2(257, 154),
	Vector2(149, 260),
	Vector2(1.0, 298),
	Vector2(-142, 261),
	Vector2(-248, 151),
	Vector2(-275, 1.0),
	Vector2(-252, -136)
];

var object_rotation_based_on_position = {
	Vector2(144, -253): 210,
	Vector2(254, -144): 240,
	Vector2(287, 2.0): -90,
	Vector2(257, 154): -60,
	Vector2(149, 260): -30,
	Vector2(1.0, 298): 0,
	Vector2(-142, 261): 30,
	Vector2(-248, 151): 60,
	Vector2(-275, 1.0): 90,
	Vector2(-252, -136): 120
};

var statue_positions = [
	Vector2(122, -214),
	Vector2(213, -124),
	Vector2(243, 0),
	Vector2(214, 127),
	Vector2(127, 218),
	Vector2(0, 250),
	Vector2(-121, 218),
	Vector2(-208, 126),
	Vector2(-238, 0),
	Vector2(-210, -119),
];

var statue_rotation_based_on_position = {
	Vector2(122, -214): 210,
	Vector2(213, -124): 240,
	Vector2(243, 0): -90,
	Vector2(214, 127): -60,
	Vector2(127, 218): -30,
	Vector2(0, 250): 0,
	Vector2(-121, 218): 30,
	Vector2(-208, 126): 60,
	Vector2(-238, 0): 90,
	Vector2(-210, -119): 120
}

var rotations_possible = [
	0.0,
	30.0,
	60.0,
	90.0,
	120.0,
	150.0,
	180.0,
	210.0,
	240.0,
	270.0,
	300.0,
	330.0,
	360.0
]

@onready var level_handler = $CanvasLayer/LevelHandler
@onready var sound_manager = $SoundManager
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")

@onready var monk = $monk
@onready var canvas_layer = $CanvasLayer
@onready var center_pos = $center_pos
@onready var circly_thingy = $CirclyThingy
@onready var phase_1_switch_circles = [$"AreaHandler1/1_switch_circle", $"AreaHandler2/1_switch_circle"]
@onready var phase_2_switch_circles = [$"AreaHandler1/2_switch_circle", $"AreaHandler1/2_switch_circle2", $"AreaHandler2/2_switch_circle", $"AreaHandler2/2_switch_circle2", $"AreaHandler3/2_switch_circle", $"AreaHandler3/2_switch_circle2", $"AreaHandler4/2_switch_circle", $"AreaHandler4/2_switch_circle2", $"AreaHandler5/2_switch_circle", $"AreaHandler5/2_switch_circle2", $"AreaHandler6/2_switch_circle", $"AreaHandler6/2_switch_circle2"]
@onready var phase_3_switch_circles = [$"AreaHandler1/3_switch_circle2", $"AreaHandler1/3_switch_circle", $"AreaHandler2/3_switch_circle2", $"AreaHandler2/3_switch_circle", $"AreaHandler3/3_switch_circle2", $"AreaHandler3/3_switch_circle", $"AreaHandler4/3_switch_circle2", $"AreaHandler4/3_switch_circle", $"AreaHandler5/3_switch_circle2", $"AreaHandler5/3_switch_circle", $"AreaHandler6/3_switch_circle2", $"AreaHandler6/3_switch_circle", $"AreaHandler7/3_switch_circle2", $"AreaHandler7/3_switch_circle", $"AreaHandler8/3_switch_circle2", $"AreaHandler8/3_switch_circle", $"AreaHandler9/3_switch_circle2", $"AreaHandler9/3_switch_circle", $"AreaHandler10/3_switch_circle2", $"AreaHandler10/3_switch_circle", $"AreaHandler11/3_switch_circle2", $"AreaHandler11/3_switch_circle", $"AreaHandler12/3_switch_circle2", $"AreaHandler12/3_switch_circle"]
@onready var area_handlers_1 = [$AreaHandler1, $AreaHandler2]
@onready var area_handlers_2 = [$AreaHandler1, $AreaHandler2, $AreaHandler3, $AreaHandler4, $AreaHandler5, $AreaHandler6]
@onready var area_handlers_3 = [$AreaHandler1, $AreaHandler2, $AreaHandler3, $AreaHandler4, $AreaHandler5, $AreaHandler6, $AreaHandler7, $AreaHandler8, $AreaHandler9, $AreaHandler10, $AreaHandler11, $AreaHandler12]

# Area Handlers

@onready var area_handler1 = $AreaHandler1
@onready var area_handler2 = $AreaHandler2
@onready var area_handler3 = $AreaHandler3
@onready var area_handler4 = $AreaHandler4
@onready var area_handler5 = $AreaHandler5
@onready var area_handler6 = $AreaHandler6
@onready var area_handler7 = $AreaHandler7
@onready var area_handler8 = $AreaHandler8
@onready var area_handler9 = $AreaHandler9
@onready var area_handler10 = $AreaHandler10
@onready var area_handler11 = $AreaHandler11
@onready var area_handler12 = $AreaHandler12

# Statues

@onready var tree_statue = $tree_statue
@onready var hero_statue = $hero_statue
@onready var geyser_statue = $geyser_statue
@onready var dinosaur_statue = $dinosaur_statue
@onready var rocket_statue = $rocket_statue
@onready var apple_statue = $apple_statue
@onready var butterfly_statue = $butterfly_statue
@onready var turtle_statue = $turtle_statue
@onready var cat_statue = $cat_statue
@onready var electric_statue = $electric_statue
@onready var plooy_statue = $plooy_statue

# Keystones

@onready var seed = $seed
@onready var skull = $skull
@onready var rock = $rock
@onready var egg = $egg
@onready var soda = $soda
@onready var apple = $apple
@onready var butterfly = $butterfly
@onready var carrot = $carrot
@onready var cat = $cat
@onready var lightbulb = $lightbulb

var objects_in_phase_1 = []
var objects_in_phase_2 = []
var objects_in_phase_3 = []

func _ready():
	timer.start()
	objects_in_phase_1 = [seed, skull]
	objects_in_phase_2 = [rock, egg, soda, apple]
	objects_in_phase_3 = [butterfly, carrot, cat, lightbulb]
	# SET LEVEL
	level_handler.set_current_level(12)
	# ROTATION, SCALE SETUP AND MAP TWEENING
	level_handler.map_initialize(self, tween_rotate, tween_scale)
	GlobalVariables.is_looping = false
	
#	Enter Phases
	enter_phase_1()
	#enter_phase_2()
	#enter_phase_3()
	#finish_it()
	
	infinite_rotation()

	# PLAY SPECIAL FINAL LEVEL MUSIC
	if sound_manager:
		sound_manager.stop_music("main_bgm")
		sound_manager.stop_ambience_music("space_ambience")
		sound_manager.play_music("final_level_bgm")

# ADD THIS METHOD AS A TEMPORARY WAY TO FINISH LEVEL, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# STOP COUNTDOWN TIMER AND SOUNDS
	if count_down:
		count_down.stop()

	# STOP MAIN TIMER
	if timer:
		timer.stop()

	# STOP FINAL LEVEL MUSIC BEFORE COMPLETING
	if sound_manager:
		sound_manager.stop_music("final_level_bgm")
		# Stop any countdown beep sounds that might still be playing
		if sound_manager.sfx.has("countdown_beep"):
			sound_manager.stop_sfx("countdown_beep")

	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent())
	level_handler.complete_current_level(get_parent()) 
	

func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 12:
		print("=== SKIP LEVEL 12 - CLEANING UP ===")

		# Stop all timers
		if count_down:
			count_down.stop()
			print("Stopped count_down timer")
		if timer:
			timer.stop()
			print("Stopped main timer")

		# Stop all sounds
		if sound_manager:
			sound_manager.stop_music("final_level_bgm")
			if sound_manager.sfx.has("countdown_beep"):
				sound_manager.stop_sfx("countdown_beep")
			print("Stopped all level 12 sounds")

		# Stop player input
		if player:
			player.set_process_input(false)

		# Complete the level
		level_handler.complete_current_level(get_parent())

func initialize_locations_and_reparenting():
#	Hide Keystones and Statues

	seed.hide()
	skull.hide()
	rock.hide()
	egg.hide()
	soda.hide()
	apple.hide()
	butterfly.hide()
	carrot.hide()
	cat.hide()
	lightbulb.hide()
	
	tree_statue.hide()
	hero_statue.hide()
	geyser_statue.hide()
	dinosaur_statue.hide()
	rocket_statue.hide()
	apple_statue.hide()
	butterfly_statue.hide()
	turtle_statue.hide()
	cat_statue.hide()
	electric_statue.hide()
	plooy_statue.hide()
	
	tree_statue.get_node("AnimatedSprite2D").play_backwards("default")
	hero_statue.get_node("AnimatedSprite2D").play_backwards("default")
	geyser_statue.get_node("AnimatedSprite2D").play_backwards("default")
	dinosaur_statue.get_node("AnimatedSprite2D").play_backwards("default")
	rocket_statue.get_node("AnimatedSprite2D").play_backwards("default")
	apple_statue.get_node("AnimatedSprite2D").play_backwards("default")
	butterfly_statue.get_node("AnimatedSprite2D").play_backwards("default")
	turtle_statue.get_node("AnimatedSprite2D").play_backwards("default")
	cat_statue.get_node("AnimatedSprite2D").play_backwards("default")
	electric_statue.get_node("AnimatedSprite2D").play_backwards("default")
	plooy_statue.get_node("AnimatedSprite2D").play_backwards("default")
	
#	Put all Keystone and statues away to prevent player from picking them up
	
	seed.position = Vector2(-9999,-9999)
	skull.position = Vector2(-9999,-9999)
	rock.position = Vector2(-9999,-9999)
	egg.position = Vector2(-9999,-9999)
	soda.position = Vector2(-9999,-9999)
	apple.position = Vector2(-9999,-9999)
	butterfly.position = Vector2(-9999,-9999)
	carrot.position = Vector2(-9999,-9999)
	cat.position = Vector2(-9999,-9999)
	lightbulb.position = Vector2(-9999,-9999)
	
	tree_statue.position = Vector2(-9999,-9999)
	hero_statue.position = Vector2(-9999,-9999)
	geyser_statue.position = Vector2(-9999,-9999)
	dinosaur_statue.position = Vector2(-9999,-9999)
	rocket_statue.position = Vector2(-9999,-9999)
	apple_statue.position = Vector2(-9999,-9999)
	butterfly_statue.position = Vector2(-9999,-9999)
	turtle_statue.position = Vector2(-9999,-9999)
	cat_statue.position = Vector2(-9999,-9999)
	electric_statue.position = Vector2(-9999,-9999)
	plooy_statue.position = Vector2(-9999,-9999)

func place_object_with_random_position(node: Node2D, parent: Node, positions: Array, rotation_map: Dictionary) -> void:
	# Reparent the node
	node.reparent(parent)

	# Pick a random position
	var pos = positions.pick_random()

	# Apply position
	node.position = pos

	# Apply rotation based on dictionary lookup
	if rotation_map.has(pos):
		node.rotation_degrees = rotation_map[pos]
		
func place_statues_with_random_position(node: Node2D, parent: Node, positions: Array, rotation_map: Dictionary) -> void:
	# Reparent the node
	node.reparent(parent)

	# Pick a random position
	var pos = positions.pick_random()

	# Apply position
	node.position = pos

	# Apply rotation based on dictionary lookup
	if rotation_map.has(pos):
		node.rotation_degrees = rotation_map[pos]

func tween_opacity(target: CanvasItem, to_alpha: float, duration: float = 0.5):
	# Ensure it uses visible alpha and is shown before starting a fade-in
	if to_alpha >= 1.0:
		target.show()

	var tween := get_tree().create_tween()
	tween.tween_property(target, "modulate:a", to_alpha, duration)

	tween.finished.connect(func():
		if to_alpha <= 0.05:
			target.hide()
		else:
			target.show()
	)

func enter_phase_1():
	
	player.set_process_input(false)
	ui_handler.hide_game_ui_elements()
	
	# Play loop shake sound before transition
	if sound_manager and sound_manager.sfx.has("loop_shake"):
		sound_manager.play_sfx("loop_shake")
	
	# Play loop shake sound before transition
	if sound_manager and sound_manager.sfx.has("loop_shake"):
		sound_manager.play_sfx("loop_shake")
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.65)
#	Pan to Monk position
	player.get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
	
	await get_tree().create_timer(1.0).timeout
	
	# Play crystal transition sound
	if sound_manager and sound_manager.sfx.has("crystal_transition"):
		sound_manager.play_sfx("crystal_transition")
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)
	
	flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(3.0).timeout
	
	# Reveal all while still on white flash
	initialize_locations_and_reparenting()
	
	place_object_with_random_position(seed, area_handler2, object_positions, object_rotation_based_on_position)
	place_object_with_random_position(skull, area_handler1, object_positions, object_rotation_based_on_position)
	
	place_statues_with_random_position(tree_statue, area_handler1, statue_positions, statue_rotation_based_on_position)
	place_statues_with_random_position(hero_statue, area_handler2, statue_positions, statue_rotation_based_on_position)
	
	circly_thingy.show()
	
	seed.show()
	tree_statue.show()
	
	skull.show()
	hero_statue.show()
	
	player.shake_camera(5.0, 10.0, 4.0)
	
# 	Fade out animation
	var unflash = create_tween()
	unflash.tween_property(flash, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
#	Tween of the two circle separating	
	area_handler1.create_tween().tween_property(area_handler1, "position:x", -342.0, 3.0).finished.connect(func(): seed.pwede_na = true)
	area_handler2.create_tween().tween_property(area_handler2, "position:x", 342.0, 3.0).finished.connect(func(): skull.pwede_na = true)
	
#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position:x", -342.0, 3.0)
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position:x", 342.0, 3.0)
	
	await unflash.finished
	
#	Hide Cinematic Cameras
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")

	for switch_circle in phase_1_switch_circles:
		tween_opacity(switch_circle, 1.0, 2.0)
		switch_circle.monitoring = true
		switch_circle.monitorable = true

#	Show elements again
	ui_handler.show_game_ui_elements()
	
#	Enable Player Movement
	player.set_process_input(true)
	tween_opacity(monk, 0.0, 3.0)
	await get_tree().create_timer(3.0).timeout
	monk.hide()
	monk.position = Vector2(9999, 9999)

func enter_phase_2():	
	player.set_process_input(false)
	ui_handler.hide_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
	
	# Play loop shake sound for phase transition
	if sound_manager and sound_manager.sfx.has("loop_shake"):
		sound_manager.play_sfx("loop_shake")
	
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.25)
#	Pan to Monk position
	player.get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
	
	await get_tree().create_timer(1.0).timeout
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)
	
	flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Play crystal transition sound during flash
	if sound_manager and sound_manager.sfx.has("crystal_transition"):
		sound_manager.play_sfx("crystal_transition")
	
	await get_tree().create_timer(3.0).timeout
	
	# Reveal all while still on white flash
	initialize_locations_and_reparenting()
	
	for switch_circle in phase_1_switch_circles:
		tween_opacity(switch_circle, 0.0, 2.0)
		switch_circle.monitoring = false
		switch_circle.monitorable = false
	
	# Show keystones and statues AND show keystones and statues
	
	rock.show()
	egg.show()
	
	geyser_statue.show()
	dinosaur_statue.show()
	
	soda.show()
	apple.show()
	
	rocket_statue.show()
	apple_statue.show()
	
	place_object_with_random_position(rock, area_handlers_2.pick_random(), object_positions, object_rotation_based_on_position)
	place_object_with_random_position(egg, area_handlers_2.pick_random(), object_positions, object_rotation_based_on_position)
	
	place_statues_with_random_position(geyser_statue, area_handlers_2.pick_random(), statue_positions, statue_rotation_based_on_position)
	place_statues_with_random_position(dinosaur_statue, area_handlers_2.pick_random(), statue_positions, statue_rotation_based_on_position)
	
	place_object_with_random_position(soda, area_handlers_2.pick_random(), object_positions, object_rotation_based_on_position)
	place_object_with_random_position(apple, area_handlers_2.pick_random(), object_positions, object_rotation_based_on_position)
	
	place_statues_with_random_position(rocket_statue, area_handlers_2.pick_random(), statue_positions, statue_rotation_based_on_position)
	place_statues_with_random_position(apple_statue, area_handlers_2.pick_random(), statue_positions, statue_rotation_based_on_position)
	
	player.shake_camera(5.0, 10.0, 4.0)
	
# 	Fade out animation
	var unflash = create_tween()
	unflash.tween_property(flash, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
	area_handler3.show()
	area_handler4.show()
	area_handler5.show()
	area_handler6.show()
	
	# make the circly thingy bigger scale
	circly_thingy.create_tween().tween_property(circly_thingy, "scale", Vector2(0.6, 0.6), 3.0)
	
#	Tween of the two circle separating	
		# Circle 1: (0, -900)
	area_handler1.create_tween() \
		.tween_property(area_handler1, "position", Vector2(0, -900), 3.0) \
		.finished.connect(func(): seed.pwede_na = true)

	# Circle 2: (779, -450)
	area_handler2.create_tween() \
		.tween_property(area_handler2, "position", Vector2(779, -450), 3.0) \
		.finished.connect(func(): skull.pwede_na = true)

	# Circle 3: (779, 450)
	area_handler3.create_tween() \
		.tween_property(area_handler3, "position", Vector2(779, 450), 3.0) \
		.finished.connect(func(): rock.pwede_na = true)

	# Circle 4: (0, 900)
	area_handler4.create_tween()\
		.tween_property(area_handler4, "position", Vector2(0, 900), 3.0)\
		.finished.connect(func(): egg.pwede_na = true)

	# Circle 5: (-779, 450)
	area_handler5.create_tween()\
		.tween_property(area_handler5, "position", Vector2(-779, 450), 3.0)\
		.finished.connect(func(): soda.pwede_na = true)

	# Circle 6: (-779, -450)
	area_handler6.create_tween()\
		.tween_property(area_handler6, "position", Vector2(-779, -450), 3.0)\
		.finished.connect(func(): apple.pwede_na = true)

#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position", Vector2(0, -900), 3.0)
	
	await unflash.finished
	
#	Hide Cinematic Cameras
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")

	# Tween the circles
	for switch_circle in phase_2_switch_circles:
		tween_opacity(switch_circle, 1.0, 2.0)
		switch_circle.monitoring = true
		switch_circle.monitorable = true

#	Show elements again
	ui_handler.show_game_ui_elements()
	
#	Enable Player Movement
	player.set_process_input(true)

func enter_phase_3():
	player.set_process_input(false)
	ui_handler.hide_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
	
	# Play loop shake sound for phase transition
	if sound_manager and sound_manager.sfx.has("loop_shake"):
		sound_manager.play_sfx("loop_shake")
	
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
	if sound_manager and sound_manager.sfx.has("loop_shake"):
		sound_manager.play_sfx("loop_shake")
	
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.1)
#	Pan to Monk position
	player.get_node("Camera2D").emit_signal("pan_to_pos", center_pos.global_position)
	
	await get_tree().create_timer(1.0).timeout
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)
	
	flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Play crystal transition sound during flash
	if sound_manager and sound_manager.sfx.has("crystal_transition"):
		sound_manager.play_sfx("crystal_transition")
	
	await get_tree().create_timer(3.0).timeout
	
	# Reveal all while still on white flash
	initialize_locations_and_reparenting()
	
	for switch_circle in phase_2_switch_circles:
		tween_opacity(switch_circle, 0.0, 2.0)
		switch_circle.monitoring = false
		switch_circle.monitorable = false
	
	# Show keystones and statues AND show keystones and statues
	
	for area_handlerr in area_handlers_3:
		area_handlerr.show()
	
	butterfly.show()
	carrot.show()
	cat.show()
	lightbulb.show()
	
	butterfly_statue.show()
	turtle_statue.show()
	cat_statue.show()
	electric_statue.show()
	
	place_object_with_random_position(butterfly, area_handlers_3.pick_random(), object_positions, object_rotation_based_on_position)
	place_object_with_random_position(carrot, area_handlers_3.pick_random(), object_positions, object_rotation_based_on_position)
	
	place_statues_with_random_position(butterfly_statue, area_handlers_3.pick_random(), statue_positions, statue_rotation_based_on_position)
	place_statues_with_random_position(turtle_statue, area_handlers_3.pick_random(), statue_positions, statue_rotation_based_on_position)
	
	place_object_with_random_position(cat, area_handlers_3.pick_random(), object_positions, object_rotation_based_on_position)
	place_object_with_random_position(lightbulb, area_handlers_3.pick_random(), object_positions, object_rotation_based_on_position)
	
	place_statues_with_random_position(cat_statue, area_handlers_3.pick_random(), statue_positions, statue_rotation_based_on_position)
	place_statues_with_random_position(electric_statue, area_handlers_3.pick_random(), statue_positions, statue_rotation_based_on_position)
	
	player.shake_camera(5.0, 10.0, 4.0)
	
# 	Fade out animation
	var unflash = create_tween()
	unflash.tween_property(flash, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
	
	# make the circly thingy bigger scale
	circly_thingy.create_tween().tween_property(circly_thingy, "scale", Vector2(1.05, 1.05), 3.0)
	
#	Tween of the two circle separating	
	# Circle 1: (0, -1600)
	area_handler1.create_tween() \
		.tween_property(area_handler1, "position", Vector2(0, -1600), 3.0) \
		.finished.connect(func(): seed.pwede_na = true)

	# Circle 2: (800, -1400)
	area_handler2.create_tween() \
		.tween_property(area_handler2, "position", Vector2(800, -1400), 3.0) \
		.finished.connect(func(): skull.pwede_na = true)

	# Circle 3: (1400, -800)
	area_handler3.create_tween() \
		.tween_property(area_handler3, "position", Vector2(1400, -800), 3.0) \
		.finished.connect(func(): rock.pwede_na = true)

	# Circle 4: (1600, 0)
	area_handler4.create_tween() \
		.tween_property(area_handler4, "position", Vector2(1600, 0), 3.0) \
		.finished.connect(func(): egg.pwede_na = true)

	# Circle 5: (1400, 800)
	area_handler5.create_tween() \
		.tween_property(area_handler5, "position", Vector2(1400, 800), 3.0) \
		.finished.connect(func(): soda.pwede_na = true)

	# Circle 6: (800, 1400)
	area_handler6.create_tween() \
		.tween_property(area_handler6, "position", Vector2(800, 1400), 3.0) \
		.finished.connect(func(): apple.pwede_na = true)

	# Circle 7: (0, 1600)
	area_handler7.create_tween() \
		.tween_property(area_handler7, "position", Vector2(0, 1600), 3.0) \
		.finished.connect(func(): butterfly.pwede_na = true)

	# Circle 8: (-800, 1400)
	area_handler8.create_tween() \
		.tween_property(area_handler8, "position", Vector2(-800, 1400), 3.0) \
		.finished.connect(func(): carrot.pwede_na = true)

	# Circle 9: (-1400, 800)
	area_handler9.create_tween() \
		.tween_property(area_handler9, "position", Vector2(-1400, 800), 3.0) \
		.finished.connect(func(): cat.pwede_na = true)

	# Circle 10: (-1600, 0)
	area_handler10.create_tween() \
		.tween_property(area_handler10, "position", Vector2(-1600, 0), 3.0) \
		.finished.connect(func(): lightbulb.pwede_na = true)

	# Circle 11: (-1400, -800)
	area_handler11.create_tween() \
		.tween_property(area_handler11, "position", Vector2(-1400, -800), 3.0) \
		.finished.connect(func(): pass)

	# Circle 12: (-800, -1400)
	area_handler12.create_tween() \
		.tween_property(area_handler12, "position", Vector2(-800, -1400), 3.0) \
		.finished.connect(func(): pass)


#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position", Vector2(0, -1600), 3.0)
	
	await unflash.finished
	
#	Hide Cinematic Cameras
	player.get_node("Camera2D").emit_signal("hide_bars")
	player.get_node("Camera2D").emit_signal("cam_orig_zoom")
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")

	# Tween the circles
	for switch_circle in phase_3_switch_circles:
		tween_opacity(switch_circle, 1.0, 2.0)
		switch_circle.monitoring = true
		switch_circle.monitorable = true

#	Show elements again
	ui_handler.show_game_ui_elements()
	
#	Enable Player Movement
	player.set_process_input(true)
	
func finish_it():	
	tween_opacity(player, 0.0, 2.0)
	tween_opacity(monk, 0.0, 2.0)	
	
	GlobalVariables.player_stopped = true
	ui_handler.hide_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.1)
	
	player.get_node("Camera2D").emit_signal("pan_to_orig_pos")
	
	await get_tree().create_timer(1.0).timeout
	
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.anchor_right = 1
	flash.anchor_bottom = 1
	canvas_layer.add_child(flash)
	
	flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func():
		player.get_node("AnimatedSprite2D").position.y = 0.0
		player.get_node("CollisionShape2D").position.y = 0.0
		
		monk.get_node("AnimatedSprite2D").position.y = 0.0
		monk.get_node("CollisionShape2D").position.y = 0.0
	)
	await get_tree().create_timer(3.0).timeout
	
	# Show keystones and statues AND show keystones and statues
	
	player.get_node("Camera2D").emit_signal("cam_zoom", 1.5)
	
	
	for area_handlerr in area_handlers_3:
		area_handlerr.hide()
	
# 	Fade out animation
	var unflash = create_tween()
	unflash.tween_property(flash, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))

	tween_opacity(player, 1.0, 2.0)
	tween_opacity(monk, 1.0, 2.0)

#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position", Vector2(-20, 0), 2.0)
	#player.get_node("AnimatedSprite2D").flip_h = true
	player.get_node("AnimatedSprite2D").rotation_degrees = 0.0
	player.rotation_degrees = 0.0
	player.get_node("AnimatedSprite2D").flip_h = true
	monk.create_tween().tween_property(monk, "position", Vector2(20, 0), 2.0)
	monk.get_node("AnimatedSprite2D").rotation_degrees = 0.0
	monk.rotation_degrees = 0.0

	await unflash.finished
	
	DialogueManager.show_dialogue_balloon_scene("res://dialogues/made/balloon.tscn", load("res://dialogues/ending.dialogue"))
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _on_dialogue_ended(_resource: DialogueResource):
	
	player.create_tween().tween_property(player, "position", Vector2(0, 0), 3.0)
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position", Vector2(0, 0), 3.0).finished.connect(func():
		#	Plooy also gets separated to the left circle
		player.create_tween().tween_property(player, "position", Vector2(0, 0), 2.0)
	#	Monk gets separated to the right circle
		monk.create_tween().tween_property(monk, "position", Vector2(0, 0), 2.0)

		var flash = ColorRect.new()
		flash.color = Color(1.0, 1.0, 1.0, 0.0)
		flash.anchor_right = 1
		flash.anchor_bottom = 1
		canvas_layer.add_child(flash)
		flash.create_tween().tween_property(flash, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(3.0).timeout
		emit_signal("level_12_completed")
		level_handler.complete_current_level(get_parent())
		
	)

func infinite_rotation() -> void:
	var tween := create_tween().set_loops()

	tween.tween_property(circly_thingy, "rotation_degrees", 360.0, 1.0).as_relative().set_trans(Tween.TRANS_LINEAR)

func _on_timer_timeout() -> void:
	if not player.is_processing_input() or GlobalVariables.player_stopped:
		return
	trigger_random_event()

var countdown_data = {"time": 6}

func trigger_random_event():
	print("Monk Created") 

	var player_cur_pos = player.position
	if player.phase == 1:
		player_cur_pos = area_handlers_1.pick_random().position
	elif player.phase == 2:
		player_cur_pos = area_handlers_2.pick_random().position
	elif player.phase == 3:
		player_cur_pos = area_handlers_3.pick_random().position
		
	var rand_rotation_in_circle = rotations_possible.pick_random()

	# Duplicate monk
	monk.position = player_cur_pos
	monk.rotation_degrees = rand_rotation_in_circle
	monk.monitoring = true
	monk.monitorable = true
	tween_opacity(monk, 1.0, 2.0)

	# Countdown variables
	countdown_data = {"time": 6}
	count_down.start()

func on_countdown_tick(_monk_duplicate, time_left):
	time_left -= 1
	print("COUNTDOWN DATA TIME: ", countdown_data.time)
	print("TIMER TIME: ", timer.time_left)

	# Play countdown beep with increasing pitch as time decreases
	if sound_manager and sound_manager.sfx.has("countdown_beep"):
		var pitch = 0.7 + (6 - time_left) * 0.1  # 0.7 at 6 seconds, 1.2 at 1 second
		sound_manager.set_sfx_pitch_scale("countdown_beep", pitch)
		sound_manager.play_sfx("countdown_beep")

	player.shake_camera(1.0, 3.0, 1.0)
	
	# Update map frames based on time_left
	if time_left == 4 or time_left == 0:
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 0
	elif time_left == 3:
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 1
	elif time_left == 2:
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 2
	elif time_left == 1:
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 3
	
	# Show countdown label
	create_countdown_label(time_left)

func create_countdown_label(time_left: int) -> void:
	var label = Label.new()
	label.text = str(time_left)

	var font = FontFile.new()
	font.load_dynamic_font("res://Assets/fonts/ByteBounce.ttf")  
	label.add_theme_font_override("font", font)  
	label.add_theme_font_size_override("font_size", 256) 
	label.modulate = Color(1, 1, 1, 0)        
	
	add_child(label)
	
	label.pivot_offset = label.size / 2
	label.set_anchors_preset(Control.PRESET_CENTER, true)
	
	label.position = player.position - label.pivot_offset

	var tween = create_tween()
	label.scale = Vector2(0.5, 0.5)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.3)
	tween.finished.connect(func(): label.queue_free())


func _on_player_scene_player_finished_moving() -> void:	
	# Check rotation alignment FIRST
	var plyr_clock_pos = int(abs(round(player.rotation_degrees))) % 360
	var monk_clock_pos = int(abs(round(monk.rotation_degrees))) % 360
	
	#print("PLR ROT: ", plyr_clock_pos)
	#print("MONK ROT: ", monk_clock_pos)
	
	if plyr_clock_pos == monk_clock_pos and countdown_data.time < 6:
		print("MONK MATCHED")
		# Stop the timer and clean up
		count_down.stop()
		
		# Fade out and remove the monk
		tween_opacity(monk, 0.0, 0.3)
		monk.monitoring = false
		monk.monitorable = false
		await get_tree().create_timer(0.3).timeout
		
		player.shake_camera(3.0, 6.0, 1.0)
		
		# Reset map frames
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 0
		
#		Reset countdown data back to 6
		countdown_data = {"time": 6}


func _on_count_down_timeout() -> void:		
	# Execute your per-second function here
	on_countdown_tick(monk, countdown_data.time)

	countdown_data.time -= 1

	if countdown_data.time <= 0:
		# Time's up! Play failure sound
		if sound_manager and sound_manager.sfx.has("time_up"):
			sound_manager.play_sfx("time_up")
		
		# Remove monk and timer, and trigger object placement
		monk.monitoring = false
		monk.monitorable = false
		tween_opacity(monk, 0.0, 2.0)
		count_down.stop()
		
#		Reset countdown data time to 6
		countdown_data = {"time": 6}

		if player.phase == 1:
			var obj = objects_in_phase_1.pick_random()
			for object in objects_in_phase_1:
				if object.matched:
					obj = object
					break
			if obj.is_pickupable or obj.matched:
				var area = area_handlers_1.pick_random()
				obj.matched = false
				obj.is_pickupable = true
				place_object_with_random_position(obj, area, object_positions, object_rotation_based_on_position)
		elif player.phase == 2:
			var obj = objects_in_phase_2.pick_random()
			for object in objects_in_phase_2:
				if object.matched:
					obj = object
					break
			if obj.is_pickupable or obj.matched:
				var area = area_handlers_2.pick_random()
				obj.matched = false
				obj.is_pickupable = true
				place_object_with_random_position(obj, area, object_positions, object_rotation_based_on_position)
		elif player.phase == 3:
			var obj = objects_in_phase_3.pick_random()
			for object in objects_in_phase_3:
				if object.matched:
					obj = object
					break
			if obj.is_pickupable or obj.matched:
				var area = area_handlers_3.pick_random()
				obj.matched = false
				obj.is_pickupable = true
				place_object_with_random_position(obj, area, object_positions, object_rotation_based_on_position)
		for area in area_handlers_3:
			area.get_node("world_environment").get_node("map").frame = 0

func get_normalized_rotation(rotation_deg: float) -> float:
	# Normalize any rotation to 0-360 range
	var normalized = fmod(rotation_deg, 360.0)
	if normalized < 0:
		normalized += 360.0
	return normalized

func get_clock_position(rotation_deg: float) -> int:
	# Get which "hour" on the clock (0-11)
	var normalized = get_normalized_rotation(rotation_deg)
	var sector_size = 360.0 / 12.0  # 30 degrees per sector
	return int(round(normalized / sector_size)) % 12
