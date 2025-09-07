extends Control

var layout: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layout = get_node("transition_layout")

func show_background() -> void:
	var bg = get_node("background")
	bg.visible = true
	if bg.has_node("game_animated_explosion_bg"):
		var anim = bg.get_node("game_animated_explosion_bg")
		if anim is AnimatedSprite2D:
			anim.frame = 0
			anim.play("default")
			
# func remove_transition(transition_name: String) -> void:
# 	if layout and layout.has_node(transition_name):
# 		var node = layout.get_node(transition_name)
# 		node.visible = false
# 		node.queue_free()

func show_child_node(node_name: String) -> void:
	if layout and layout.has_node(node_name):
		var node = layout.get_node(node_name)
		_show_node_and_children(node)

func _show_node_and_children(node: Node) -> void:
	node.visible = true
	for child in node.get_children():
		_show_node_and_children(child)

func show_main_to_game_transition() -> void:
	show_background()
	show_child_node("main_to_game")
	if layout:
		layout.play_plooy_falling_animation()




