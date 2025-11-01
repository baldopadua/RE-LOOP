extends object_class

var rocket_started : bool = false
var ready_for_entering: bool = false
@onready var timer = $"../Timer"
@onready var temp_timer = $"../temp_timer"
@onready var text = $AnimatedSprite2D/Label
@onready var animationplayer = $"../AnimationPlayer"
@onready var player_label = $"../PlayerScene/Label"
var player_has_entered : bool = false
var player_still_allowed : bool = true
@onready var level_handler = $"../CanvasLayer/LevelHandler"
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var sound_manager = get_parent().get_node("SoundManager")


func _process(_delta: float) -> void:
	if rocket_started:
		text.text = str(abs(round(int(timer.time_left))))

func rocket_start():
	ready_for_entering = true
	timer.start(10.0)
	timer.timeout.connect(func():
		# Send the rocket out into space
		rocket_started = false
		animationplayer.play("rocket_animation")
		text.visible = false
		player_still_allowed = false
	)
	rocket_started = true
	await get_tree().create_timer(13.5).timeout
	# Play all finish_level_sfx SFX at once
	if sound_manager.has_method("play_finish_level_sfx"):
		sound_manager.play_finish_level_sfx()
	z_index = 1
	area_handler.show_loop_break(5)

func _on_body_entered(body) -> void:
	if ready_for_entering and player_still_allowed:
		handle_body_entered(body)
		
		if body.name == "PlayerScene":
			GlobalVariables.player_stopped = true
			player_has_entered = true
			var tween = create_tween()
			tween.tween_property(body, "modulate", Color(0.0, 0.0, 0.0, 0.0), 1.5)
			tween.finished.connect(func():
				body.visible = false
				tween.kill()
			)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "rocket_animation":
		if not player_has_entered:
			player_label.visible = true
			temp_timer.start(3.0)
			temp_timer.timeout.connect(func():
				level_handler.restart_level(get_parent().get_parent())
			)
		else:
			# Player successfully entered the rocket and animation finished
			level_handler.complete_current_level(get_parent().get_parent())
