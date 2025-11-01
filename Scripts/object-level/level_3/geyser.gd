extends object_class

# ROCKS PLACED IN THE GEYSER
var rocks: Array = []

# ANIMATEDSPRITE2D and PLAYER
@onready var animate_geyser: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = $"../PlayerScene"

# HANDLERS
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var level_handler = $"../CanvasLayer/LevelHandler"

# BOOLEANS
var can_now_enter_geyser: bool = false
var default_geyser_played: bool = false
var is_exploded: bool = false
var is_playing: bool = false
var player_body: Node 

# ANIMATION PLAYER
@onready var anim_handler = $"../AnimationPlayer"

# TIME INDICATOR
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var area_handler = get_parent().get_node("AreaHandler")

# ALLOWED POSITIONS/MOVES
var allowed_positions: Array = [0, 3, -3, 6, -6, 9, -9, 12, -12]

func geyser_ekusproshon():
	animate_geyser.visible = true
	# LESS THAN FIVE ROCKS IS NOT GOING TO BUILD PRESSURE
	if rocks.size() >= 1 and rocks.size() < 5:
		if sound_manager:
			sound_manager.play_sfx("rock_explode_fail")
			sound_manager.play_sfx("rock_default_geyser_explode")
		# REPARENT EACH ROCK TO LEVEL 3 NODE
		await return_rocks()
		
		await animate_geyser.animation_finished
		animate_geyser.visible = false
	else:
		# STOP EVERYTHING
		GlobalVariables.player_stopped = true
		GlobalVariables.is_looping = false
		
		# DISABLE VISIBLITY ALL STATES AND NO ROCK
		get_node("NoRock").visible = false
		
		for node in get_children():
			if "State" in str(node.name):
				node.visible = false
	
		# BURST
		animate_geyser.play("burst")	
		await animate_geyser.animation_finished
		
		# AFTER BURSTING PLAY SFX
		if sound_manager:
			# Play level_3_sfx SFX directly
			sound_manager.play_sfx("geyser_explode")
			sound_manager.play_sfx("rock_explode")
			# Play all finish_level_sfx SFX at once
			if sound_manager.has_method("play_finish_level_sfx"):
				sound_manager.play_finish_level_sfx()
		# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
		ui_handler.set_time_indicator_fixed()
		
		# PLAY LOOPING GEYSER AFTER 
		area_handler.show_loop_break(2)
		animate_geyser.play("loop_break")
		
		# MAKE THE PLAYER ABLE TO MOVE AGAIN
		GlobalVariables.player_stopped = false
		can_now_enter_geyser = true	

func return_rocks():
		# DISABLE VISIBILITY OF EVERY STATE
	for node in get_children():
		if "State" in str(node.name):
			node.visible = false
	animate_geyser.play("default_geyser")
	for rock in rocks:
		rock.visible = true
		rock.is_pickupable = true
		rock.reparent(get_parent())
		
		# TWEEN TO ADD BOUNCE WHEN DROPPING DOWN
		var tween_prev_pos = create_tween()
		
		# GET THE PREV POS ON FIRST INDEX
		var rock_prev_pos = rock.orig_pos
		# PRINT PREVIOUS ROCK POSITION DEBUG
		#print(rock_prev_pos)
		
		tween_prev_pos.tween_property(rock, "position", rock_prev_pos, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await tween_prev_pos.finished
		tween_prev_pos.kill()
		
		if sound_manager:
			sound_manager.play_sfx("rock_ground_drop")
		
		var tween_prev_rotation = create_tween()
		
		# GET THE PREV ROTATION IN SECOND INDEX
		var rock_prev_rotation = rock.orig_rotation
		
		tween_prev_rotation.tween_property(rock, "rotation", rock_prev_rotation, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await tween_prev_rotation.finished
		tween_prev_rotation.kill()
		
	rocks.clear()

func _on_body_entered(body) -> void:
	handle_body_entered(body) 
	
	# IF LOOP BREAK IS PLAYING AND ROCKS SIZE IS 5
	if (animate_geyser.animation == "loop_break" and animate_geyser.is_playing()) and rocks.size() == 5 and not is_playing:
	
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		is_playing = true
		
		# STORE THE PLAYER REFERENCE
		player_body = body
		
		# PLAY RIDE THE WATER ANIMATION
		anim_handler.play("ride_the_water")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ride_the_water":
		# HIDE PLAYER AFTER RIDING THE WATER
		player_body.visible = false

		# NOTIFY LEVEL 3 IS COMPLETED - this will handle cutscene and next level automatically
		level_handler.complete_current_level(get_parent().get_parent())


# EXECUTE AFTER PLAYER FINISHES MOVING
func _on_player_scene_player_finished_moving() -> void:
	if can_now_enter_geyser:
		return
	
	# DEBUG PRINT CHECK PLAYER MOVES
	#print("MOVES: ")
	#print(player.moves)
	if player.moves in allowed_positions and rocks.size() > 0 and player.direction == GlobalVariables.player_direction.CLOCKWISE:
		geyser_ekusproshon()
	elif player.moves in allowed_positions and rocks.size() > 0 and player.direction == GlobalVariables.player_direction.COUNTERCLOCKWISE:
		return_rocks()
		
	if player.moves in allowed_positions and rocks.size() == 0 and not default_geyser_played:
		default_geyser_played = true
		animate_geyser.visible = true
		get_node("NoRock").visible = false
		if sound_manager:
			sound_manager.play_sfx("rock_default_geyser_explode")
		animate_geyser.play("default_geyser")
		await animate_geyser.animation_finished
		get_node("NoRock").visible = true
		default_geyser_played = false
		animate_geyser.visible = false
