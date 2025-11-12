extends object_class 

var level_number: int = 0
var original_area_position: Vector2

# Reference offsets for each level (from Animation resource)
const HOVER_OFFSETS := {
	1: Vector2(-12, 23),
	2: Vector2(-12, 7),
	3: Vector2(-12, -2),
	4: Vector2(-12, -8),
	5: Vector2(0, -17),
	6: Vector2(1, -21),
	7: Vector2(11, -16),
	8: Vector2(12, -9),
	9: Vector2(13, 3),
	10: Vector2(12, 8),
	11: Vector2(13, 16),
	12: Vector2(1, 15),
}

func _ready() -> void:
	is_enterable = true
	print("Lobby available: ", object_name)
	var object_lvl_num = object_name.replace("enter_", "").strip_edges()
	level_number = object_lvl_num.to_int()
	print(level_number)
	# Store original position of Area2D for hover animation
	original_area_position = position

func on_hover_enter():
	# Animate Area2D position up on hover
	var offset = HOVER_OFFSETS.get(level_number, Vector2.ZERO)
	var tween = create_tween()
	tween.tween_property(self, "position", original_area_position + offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover(level_number, self)

func on_hover_exit():
	# Animate Area2D back to original position
	var tween = create_tween()
	tween.tween_property(self, "position", original_area_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_hover_exit(self)


func interact(object_interacted: object_class):
	var enter_lobby = preload("res://Scripts/object-level/level_lobby/enter_lobby.gd")
	enter_lobby.handle_level_entrance(level_number, object_interacted)
