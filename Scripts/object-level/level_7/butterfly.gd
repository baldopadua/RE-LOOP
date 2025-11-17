extends object_class

# Butterfly can freely fly to make the wind reach the 6th state.
# 	Limit that by introducing a hunger mechanic
# Give a solution to hunger
# 	Flower will energize and sustain the butterfly so it can now move to form tornado.
# too easy, introduce another challenge
# 	Add spider enemy
# the spider will eat the butterfly therefore forfeiting the game, cinematic to butterfly then restart.
# 	Solution is to remove the spider from the way.
# Too easy, make it so that the spider is not pickup-able until dead.
# 	Tt can now be moved away from the butterfly's path.

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_manager = get_parent().get_node("SoundManager")
var moves : int = 3
var is_alive : bool = true
var b_min_state = 1
var b_max_state = 3
var b_curr_state = 3
@onready var flower = $"../flower"
@onready var wind = $"../wind"

@warning_ignore("unused_signal")
signal add_state(direction)
signal butterfly_state_changed

# TODO: Ayusin yung movement ng butterfly

func _on_rotate_object(direction: Variant) -> void:
	if not is_alive or wind.is_tornado:
		return
	if moves >= 0 and moves <= 3:
		var tween = create_tween()
			
		# Rotate based on direction
		var rotation_tween: float
		
		if direction == GlobalVariables.Directions.COUNTERCLOCKWISE and moves < 3 and moves >= 0:
			animated_sprite.play("flap_wings")
			rotation_tween = rotation - deg_to_rad(30.0)
			animated_sprite.flip_h = true
			moves += 1
			# Play butterfly sound
			if sound_manager and sound_manager.sfx.has("butterfly"):
				sound_manager.play_sfx("butterfly")
			tween.tween_property(self, "rotation", rotation_tween, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.finished.connect(func():
				wind.emit_signal("add_wind_state", direction)
				tween.kill()	
			)
			
		elif direction == GlobalVariables.Directions.CLOCKWISE and moves > 0 and moves <= 3:
			animated_sprite.play("flap_wings")
			rotation_tween = rotation + deg_to_rad(30.0)
			animated_sprite.flip_h = false
			moves -= 1
			# Play butterfly sound
			if sound_manager and sound_manager.sfx.has("butterfly"):
				sound_manager.play_sfx("butterfly")
			tween.tween_property(self, "rotation", rotation_tween, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.finished.connect(func():
				wind.emit_signal("add_wind_state", direction)
				tween.kill()	
			)
		else:
			tween.kill()
		
		if moves == 0:
			animated_sprite.play("starved_butterfly")
		print("MOVES: ", moves)
		

func _on_add_state(direction: Variant) -> void:
	if not is_alive or wind.is_tornado:
		return
	if direction == GlobalVariables.Directions.CLOCKWISE:
		if b_curr_state < b_max_state:
			b_curr_state += 1
		if b_curr_state == 2:
			animated_sprite.play("cocoon")
		elif b_curr_state == 3:
			animated_sprite.play("default")
			emit_signal("butterfly_state_changed") # <--- emit when state 3
	else:
		if b_curr_state > b_min_state:
			b_curr_state -= 1
		if b_curr_state == 1:
			animated_sprite.play_backwards("caterpillar")
		elif b_curr_state == 2:
			animated_sprite.play_backwards("cocoon")
	print("CURR_STATE: ", b_curr_state)


func _on_area_entered(area: Area2D) -> void:
	if area == flower and flower.is_pickupable and flower.animated_sprite.animation == "flower_blooming":
		moves = 3
		animated_sprite.play("starved_to_alive")
		print("Butterfly touched the flower!")

func _on_area_exited(area: Area2D) -> void:
	if area == flower:
		print("Butterfly left the flower")
