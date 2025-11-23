extends "res://Scripts/player_script.gd"

@onready var monk = $"../monk"

# Area Handlers

@onready var area_handler1 = $"../AreaHandler1"
@onready var area_handler2 = $"../AreaHandler2"
@onready var area_handler3 = $"../AreaHandler3"
@onready var area_handler4 = $"../AreaHandler4"
@onready var area_handler5 = $"../AreaHandler5"
@onready var area_handler6 = $"../AreaHandler6"
@onready var area_handler7 = $"../AreaHandler7"
@onready var area_handler8 = $"../AreaHandler8"
@onready var area_handler9 = $"../AreaHandler9"
@onready var area_handler10 = $"../AreaHandler10"
@onready var area_handler11 = $"../AreaHandler11"
@onready var area_handler12 = $"../AreaHandler12"

# Statues

@onready var tree_statue = $"../tree_statue"
@onready var hero_statue = $"../hero_statue"
@onready var geyser_statue = $"../geyser_statue"
@onready var dinosaur_statue = $"../dinosaur_statue"
@onready var rocket_statue = $"../rocket_statue"
@onready var apple_statue = $"../apple_statue"
@onready var butterfly_statue = $"../butterfly_statue"
@onready var turtle_statue = $"../turtle_statue"
@onready var cat_statue = $"../cat_statue"
@onready var electric_statue = $"../electric_statue"
@onready var plooy_statue = $"../plooy_statue"

# Keystones

@onready var seed = $"../seed"
@onready var skull = $"../skull"
@onready var rock = $"../rock"
@onready var egg = $"../egg"
@onready var soda = $"../soda"
@onready var apple = $"../apple"
@onready var butterfly = $"../butterfly"
@onready var carrot = $"../carrot"
@onready var cat = $"../cat"
@onready var lightbulb = $"../lightbulb"

var phase = 1

func _on_player_finished_moving() -> void:
	#var normalized_rotation = int(round(rotation_degrees)) % 360
	#var monk_normalized_rotation = int(round(monk.rotation_degrees)) % 360
	if phase == 1:
		if seed.matched and skull.matched:
			finish_phase_1()
	elif phase == 2:
		if rock.matched and egg.matched and soda.matched and apple.matched:
			finish_phase_2()
	elif phase == 3:
		if butterfly.matched and carrot.matched and cat.matched and lightbulb.matched:
			finish_phase_3()
	
func finish_phase_1():
	phase += 1
	get_parent().enter_phase_2()

func finish_phase_2():
	phase += 1
	get_parent().enter_phase_3()
	
func finish_phase_3():
	print("PHASE 3 FINISHED")
	get_parent().finish_it()
