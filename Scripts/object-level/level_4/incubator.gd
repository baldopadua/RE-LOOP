extends object_class

@warning_ignore("unused_signal")
signal item_put(obj)

@onready var symbol_anim_sprite : AnimatedSprite2D = $symbol_anim_sprite
@onready var DinoEggSprite : AnimatedSprite2D = $DinoEggSprite
@onready var trex = $"../trex"
@onready var level_script = get_parent()
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
		DinoEggSprite.play("running")
		return

	elif material_count == 2 and obj.object_name == "lizard":
		level_script.play_incubator_processing()
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
		return

	elif material_count == 3 and obj.object_name == "bone":
		level_script.play_incubator_processing()
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
		
		# Make T-Rex visible and trigger evolution
		print("TREX VISIBLE")
		trex.visible = true
		symbol_anim_sprite.visible = false
		trex.is_processed = true
		level_script.play_trex_evolution()
	else:
		material_count -= 1
		level_script.play_level4_sfx("incubator_error")
		symbol_anim_sprite.play("wrong")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
