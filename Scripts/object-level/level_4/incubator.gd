extends object_class

@warning_ignore("unused_signal")
signal item_put(obj)

@onready var symbol_anim_sprite : AnimatedSprite2D = $symbol_anim_sprite
@onready var DinoEggSprite : AnimatedSprite2D = $DinoEggSprite
@onready var trex = get_parent().get_node("trex")
@onready var level_script = get_parent()
@onready var sound_manager = get_parent().get_node("SoundManager")
var material_count : int = 0

func _on_item_put(obj) -> void:
	material_count += 1

	if material_count == 1 and obj.object_name == "chicken":
		level_script.play_incubator_processing()
		
		# Play symbol animations
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
		
		# Start DinoEggSprite animation — ensure it’s looping in the editor
		DinoEggSprite.visible = true
		DinoEggSprite.stop()
		DinoEggSprite.frame = 0
		DinoEggSprite.play("running")
		print("[incubator] DinoEggSprite now visible and playing 'running'")
		return
	elif material_count == 2 and obj.object_name == "lizard":
		level_script.play_incubator_processing()
		if sound_manager and sound_manager.sfx.has("incubator_check"):
			sound_manager.play_sfx("incubator_check")
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		return
	elif material_count == 3 and obj.object_name == "bone":
		GlobalVariables.player_stopped = true
		level_script.play_incubator_processing()
		if sound_manager and sound_manager.sfx.has("incubator_check"):
			sound_manager.play_sfx("incubator_check")
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		
		print("TREX VISIBLE")
		await get_tree().create_timer(0.3).timeout
		
		# Stop incubator sound & play empty
		if sound_manager:
			sound_manager.stop_sfx("idle_incubator")
		DinoEggSprite.stop()
		DinoEggSprite.play("empty")
		
		# Make trex visible and enable processing
		trex.visible = true
		trex.is_processed = true
		symbol_anim_sprite.visible = false
		level_script.play_trex_evolution()
		await get_tree().create_timer(2.0).timeout
		GlobalVariables.player_stopped = false
	else:
		material_count -= 1
		if sound_manager and sound_manager.sfx.has("incubator_wrong"):
				sound_manager.play_sfx("incubator_wrong")
		symbol_anim_sprite.play("wrong")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
