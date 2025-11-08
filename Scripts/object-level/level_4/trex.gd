extends object_class

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
	if is_processed and (current_state != previous_state):
		match [previous_state, current_state, player.direction]:
			# Forward animations
			[1, 2, GlobalVariables.player_direction.CLOCKWISE], \
			[2, 2, GlobalVariables.player_direction.CLOCKWISE]:
				stop_player()
				sprite.play("egg_to_trex")
				await sprite.animation_finished
				GlobalVariables.player_stopped = false
			# Reverse animations
			[2, 1, GlobalVariables.player_direction.COUNTERCLOCKWISE]:
				stop_player()
				sprite.play_backwards("egg_to_trex")
				await sprite.animation_finished
				GlobalVariables.player_stopped = false
	previous_state = current_state

func _on_body_entered(body):
	if body.name != "PlayerScene" or not is_processed:
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