extends object_class

signal item_put(obj)

@onready var anim_sprite : AnimatedSprite2D = $symbol_anim_sprite
@onready var trex = $"../trex"
var material_count : int = 0

func _on_item_put(obj) -> void:
	#anim_sprite.play("")
	material_count += 1
	print(obj.name)
	print("Material Count Incremented: ", material_count)
	
	# Final ingredient is set
	if material_count == 3:
		# set visibility of trex to true
		print("TREX VISIBLE")
		trex.visible = true
		anim_sprite.visible = false
		trex.is_processed = true
