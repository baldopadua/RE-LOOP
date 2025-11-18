extends Node2D

@export var source_tilemap: TileMapLayer
@onready var player = $PlayerScene

var tween_rotate: Tween
var tween_scale: Tween
var objects: Array = []

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

func _ready():
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

	# PLAY SPECIAL FINAL LEVEL MUSIC
	if sound_manager:
		sound_manager.stop_music("main_bgm")
		sound_manager.stop_ambience_music("space_ambience")
		sound_manager.play_music("final_level_bgm")

# ADD THIS METHOD AS A TEMPORARY WAY TO FINISH LEVEL, REMOVE IT WHEN STARTING 
# TO WORK ON THE SCRIPT
# ALSO REMOVE THE OBJECT "enter_[number]" WHEN THE SCRIPTING IS DONE
func enter_level():
	# STOP FINAL LEVEL MUSIC BEFORE COMPLETING
	if sound_manager:
		sound_manager.stop_music("final_level_bgm")
	
	# CALL THIS WHEN METHOD IS DONE IN LEVEL SCRIPT, IF THE FINISH CONDITION IS IN THE
	# OBJECT, USE level_handler.complete_current_level(get_parent()get_parent()) 
	level_handler.complete_current_level(get_parent()) 
	

func _on_level_handler_skip_level_requested(level_number: int) -> void:
	if level_number == 12:
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
	ui_handler.disable_game_ui_elements()
	
	player.set_process_input(false)
	ui_handler.disable_game_ui_elements()
	
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

func enter_phase_2():
	ui_handler.disable_game_ui_elements()
	
	player.set_process_input(false)
	ui_handler.disable_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
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
	circly_thingy.create_tween().tween_property(circly_thingy, "scale", Vector2(2.0, 2.0), 3.0)
	
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
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position", Vector2(0, 900), 3.0)
	
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
	ui_handler.disable_game_ui_elements()
	
	player.set_process_input(false)
	ui_handler.disable_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
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
	circly_thingy.create_tween().tween_property(circly_thingy, "scale", Vector2(3.5, 3.5), 3.0)
	
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
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position", Vector2(0, 1600), 3.0)
	
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
	GlobalVariables.player_stopped = true
	ui_handler.disable_game_ui_elements()
	
#	Shake Camera
	player.shake_camera(5.0, 10.0, 4.0)
#	Cinematic Cameras
	player.get_node("Camera2D").emit_signal("reveal_bars")
#	Zoom out
	player.get_node("Camera2D").emit_signal("cam_zoom", 0.1)
	
	player.get_node("Camera2D").emit_signal("pan_to_pos", monk.global_position)
	
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

#	The separation of the two symbolizes the 
	
#	Plooy also gets separated to the left circle
	player.create_tween().tween_property(player, "position", Vector2(-20, 0), 2.0)
	#player.get_node("AnimatedSprite2D").flip_h = true
	player.get_node("AnimatedSprite2D").rotation_degrees = 0.0
	player.get_node("AnimatedSprite2D").flip_h = true
#	Monk gets separated to the right circle
	monk.create_tween().tween_property(monk, "position", Vector2(20, 0), 2.0)
	monk.get_node("AnimatedSprite2D").rotation_degrees = 0.0


	
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
	)
