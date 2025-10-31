extends object_class 

var level_number: int = 0

func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)
	var object_lvl_num = object_name.replace("enter_", "").strip_edges()
	level_number = object_lvl_num.to_int()
	print(level_number)

func on_hover_enter():
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover(level_number, self)

func on_hover_exit():
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover_exit(self)


func interact(object_interacted: object_class):
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_entrance(level_number, object_interacted)
