extends object_class

var area_entered_objects : Array = []
var is_dreamer_here : bool = false
var is_soda_here : bool = false
@onready var rocket = $"../rocket"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_manager = get_parent().get_node("SoundManager")

func _ready():
	print("SCIENCE PROJECT: ",get_rid())

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# GUARD: ignore null area (prevents "invalid access to property 'name' on null instance")
	if area == null:
		return
	var parent = get_parent()
	if parent == null:
		return

	#	DREAMER/KID
	if area.name == "dreamer" and parent.name != "object_position":
		area_entered_objects.append(area)
		is_dreamer_here = true
	#	SODA
	elif area.name == "soda" and parent.name != "object_position":
		area_entered_objects.append(area)
		is_soda_here = true

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# GUARD: ignore null area (prevents "invalid access to property 'name' on null instance")
	if area == null:
		return
	var parent = get_parent()
	if parent == null:
		return

	#	DREAMER/KID
	if area.name == "dreamer" and parent.name != "object_position":
		area_entered_objects.erase(area)
		is_dreamer_here = false
	#	SODA
	elif area.name == "soda" and parent.name != "object_position":
		area_entered_objects.erase(area)
		is_soda_here = false

func set_animation(anim_name: String):
	var target_anim = anim_name + "_cubicle"
	if animated_sprite.animation != target_anim or animated_sprite.frame != 0:
		# Play build_stall sound with pitch variation based on cubicle state
		if sound_manager and sound_manager.sfx.has("build_stall"):
			var stall_sound = sound_manager.sfx["build_stall"]
			# Small stall (kid) = high pitch, Big stall (skeletal_remains) = low pitch
			match anim_name:
				"kid":
					stall_sound.pitch_scale = 1.3  # High pitch for small stall
				"depressed_salaryman":
					stall_sound.pitch_scale = 1.0  # Medium pitch
				"skeletal_remains":
					stall_sound.pitch_scale = 0.7  # Low pitch for big stall
			sound_manager.play_sfx("build_stall")
		animated_sprite.play(target_anim)
		# Connect to animation_finished to stop at last frame
		if not animated_sprite.is_connected("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished")):
			animated_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished").bind(target_anim))

func _on_animated_sprite_2d_animation_finished(_finished_anim: String = "") -> void:
	# Stop at last frame for the current animation
	var anim_name = animated_sprite.animation
	var last_frame = 0
	match anim_name:
		"depressed_salaryman_cubicle":
			last_frame = 4 # last frame index for depressed_salaryman_cubicle
		"skeletal_remains_cubicle":
			last_frame = 4 # last frame index for skeletal_remains_cubicle
		"kid_cubicle":
			last_frame = 4 # only one frame for kid_cubicle
		_:
			return # Do nothing for unknown animations
	animated_sprite.frame = last_frame
	animated_sprite.stop() # stop AFTER setting frame, so it doesn't reset to 0
	animated_sprite.frame = last_frame # set again in case stop() resets it
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_animated_sprite_2d_animation_finished"))
