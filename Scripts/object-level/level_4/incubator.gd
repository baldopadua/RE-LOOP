extends object_class

@warning_ignore("unused_signal")
signal item_put(obj)

@onready var symbol_anim_sprite : AnimatedSprite2D = $symbol_anim_sprite
@onready var trex = $"../trex"
var material_count : int = 0

func _on_item_put(obj) -> void:
	#anim_sprite.play("")
	material_count += 1
	#print(obj.name)
	#print("Material Count Incremented: ", material_count)
	
	if material_count == 1 and obj.object_name == "chicken":
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")
		return
	elif material_count == 2 and obj.object_name == "lizard":
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		return
	elif material_count == 3 and obj.object_name == "bone":
		symbol_anim_sprite.play("correct")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
		# set visibility of trex to true
		print("TREX VISIBLE")
		trex.visible = true
		symbol_anim_sprite.visible = false
		trex.is_processed = true
	else:
		material_count -= 1
		symbol_anim_sprite.play("wrong")
		await symbol_anim_sprite.animation_finished
		symbol_anim_sprite.play("dino")	
