extends object_class

var area_entered_objects : Array = []

func _on_area_shape_entered(area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area_rid == rid_from_int64(1271310319616) and get_parent().name != "object_position":
		area_entered_objects.append(area)
