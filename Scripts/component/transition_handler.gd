extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func show_background() -> void:
	var bg = get_node("background")
	bg.visible = true
	if bg.has_node("game_animated_explosion_bg"):
		var anim = bg.get_node("game_animated_explosion_bg")
		if anim is AnimatedSprite2D:
			anim.frame = 0
			anim.play("default")
			
func remove_transition(transition_name: String) -> void:
	# Hide and queue_free the transition node after animation
	var layout = get_node("transition_layout")
	if layout.has_node(transition_name):
		var node = layout.get_node(transition_name)
		node.visible = false
		node.queue_free()

func show_node_child(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("set_visible"):
			child.visible = true
		show_node_child(child)

func show_transition (transition_name: String) -> void:
	var layout = get_node("transition_layout")
	if layout.has_node(transition_name):
		var node = layout.get_node(transition_name)
		node.visible = true 
		show_node_child(node)
		show_background()



