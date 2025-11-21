extends object_class
var pwede_na = false
var matched = false


func _on_area_entered(area: Area2D) -> void:
	if area is object_class and GlobalVariables.object_types.NONTOOL and pwede_na:
		if area.object_name == "rocket_statue" and is_pickupable and not get_parent().name.contains("AreaHandler"):
			pulse("green", $AnimatedSprite2D2)
			matched = true
			is_pickupable = false
