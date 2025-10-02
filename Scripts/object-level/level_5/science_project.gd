extends object_class

var area_entered_objects : Array = []
var is_dreamer_here : bool = false
var is_soda_here : bool = false
@onready var rocket = $"../rocket"

func _on_area_shape_entered(area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	#	DREAMER/KID
	if area_rid == rid_from_int64(1322849927171) and get_parent().name != "object_position":
		area_entered_objects.append(area)
		is_dreamer_here = true
	#	SODA
	elif area_rid == rid_from_int64(1378684502020) and get_parent().name != "object_position":
		area_entered_objects.append(area)
		is_soda_here = true

func _on_area_shape_exited(area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	#	DREAMER/KID
	if area_rid == rid_from_int64(1322849927171) and get_parent().name != "object_position":
		area_entered_objects.erase(area)
		is_dreamer_here = false
	#	SODA
	elif area_rid == rid_from_int64(1378684502020) and get_parent().name != "object_position":
		area_entered_objects.erase(area)
		is_soda_here = true
