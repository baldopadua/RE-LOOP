extends Control

var logic: Control
@onready var sound_manager = $SoundManager

func _ready() -> void:
	logic = get_node("transition_logic")

func show_background() -> void:
	var bg = get_node("background")
	bg.visible = true
	if bg.has_node("game_animated_explosion_bg"):
		var anim = bg.get_node("game_animated_explosion_bg")
		if anim is AnimatedSprite2D:
			anim.frame = 0
			anim.play("default")
			
func show_child_node(node_name: String) -> void:
	if logic and logic.has_node(node_name):
		var node = logic.get_node(node_name)
		_show_node_and_children(node)

func _show_node_and_children(node: Node) -> void:
	node.visible = true
	for child in node.get_children():
		_show_node_and_children(child)

func show_main_to_game_transition() -> void:
	show_background()
	show_child_node("main_to_game")
	# Play wormhole sound
	if sound_manager:
		sound_manager.play_sfx("Climb")
	if logic:
		logic.play_plooy_falling_animation()
