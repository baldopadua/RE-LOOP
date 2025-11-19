extends "res://Scripts/player_script.gd"

@onready var in_1 = $"../isaac_newton_1"
@onready var in_2 = $"../isaac_newton_2"
@onready var seed1 = $"../seed"
@onready var seed2 = $"../seed2"
@onready var canvas_layer = $"../CanvasLayer"
@onready var switch_circle = $"../switch_circle"
@onready var animated_sprite = $AnimatedSprite2D

signal loop_break_shown # Add this signal

var matched = false
var can_trigger_body_entered = false # Add this flag

func _on_player_finished_moving() -> void:
	if not matched:
		if in_1.matched and in_2.matched and seed1.matched and seed2.matched:
			if in_1.current_state == in_2.current_state and seed1.current_state == seed2.current_state:
				GlobalVariables.player_stopped = true
				set_process_input(false)
				can_trigger_body_entered = true # Enable triggers only when matched
				
				await get_tree().create_timer(1.0).timeout
				
				# HIDE THE UI DURING CINEMA
				ui_handler.hide_game_ui_elements()
				get_node("Camera2D").emit_signal("reveal_bars")
				get_node("Camera2D").emit_signal("cam_zoom", 0.75)
				shake_camera(5.0, 10.0, 2.5)
				
				# Play variance merging SFX (loop shake + crystal transition)
				if sound_manager and sound_manager.sfx.has("loop_shake"):
					sound_manager.play_sfx("loop_shake")
				
				await get_tree().create_timer(2.5).timeout
				
				# Play crystal transition sound for variance merge
				if sound_manager and sound_manager.sfx.has("crystal_transition"):
					sound_manager.play_sfx("crystal_transition")
				
				var flash = ColorRect.new()
				flash.color = Color(1, 1, 1, 1)
				flash.anchor_right = 1
				flash.anchor_bottom = 1
				canvas_layer.add_child(flash)

				# Do all things before transitionting here...
				area_handler.get_node("world_environment").get_node("map").animation = "default"
				# Avoid setting position here if AnimationPlayer will animate it
				# position.x = 0.0 # <-- REMOVE or move after animation finished
				in_1.is_pickupable = false
				in_2.is_pickupable = false
				seed1.is_pickupable = false
				seed2.is_pickupable = false
				in_2.visible = false
				switch_circle.visible = false
				in_1.position.x = 0.0
				seed1.position.x = 0.0
				seed2.position.x = 0.0
				in_1.animated_sprite.play("default")
				in_1.animated_sprite2.play("default")
				seed1.animated_sprite.play("tree")
				seed1.animated_sprite2.play("tree")
				in_1.current_state = 2
				seed1.current_state = 4
				matched = true
				# Enable AnimationPlayer after match
				get_parent().enable_animation_player()
				# Reveal all the keystones here
				# Fade out animation
				position.x = 0.0
				flash.create_tween().tween_property(flash, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).finished.connect(func(): canvas_layer.remove_child(flash))
				
				await get_tree().create_timer(1.0).timeout

				# Ensure AnimationPlayer is active before playing apple_fall
				var anim_player = get_parent().get_node_or_null("AnimationPlayer")
				if anim_player:
					anim_player.playback_active = true
					anim_player.play("apple_fall")
					
					# Play apple fall SFX
					if sound_manager and sound_manager.sfx.has("apple_fall"):
						sound_manager.play_sfx("apple_fall")
					
					await anim_player.animation_finished

				get_node("Camera2D").emit_signal("cam_orig_zoom")
				# Play all finish_level_sfx SFX at once
				if sound_manager.has_method("play_finish_level_sfx"):
					sound_manager.play_finish_level_sfx()
				sound_manager.play_finish_level_sfx()
				area_handler.show_loop_break(6)

				emit_signal("loop_break_shown") 
				await get_tree().create_timer(1.0).timeout 

				# After the loop break, hide bars and enable player movement
				get_node("Camera2D").emit_signal("hide_bars")
				set_process_input(true)
				GlobalVariables.player_stopped = false
				
				# Connect body_entered signals for climbable objects
				seed1.connect("body_entered", Callable(self, "_on_climbable_body_entered"))
				seed2.connect("body_entered", Callable(self, "_on_climbable_body_entered"))
				in_1.connect("body_entered", Callable(self, "_on_climbable_body_entered"))
				in_2.connect("body_entered", Callable(self, "_on_climbable_body_entered"))

			else:
				can_trigger_body_entered = false # Disable triggers if not matched
		else:
			can_trigger_body_entered = false # Disable triggers if not matched

# Add this function to handle climb animation trigger
func _on_climbable_body_entered(body: Node) -> void:
	if body == self:
		set_process_input(false)
		print("Playing ClimbingAnimation")
		animated_sprite.play("climb") # Play climb on AnimatedSprite2D
		var level_node = get_parent()
		if level_node.has_method("play_climb_animation"):
			level_node.play_climb_animation(self)

# Add this function to be called from level script after climb animation finishes
func play_jump_animation():
	set_process_input(false)
	print("Playing JumpAnimation")
	animated_sprite.play("jump") # Play jump on AnimatedSprite2D
	position = Vector2(-1, -200)
	modulate = Color(1, 1, 1, 1)
