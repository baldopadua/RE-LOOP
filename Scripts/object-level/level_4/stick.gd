extends object_class

signal add_cur_state(direction)

# Stick
@onready var bone = $"../bone"
@onready var stick_dog_sprite = $"../dog/StickDog"
@onready var bone_dog_sprite = $"../dog/BoneDog"
var is_removed: bool = false

func interact(interactable_obj):
	if interactable_obj.name == "dog":
		position = Vector2(0, 50.0)
		var player: CharacterBody2D = get_parent().get_parent()
		reparent(interactable_obj)
		is_pickupable = false
		
		# Visibilities
		visible = false
		bone.visible = true
		bone.is_pickupable = true
		stick_dog_sprite.visible = true
		bone_dog_sprite.visible = false
		
		# To immediately signal the player to pickup the bone
		player.is_holding_object = false
		bone.handle_body_entered(player)

func _on_add_cur_state(direction) -> void:
	if is_removed:
		return
	
	if current_state in [2,3] and direction == GlobalVariables.player_direction.CLOCKWISE:
		adjust_scale_position(true)
	elif current_state in [1,2] and direction == GlobalVariables.player_direction.COUNTERCLOCKWISE:
		adjust_scale_position(false)
	
	if current_state == 3:
		is_pickupable = true
	else:
		is_pickupable = false

func adjust_scale_position(is_told_to_increased):
	if is_told_to_increased:
		scale += Vector2(0.2, 0.2)
		position -= Vector2(0.0, 9.0)
	else:
		scale -= Vector2(0.2, 0.2)
		position += Vector2(0.0, 9.0)

func _on_tree_exited() -> void:
	print("Tree Exited")
	is_removed = true
	
	# Figure out a way to flip rotation of the stick after exiting
