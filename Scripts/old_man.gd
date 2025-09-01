extends object_class

var previous_state: int = 3
var old_man = self
@onready var animated_sprite = $AnimatedSprite2D
@onready var sound_manager = get_parent().get_node("SoundManager")

func _on_body_entered(body)-> void:
	if previous_state == 4 and current_state == 4:
		await animated_sprite.animation_finished
		handle_body_entered(body)
	else:
		handle_body_entered(body)

func _process(_delta: float) -> void:
	update_old_man_visibility()
	#print("CURRENT STATE: ", current_state)

func update_old_man_visibility():
	if not old_man:
		return
	
	# THE PLAYER ENTERED FIRST BEFORE THE STATE CHANGES SO IT READS 4 INSTEAD OF 5
	
	if current_state == 5 and get_parent().name != "PlayerScene" and get_parent().name != "Sword":
		is_pickupable = true
	else:
		is_pickupable = false
	
	if current_state != previous_state:
		#print("PREVIOUS STATE: ", previous_state, " ", "CURRENT STATE: ", current_state)
		match [previous_state, current_state]:
			[1, 2]:
				animated_sprite.play("young_to_strong")
				if sound_manager and sound_manager.sfx.has("man_transform"):
					sound_manager.sfx["man_transform"].pitch_scale = 1
					sound_manager.play_sfx("man_transform")
			[2, 3]:
				animated_sprite.play("strong_to_old")
				if sound_manager and sound_manager.sfx.has("man_transform"):
					sound_manager.sfx["man_transform"].pitch_scale = 0.5
			[3, 4]:
				animated_sprite.play("old_to_super_old")
				if sound_manager and sound_manager.sfx.has("old_transform"):
					sound_manager.play_sfx("old_transform")
			[4, 5]:
				animated_sprite.play("dead_skeleton")
				if sound_manager and sound_manager.sfx.has("bones"):
					sound_manager.play_sfx("bones")
			[5, 4]:
				animated_sprite.play("skeleton_to_super_old")
				if sound_manager and sound_manager.sfx.has("bones"):
					sound_manager.play_sfx("bones")
			[4, 3]:
				animated_sprite.play_backwards("old_to_super_old")
				if sound_manager and sound_manager.sfx.has("man_transform"):
					sound_manager.sfx["man_transform"].pitch_scale = 0.5
					sound_manager.play_sfx("man_transform")
			[3, 2]:
				animated_sprite.play_backwards("strong_to_old")
				if sound_manager and sound_manager.sfx.has("man_transform"):
					sound_manager.sfx["man_transform"].pitch_scale = 1
					sound_manager.play_sfx("man_transform")
			[2, 1]:
				animated_sprite.play_backwards("young_to_strong")
				if sound_manager and sound_manager.sfx.has("kid_transform"):
					sound_manager.sfx["kid_transform"].pitch_scale = 1
					sound_manager.play_sfx("kid_transform")
			
		previous_state = current_state

func interact(object_interacted: object_class):
	if object_interacted.object_name == "sword" and current_state == 5:
		position = Vector2(0, 50.0)
		is_pickupable = false
		reparent(object_interacted)
