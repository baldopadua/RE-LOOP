extends object_class

# STOP PLAYER
# IF HAS NODE old_man BEGIN PROCESS IF old_man.current_state is 2 or strong
# ANIMATESPRITE2D.aVISIBLE = TRUE THEN PLAY ANIMATION
@onready var loop_break_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_sprite: Sprite2D = $SwordSprite
@onready var sword_sfx: AudioStreamPlayer2D = $"../sword"

var is_playing: bool = false	

func _process(delta: float) -> void:
	if has_node("old_man") and GlobalVariables.is_looping and not is_playing:
		break_loop()
	pass

func break_loop():
	if get_node("old_man").current_state == 2:
		is_playing = true
		GlobalVariables.player_stopped = true
		GlobalVariables.is_looping = false
		get_node("old_man").get_node("AnimatedSprite2D").play_backwards("strong_to_old")
		await get_tree().create_timer(2.0)
		sword_sprite.visible = false
		loop_break_animation.visible = true
		get_node("old_man").visible = false
		sword_sfx.play()
		loop_break_animation.play("unsheate")
		# PLAY MUSIC
		await get_tree().create_timer(1.0)
		GlobalVariables.player_stopped = false
