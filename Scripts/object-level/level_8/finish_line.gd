extends object_class

var array = []

func _on_area_entered(area: Area2D) -> void:
	if area is object_class:
		if area.object_name == "hare" or area.object_name == "turtle":
			array.append(area)
			print("FINISH LINE ARRAY: ", array)
