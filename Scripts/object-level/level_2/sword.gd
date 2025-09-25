extends object_class

# STOP PLAYER
# IF HAS NODE old_man BEGIN PROCESS IF old_man.current_state is 2 or strong
# ANIMATESPRITE2D.aVISIBLE = TRUE THEN PLAY ANIMATION
@onready var loop_break_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_sprite: Sprite2D = $SwordSprite
@onready var player = $"../PlayerScene"

# HANDLERS
@onready var sound_manager = get_parent().get_node("SoundManager")
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var level_handler = $"../LevelHandler"
@onready var ui_handler = get_tree().root.get_node("MainScene/CanvasLayerUi/UiHandler")
@onready var anim_handler = $"../AnimationPlayer"

# BOOLEANS
var is_playing: bool = false
var is_playing_two: bool = false

# TWEENS
var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween

# TIME INDICTAOR
var time_indicator: AnimatedSprite2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if has_node("old_man") and GlobalVariables.is_looping and not is_playing:
		break_loop()
	pass

func break_loop():
	var old_man = get_node("old_man")
	if old_man.current_state == 2:
		is_playing = true
		GlobalVariables.player_stopped = true
		GlobalVariables.is_looping = false

		var anim_strong_to_old = old_man.get_node("AnimatedSprite2D")
		anim_strong_to_old.play_backwards("strong_to_old")
		await anim_strong_to_old.animation_finished

		sword_sprite.visible = false
		loop_break_animation.visible = true
		get_node("old_man").visible = false

		# PLAY SFX via SoundManager
		if sound_manager:
			if sound_manager.sfx.has("Sword2"):
				sound_manager.play_sfx("Sword2")
			if sound_manager.sfx.has("nagulat"):
				sound_manager.play_sfx("nagulat")
		loop_break_animation.play("unsheate")
		await loop_break_animation.animation_finished

		if sound_manager:
			if sound_manager.sfx.has("sword"):
				sound_manager.play_sfx("sword")
			# Play all finish level SFX at once
			if sound_manager.has_method("play_finish_level_sfx"):
				sound_manager.play_finish_level_sfx()
		area_handler.show_loop_break(2)
		GlobalVariables.player_stopped = false

func _on_body_entered(body) -> void:
	handle_body_entered(body) 
	
	# CLIMB THE SWORD
	if not GlobalVariables.is_looping and not is_playing_two:
		is_playing_two = true
		GlobalVariables.player_stopped = true
		await get_tree().create_timer(1).timeout

		ui_handler.set_time_indicator_fixed()
		ui_handler.set_default_time_indicator()

		# Play the climbing sprite animation

		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# Play the Sound for climbing and Climb keyframe animation
		
		sound_manager.play_player_sfx("Climb")
		anim_handler.play("ClimbingAnimation_2")

func _tween_climb_finished():
	tween_climb.kill()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ClimbingAnimation_2":
		# Play jump animation on player sprite after climbing finishes
		if player and player.has_node("AnimatedSprite2D"):
			var sprite = player.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("jump")
		
		# Play jump animation in AnimationPlayer
		anim_handler.play("JumpAnimation_2")
	elif anim_name == "JumpAnimation_2":
		# DECLARE LEVEL TO BE FINISHED
		var cur_level = get_parent()
		
		# NOTIFY LEVEL IS COMPLETED
		level_handler.complete_current_level(get_parent().get_parent())
		level_handler.next_level(cur_level, tween_rotate, tween_scale, "res://Scenes/levels/level_3_scene.tscn")
		
		# CODE FOR PLAYING AnimatedSprite2D na nag jujump yung player sa hole.
