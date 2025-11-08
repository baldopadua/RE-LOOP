extends object_class

# If incubator is not complete, trex is not processed
var is_processed: bool = false
var has_played: bool = false  # Tracks if the spawn + tail whip has played

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $"../AnimationPlayer"
@onready var area_handler = get_parent().get_node("AreaHandler")
@onready var sound_manager = get_parent().get_node("SoundManager")


func stop_player():
	GlobalVariables.is_looping = false
	GlobalVariables.player_stopped = true

func _ready():
	sprite.frame_changed.connect(_on_sprite_frame_changed)

func _on_sprite_frame_changed():
	if sprite.animation == "egg_to_trex":
		match sprite.frame:
			2:
				if sound_manager and sound_manager.sfx.has("egg_crack1"):
					sound_manager.play_sfx("egg_crack1")
				if sound_manager and sound_manager.sfx.has("baby_dinasaur1"):
					sound_manager.play_sfx("baby_dinasaur1")
			4:
				if sound_manager and sound_manager.sfx.has("egg_crack2"):
					sound_manager.play_sfx("egg_crack2")
				if sound_manager and sound_manager.sfx.has("baby_dinasaur2"):
					sound_manager.play_sfx("baby_dinasaur2")
			6:
				if sound_manager and sound_manager.sfx.has("big_dinasaur1"):
					sound_manager.play_sfx("big_dinasaur1")

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
	
	anim_player.play("tail_whipped")
