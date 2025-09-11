extends object_class

# ROCKS PLACED IN THE GEYSER
var rocks: Array = []

# ANIMATEDSPRITE2D and PLAYER
@onready var animate_geyser: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = $"../PlayerScene"

# HANDLERS
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var level_manager = $"../LevelHandler"

# BOOLEANS
var is_playing_two: bool = false
var is_player_in_geyser: bool = false
var default_geyser_played: bool = false
var is_exploded: bool = false

# TWEENS
var sprung_tween: Tween
var tween_rotate: Tween
var tween_scale: Tween

# ALLOWED ANGLES
var allowed_angles: Array = [0.0, 360.0, -360.0, 90.0, -90.0, 180.0, -180.0, 270.0, -270.0]

# TIME INDICATOR
@onready var ui_handler = get_tree().root.get_node("MainScene/UiHandler")

func _ready() -> void:
	# ang haba bruh, atleast it works ahhahahah
	pass

func _process(_delta: float) -> void:
	if is_player_in_geyser:
		if animate_geyser.frame == 18:
			if sound_manager:
				# Play level_3_sfx SFX directly
				sound_manager.play_sfx("geyser_explode")
				sound_manager.play_sfx("rock_explode")
				# Play all finish_level_sfx SFX at once
				if sound_manager.has_method("play_finish_level_sfx"):
					sound_manager.play_finish_level_sfx()
			# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
			ui_handler.set_time_indicator_fixed()
			ui_handler.set_default_time_indicator()
			
			animate_geyser.play("loop_break")
			
			# SPRUNG ALONG WITH GEYSER EXPLOSION
			sprung_tween = create_tween()
				
			var screen_center = Vector2(-150.0, 250.0)
			sprung_tween.tween_property(player, "position", screen_center, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			await sprung_tween.finished
			sprung_tween.kill()
			
			player.visible = false
			# SWITCH SCENE TO LEVEL 4
			level_manager.next_level(get_parent(), tween_rotate, tween_scale, "res://Scenes/levels/level_4_scene.tscn")
	
	# IF ANGLE OF PLAYER IS IN 3,6,9,12 AND ROCK SIZE IS GREATER THAN 0
	if round(rad_to_deg(player.rotation)) in allowed_angles and rocks.size() > 0 and not is_playing_two and player.direction == GlobalVariables.player_direction.CLOCKWISE:
		geyser_ekusproshon()
	elif round(rad_to_deg(player.rotation)) in allowed_angles and rocks.size() > 0 and not is_playing_two and player.direction == GlobalVariables.player_direction.COUNTERCLOCKWISE:
		return_rocks()
		
	if round(rad_to_deg(player.rotation)) in allowed_angles and rocks.size() == 0 and not default_geyser_played:
		default_geyser_played = true
		animate_geyser.visible = true
		get_node("NoRock").visible = false
		animate_geyser.play("default_geyser")
		await animate_geyser.animation_finished
		if sound_manager:
			sound_manager.play_sfx("rock_default_geyser_explode")
		get_node("NoRock").visible = true
		default_geyser_played = false
		animate_geyser.visible = false

# IN BODY ENTERED, IF PRESSURE 1 OR PRESSURE 2 IS ANIMATION_PLAYING AND NUMBER OF ROCKS IS 5
#	EXECUTE BREAK LOOP

func geyser_ekusproshon():
	is_playing_two = true
	animate_geyser.visible = true
	# LESS THAN FIVE ROCKS IS NOT GOING TO BUILD PRESSURE
	if rocks.size() >= 1 and rocks.size() < 5:
		if sound_manager:
			sound_manager.play_sfx("rock_explode_fail")
			sound_manager.play_sfx("rock_default_geyser_explode")
		# REPARENT EACH ROCK TO LEVEL 3 NODE
		await return_rocks()
		
		is_playing_two = false
		
		await animate_geyser.animation_finished
		animate_geyser.visible = false
	else:
		# DISABLE VISIBLITY ALL STATES AND NO ROCK
		get_node("NoRock").visible = false
		
		for node in get_children():
			if "State" in str(node.name):
				node.visible = false
		
		# BURST
		animate_geyser.play("burst")
		await animate_geyser.animation_finished
		
		# DISABLE ANIMATE GEYSER AFTER TWO LOOP BREAKS
		animate_geyser.visible = false
		get_node("NoRock").visible = true
		
		await return_rocks()
		
		is_playing_two = false

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
		print(rock_prev_pos)
		
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
	
	# SPRUNG ALONG WITH THE GEISER
	if (animate_geyser.animation == "burst" and animate_geyser.is_playing()) and animate_geyser.frame >= 0 and animate_geyser.frame <= 18 and rocks.size() == 5 and body.direction == GlobalVariables.player_direction.COUNTERCLOCKWISE:
	
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		rocks.clear()
		
		is_player_in_geyser = true			
