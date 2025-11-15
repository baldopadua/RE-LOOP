extends object_class

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Default to present animation, frame 0, and stop
	animated_sprite.play("present")
	animated_sprite.frame = 0
	animated_sprite.stop()

func set_animation(anim_name: String):
	if animated_sprite.animation != anim_name or animated_sprite.frame != 0:
		_play_and_stop_at_last_frame(anim_name)

func play(anim_name: String):
	_play_and_stop_at_last_frame(anim_name)

func _play_and_stop_at_last_frame(anim_name: String):
	animated_sprite.play(anim_name)
	# Connect to animation_finished to stop at last frame
	if not animated_sprite.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished").bind(anim_name))

func _on_animated_sprite_2d_animation_finished() -> void:
	# Stop at last frame for the current animation
	var anim_name = animated_sprite.animation
	var last_frame = 0
	match anim_name:
		"climax":
			last_frame = 5 # 6 frames, index 0-5
		"future", "past", "present":
			last_frame = 3 # 4 frames, index 0-3
		_:
			return # Do nothing for unknown animations
	animated_sprite.frame = last_frame
	animated_sprite.stop()
	animated_sprite.frame = last_frame # set again in case stop resets it
