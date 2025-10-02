extends object_class

var area_entered_objects : Array = []

func _ready():
	print("SODA: ",get_rid())

func interact(_obj):
	return false
