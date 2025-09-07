extends Control

var plooy_tween: Tween = null

func play_plooy_falling_animation():
	var plooy = get_node("main_to_game/plooy")
	var top_marker = plooy.get_node("top_position")
	var fall_marker = plooy.get_node("fall_position")
	var shrink_marker = plooy.get_node("shrink_position")
	
	if not is_instance_valid(plooy):
		return
	
	# Stop previous tween if running
	if plooy_tween and plooy_tween.is_running():
		plooy_tween.kill()
	
	# Set plooy to top_position marker (start ng hulog)
	plooy.position = top_marker.position
	plooy.rotation = 0.0
	plooy.scale = Vector2(1, 1)
	plooy.modulate.a = 1.0
	plooy.visible = true
	
	plooy_tween = create_tween()
	# Delay bago magsimula ang hulog
	plooy_tween.tween_interval(0.1)
	# Hulog: tween position from top_position to fall_position (bounce)
	plooy_tween.tween_property(
		plooy, "position", fall_marker.position, 0.8
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Delay bago mag spin/shrink
	plooy_tween.tween_interval(0.1)
	# Spin/shrink/fade papuntang shrink_position
	plooy_tween.tween_callback(Callable(self, "_plooy_spin_and_shrink").bind(plooy, shrink_marker.position))

func _plooy_spin_and_shrink(plooy, shrink_pos):
	if not is_instance_valid(plooy):
		return
	plooy.rotation = 0.0
	plooy.scale = Vector2(1, 1)
	
	# Stop previous tween if running
	if plooy_tween and plooy_tween.is_running():
		plooy_tween.kill()
	
	plooy_tween = create_tween()
	plooy_tween.tween_property(plooy, "position", shrink_pos, 2.2)
	plooy_tween.parallel().tween_property(plooy, "rotation", -2 * PI, 2.2)
	plooy_tween.parallel().tween_property(plooy, "scale", Vector2(0, 0), 2.2)
	plooy_tween.parallel().tween_property(plooy, "modulate:a", 0.0, 2.2)
	plooy_tween.tween_callback(Callable(self, "_hide_plooy").bind(plooy))

func _hide_plooy(plooy):
	if is_instance_valid(plooy):
		plooy.visible = false