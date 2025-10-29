extends object_class

# If incubator is not complete, trex is not processed
var is_processed: bool = false
var has_played: bool = false  # Tracks if the spawn + tail whip has played

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $"../AnimationPlayer"

func _process(_delta: float) -> void:
	# Trigger spawn + tail whip immediately once
	if is_processed and not has_played:
		has_played = true
		play_spawn_and_tail_whip()


# Plays egg-to-T-Rex followed immediately by tail whip
func play_spawn_and_tail_whip() -> void:
	# Play growth animation
	sprite.speed_scale = 1
	sprite.play("egg_to_trex")
	await sprite.animation_finished
	
	# Immediately play tail whip
	sprite.play("tail_whip")
	await sprite.animation_finished
	
	# Optional follow-up AnimationPlayer animation
	anim_player.play("tail_whipped")
