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
@onready var vending = $"../vending"
@onready var vending_sprite: AnimatedSprite2D = vending.get_node("AnimatedSprite2D")

var near_objects = []

var previous_state: int = 1

var is_soda_dispensed: bool = false
var is_dream_reached: bool = false
var is_in_vending: bool = false
var is_in_science: bool = false

func _on_add_cur_state(direction) -> void:
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if current_state == 2:
			if soda in near_objects and science_project in near_objects and not rocket.rocket_started:
				dreamer_animated_sprite.play("astronaut")
				rocket.set_rocket()
			else:
				dreamer_animated_sprite.play("depressed_salaryman")
				science_project.set_animation("depressed_salaryman")
				if sound_manager:
					sound_manager.play_sfx("depress_man")
		elif current_state == 3:
			dreamer_animated_sprite.play("skeletal_remains")
			science_project.set_animation("skeletal_remains")
			is_pickupable = true
	else:
		if current_state == 1:
			dreamer_animated_sprite.play("kid")
			science_project.set_animation("kid")
			if sound_manager:
				sound_manager.play_sfx("happy_kid")
			if vending in near_objects and not is_soda_dispensed and vending.current_state == 1:
				if sound_manager:
					sound_manager.play_sfx("vending_machine")
				is_soda_dispensed = true
				soda.visible = true
				soda.is_pickupable = true
		elif current_state == 2:
			is_pickupable = false
			if soda in near_objects and science_project in near_objects and not rocket.rocket_started:
				dreamer_animated_sprite.play("astronaut")
				rocket.set_rocket()
			else:
				dreamer_animated_sprite.play("depressed_salaryman")
				science_project.set_animation("depressed_salaryman")
				if sound_manager:
					sound_manager.play_sfx("depress_man")

func interact(_obj):
	return false


func _on_area_entered(area: Area2D) -> void:
	if area is object_class:
		if area.object_name == "soda" or area.object_name == "science_project" or area.object_name == "vending":
			near_objects.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area is object_class:
		if area.object_name == "soda" or area.object_name == "science_project" or area.object_name == "vending":
			near_objects.erase(area)
