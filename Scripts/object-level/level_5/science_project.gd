extends object_class

var area_entered_objects : Array = []
var is_dreamer_here : bool = false
var is_soda_here : bool = false
@onready var rocket = $"../rocket"

func _ready():
	print("SCIENCE PROJECT: ",get_rid())

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	#	DREAMER/KID
	if area.name == "dreamer" and get_parent().name != "object_position":
		area_entered_objects.append(area)
		is_dreamer_here = true
	#	SODA
	elif area.name == "soda" and get_parent().name != "object_position":
		area_entered_objects.append(area)
		is_soda_here = true

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	#	DREAMER/KID
	if area.name == "dreamer" and get_parent().name != "object_position":
		area_entered_objects.erase(area)
		is_dreamer_here = false
	#	SODA
	elif area.name == "soda" and get_parent().name != "object_position":
		area_entered_objects.erase(area)
		is_soda_here = true
