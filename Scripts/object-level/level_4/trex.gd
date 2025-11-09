extends object_class

@warning_ignore("unused_signal")
signal add_cur_state(direction)

# If incubator is not complete, trex is not processed
var is_processed : bool = false
var previous_state = current_state
@onready var player = $"../PlayerScene"
@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $"../AnimationPlayer"
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var sound_manager = get_parent().get_node("SoundManager")


func stop_player():
	GlobalVariables.is_looping = false
	GlobalVariables.player_stopped = true

func _ready():
	pass


func _on_body_entered(body):
	# Only allow collision when trex is adult (state 4, not 3)
	if body.name != "PlayerScene" or not is_processed or current_state != 4:
		return
	handle_body_entered(body)
	stop_player()
	sprite.play("tail_whip")
	await sprite.animation_finished
	area_handler.show_loop_break(4)
	# Play all finish_level_sfx SFX at once
	if sound_manager.has_method("play_finish_level_sfx"):
		sound_manager.play_finish_level_sfx()
	anim_player.play("tail_whipped")


func _on_add_cur_state(direction: Variant) -> void:
	# Only play animations if T-Rex is processed (incubator is complete)
	if !is_processed:
		return
	
	if direction == GlobalVariables.Directions.CLOCKWISE:
		sprite.speed_scale = 1.0  # Play forward
		if current_state == 2:
			sprite.play("egg_to_baby")
			if sound_manager and sound_manager.sfx.has("egg_crack1"):
					sound_manager.play_sfx("egg_crack1")
			if sound_manager and sound_manager.sfx.has("baby_dinasaur1"):
					sound_manager.play_sfx("baby_dinasaur1")
			await sprite.animation_finished
		elif current_state == 3:
			sprite.play("baby_to_teen")
			if sound_manager and sound_manager.sfx.has("baby_dinasaur2"):
					sound_manager.play_sfx("baby_dinasaur2")
			await sprite.animation_finished
		elif current_state == 4:
			sprite.play("teen_to_adult")
			if sound_manager and sound_manager.sfx.has("big_dinasaur1"):
					sound_manager.play_sfx("big_dinasaur1")
			await sprite.animation_finished
	else:
		sprite.speed_scale = -1.0  # Play backwards
		if current_state == 1:
			sprite.play("egg_to_baby")
			sprite.frame = sprite.sprite_frames.get_frame_count("egg_to_baby") - 1
			
			await sprite.animation_finished
		elif current_state == 2:
			sprite.play("baby_to_teen")
			sprite.frame = sprite.sprite_frames.get_frame_count("baby_to_teen") - 1
			if sound_manager and sound_manager.sfx.has("egg_crack1"):
					sound_manager.play_sfx("egg_crack1")
			if sound_manager and sound_manager.sfx.has("baby_dinasaur1"):
					sound_manager.play_sfx("baby_dinasaur1")
			await sprite.animation_finished
		elif current_state == 3:
			sprite.play("teen_to_adult")
			sprite.frame = sprite.sprite_frames.get_frame_count("teen_to_adult") - 1
			if sound_manager and sound_manager.sfx.has("baby_dinasaur2"):
					sound_manager.play_sfx("baby_dinasaur2")
			await sprite.animation_finished
