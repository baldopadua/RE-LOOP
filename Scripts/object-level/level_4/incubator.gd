extends object_class

@warning_ignore("unused_signal")
signal item_put(obj)

@onready var symbol_anim_sprite : AnimatedSprite2D = $symbol_anim_sprite
@onready var trex = $"../trex"
@onready var level_script = get_parent()
@onready var sound_manager = get_parent().get_node("SoundManager")
var material_count : int = 0

func _on_item_put(obj) -> void:
	#anim_sprite.play("")
	material_count += 1
	#print(obj.name)
	#print("Material Count Incremented: ", material_count)
	
	if material_count == 1 and obj.object_name == "chicken":
		if sound_manager and sound_manager.sfx.has("incubator_check"):
			sound_manager.play_sfx("incubator_check")
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
		return
	elif material_count == 2 and obj.object_name == "lizard":
		if sound_manager and sound_manager.sfx.has("incubator_check"):
			sound_manager.play_sfx("incubator_check")
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		return
	elif material_count == 3 and obj.object_name == "bone":
		if sound_manager and sound_manager.sfx.has("incubator_check"):
			sound_manager.play_sfx("incubator_check")
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		# set visibility of trex to true
		print("TREX VISIBLE")
		trex.visible = true
		symbol_anim_sprite.visible = false
		trex.is_processed = true
		level_script.play_trex_evolution()
	else:
		material_count -= 1
		if sound_manager and sound_manager.sfx.has("incubator_wrong"):
				sound_manager.play_sfx("incubator_wrong")
		symbol_anim_sprite.play("wrong")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
