extends object_class 

var level_number: int = 0
var original_area_position: Vector2

func _ready() -> void:
	if get_parent() and get_parent().name == "level_status":
		is_enterable = false
		
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = true
		return
	is_enterable = true
	print("Lobby available: ", object_name)
	var object_lvl_num = object_name.replace("enter_", "").strip_edges()
	level_number = object_lvl_num.to_int()
	print(level_number)
	original_area_position = position

	# --- ENTERABLE LOGIC BASED ON SCENE CONTEXT ---
	_update_is_enterable()

func _update_is_enterable():
	var parent = get_parent()
	var scene = get_tree().current_scene
	var scene_name = scene.name if scene else ""
	var parent_name = parent.name if parent else ""

	# Check if under level_handler (level select clock)
	if parent_name == "level_status" or parent_name == "LevelHandler":
		is_enterable = false
		return

	# Check if inside a level_X_scene (level_1_scene, ..., level_12_scene)
	if scene_name.begins_with("level_") and scene_name.ends_with("_scene"):
		is_enterable = false
		return

	# Check if inside level_lobby
	if scene_name == "level_lobby":
		# If parent is not a level_X_scene, allow enterable
		is_enterable = true
		# But if parent is a level_X_scene (shouldn't happen), disable
		if parent_name.begins_with("level_") and parent_name.ends_with("_scene"):
			is_enterable = false
		return

	is_enterable = false

func on_hover_enter():
	if get_parent() and get_parent().name == "level_status":
		return
	
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover(level_number, self)
	# Use AnimationPlayer for hover animation if available
	var anim_player = get_parent().get_node_or_null("AnimationPlayer")
	if anim_player:
		var anim_name = "enter_%d_upward" % level_number
		if anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
	

func on_hover_exit():
	# Block all hover logic if under level_status (clock)
	if get_parent() and get_parent().name == "level_status":
		return
	# Always call hover exit logic
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover_exit(self)
	# Use AnimationPlayer to reset position if available
	var anim_player = get_parent().get_node_or_null("AnimationPlayer")
	if anim_player:
		if anim_player.has_animation("RESET"):
			anim_player.play("RESET")
	

func interact(object_interacted: object_class):
	# Block all interaction if under level_status (clock)
	if get_parent() and get_parent().name == "level_status":
		return
	print("interact called for ", object_name)
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_entrance(level_number, object_interacted)
