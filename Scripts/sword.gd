extends object_class

# STOP PLAYER
# IF HAS NODE old_man BEGIN PROCESS IF old_man.current_state is 2 or strong
# ANIMATESPRITE2D.aVISIBLE = TRUE THEN PLAY ANIMATION
@onready var loop_break_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var loopbreak2: AnimatedSprite2D = get_parent().get_node("loopbreak2")
@onready var sword_sprite: Sprite2D = $SwordSprite
@onready var sword_sfx: AudioStreamPlayer2D = $"../sword"
@onready var cinematic_impact = $"../cinematic_ah"
@onready var glass_break = $"../glass_break"
@onready var ice_break = $"../ice_break"
@onready var bell = $"../bell"
@onready var underwater_explosion = $"../underwater_explosion"
@onready var climb = $"../Climb"
@onready var sword_swing = $"../Sword2"
@onready var nagulat = $"../nagulat"

var is_playing: bool = false
var is_playing_two: bool = false
var tween_climb: Tween
var tween_rotate: Tween
var tween_scale: Tween
var time_indicator: AnimatedSprite2D

func _ready() -> void:
	time_indicator = get_parent().get_parent().get_parent().get_node("CanvasLayerGameUi").get_node("game_ui_elements").get_node("ui_frame").get_node("time_indicator")

func _process(_delta: float) -> void:
	if has_node("old_man") and GlobalVariables.is_looping and not is_playing:
		break_loop()
	pass

func break_loop():
	# STRONG TO OLD ANIMATION NEEDS TO PLAY BACKWARDS FIRST THEN
	# PLAY LOOP BREAK ANIMATION 
	var old_man = get_node("old_man")
	if old_man.current_state == 2:
		
		is_playing = true
		GlobalVariables.player_stopped = true
		GlobalVariables.is_looping = false
		
		# WAIT FOR THE ANIMATION TO FINISH
		var anim_strong_to_old = old_man.get_node("AnimatedSprite2D")
		anim_strong_to_old.play_backwards("strong_to_old")
		await anim_strong_to_old.animation_finished
		
		sword_sprite.visible = false
		loop_break_animation.visible = true
		get_node("old_man").visible = false
		
		#PLAY MUSIC
		sword_swing.play()
		nagulat.play()
		loop_break_animation.play("unsheate")

		await loop_break_animation.animation_finished
		# WAIT FOR ANIMATION TO FINISH FIRST
		sword_sfx.play()
		cinematic_impact.play()
		glass_break.play()
		ice_break.play()
		bell.play()
		underwater_explosion.play()
		loopbreak2.visible = true
		loopbreak2.play()
		GlobalVariables.player_stopped = false

func _on_body_entered(body) -> void:
	handle_body_entered(body) 
	
	# CLIMB THE SWORD
	if not GlobalVariables.is_looping and not is_playing_two:
		
		# SO THAT IT ONLY EXECUTES ONCE
		is_playing_two = true
		# DISABLE PLAYER MOVEMENT
		GlobalVariables.player_stopped = true
		
		await get_tree().create_timer(1).timeout
		
		# SET THE TIME INDICATOR TO FIXED IT INDICATES WINNING
		time_indicator.animation = "fixed"
		time_indicator.frame = 0
		time_indicator.pause()
		
		# PLAY CLIMB ANIMATION
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.stop()
			sprite.play("climb")
		
		# CLIMB
		tween_climb = create_tween()
		
		# Connect tween_finished if not yet connected
		if not tween_climb.is_connected("finished", _tween_climb_finished):
			tween_climb.connect("finished", _tween_climb_finished)
			
		# PLAY SOUND CLIMB
		climb.play()
			
		var screen_center = Vector2(-150.0, 250.0)
		tween_climb.tween_property(body, "position", screen_center, 1.5).set_trans(Tween.TRANS_LINEAR)
		await tween_climb.finished
		
		body.visible = false
		# SWITCH SCENE TO LEVEL 2
		go_to_level_3()
		
func go_to_level_3():
	# CREATE TWEEN FOR ROTATE
	tween_rotate = create_tween()
	# Connect tween_finished if not yet connected
	if not tween_rotate.is_connected("finished", _tween_rotation_finished):
		tween_rotate.connect("finished", _tween_rotation_finished)
	var rotation_tween = get_parent().rotation - deg_to_rad(-360.0)
	tween_rotate.tween_property(get_parent(), "rotation", rotation_tween, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# CREATE TWEEN FOR SCALE
	tween_scale = create_tween()
	# Connect tween_finished if not yet connected
	if not tween_scale.is_connected("finished", _tween_scale_finished):
		tween_scale.connect("finished", _tween_scale_finished)
	tween_scale.tween_property(get_parent(), "scale", Vector2(0.0,0.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await tween_scale.finished
	await get_tree().create_timer(1).timeout

	# NEXT LEVEL
	GlobalVariables.change_level("res://Scenes/levels/level_3_scene.tscn", get_parent().get_parent())

func _tween_climb_finished():
	tween_climb.kill()

func _tween_rotation_finished():
	tween_rotate.kill()

func _tween_scale_finished():
	tween_scale.kill()
