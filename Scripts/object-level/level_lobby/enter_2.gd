extends object_class 

func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)

func on_hover_enter():
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover(2, self)

func on_hover_exit():
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover_exit(self)


func interact(object_interacted: object_class):
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_entrance(2, object_interacted)


