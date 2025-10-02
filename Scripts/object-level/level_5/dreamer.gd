extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

@onready var dreamer_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var soda = $"../soda"
var area_entered_objects : Array = []

var is_soda_dispensed: bool = false

func _on_add_cur_state(_direction) -> void:
	if current_state == 1:
		dreamer_animated_sprite.play("skeletal_remains")
	elif current_state == 2:
		dreamer_animated_sprite.play("kid")
		if area_entered_objects.size() > 0:
			dreamer_animated_sprite.animation_finished.connect(func():
				for area in area_entered_objects:
					if area.object_name == "vending" and not is_soda_dispensed:
						# Play Animation of kid inserting coin
						# Play Animation of vending machine cluttering
						# Play Animation of vending machine dispensing soda
						# Play animation of kid raising the soda in the air
						# Play animation of kid dropping the soda on the ground
						
						is_soda_dispensed = true
						soda.visible = true
						soda.is_pickupable = true
						break
					# Also detect if the soda is within in range
					# Then determine if the kid grows up to be an astronaut
					# or a depressed salaryman
					elif area.object_name == "science_project":
						pass
		)
	elif current_state == 3:
		dreamer_animated_sprite.play("depressed_salaryman")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if dreamer_animated_sprite.animation == "skeletal_remains":
		is_pickupable = true
	elif dreamer_animated_sprite.animation == "kid" or dreamer_animated_sprite.animation == "depressed_salaryman" or dreamer_animated_sprite.animation == "astronaut":
		is_pickupable = false

func _on_area_shape_entered(area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# SCIENCE PROJECT
	if area_rid == rid_from_int64(1271310319616) and get_parent().name != "object_position":
		area_entered_objects.append(area)
	# VENDING MACHINE
	elif area_rid == rid_from_int64(1288490188801) and get_parent().name != "object_position":
		area_entered_objects.append(area)

func _on_area_shape_exited(area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
		# SCIENCE PROJECT
	if area_rid == rid_from_int64(1271310319616) and get_parent().name == "object_position":
		area_entered_objects.erase(area)
	# VENDING MACHINE
	elif area_rid == rid_from_int64(1288490188801) and get_parent().name == "object_position":
		area_entered_objects.erase(area)

func interact(_obj):
	#if obj.object_name == "vending" and obj in area_entered_objects:
		#pass
	return false

# TODO: make function that will add vending and science_project to usable_objects when a certain criteria is met
# TODO: When rocket is interactable, and the kid is dropped in there, the position of the kid ends up being weird
