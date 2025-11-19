extends Node2D

signal show_progress_bar(visible: bool)
signal set_progress(value: float)

@onready var bar = $TextureProgressBar

func _ready() -> void:
	bar.visible = false

func show_bar(is_visible: bool) -> void:
	bar.visible = is_visible
	emit_signal("show_progress_bar", is_visible)

func set_bar_progress(value: float) -> void:
	bar.value = clamp(value, bar.min_value, bar.max_value)
	emit_signal("set_progress", bar.value)
