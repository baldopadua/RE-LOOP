extends object_class 

var level_number: int = 0
var original_area_position: Vector2

func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)
	var object_lvl_num = object_name.replace("enter_", "").strip_edges()
	level_number = object_lvl_num.to_int()
	print(level_number)
	original_area_position = position

func on_hover_enter():
	# Always call hover logic
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover(level_number, self)
	# Use AnimationPlayer for hover animation if available
	var anim_player = get_parent().get_node_or_null("AnimationPlayer")
	if anim_player:
		var anim_name = "enter_%d_upward" % level_number
		if anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
	

func on_hover_exit():
	# Always call hover exit logic
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover_exit(self)
	# Use AnimationPlayer to reset position if available
	var anim_player = get_parent().get_node_or_null("AnimationPlayer")
	if anim_player:
		if anim_player.has_animation("RESET"):
			anim_player.play("RESET")
	

func interact(object_interacted: object_class):
	print("interact called for ", object_name)
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_entrance(level_number, object_interacted)
