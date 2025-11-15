extends Control

var sfx_volume_label: Label
var music_volume_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$settings_box/sfx_slider.value = 100
	$settings_box/music_slider.value = 100
	sfx_volume_label = $settings_box/sfx_slider/sfx_volume
	music_volume_label = $settings_box/music_slider/music_volume
	# Initialize label values to match slider values
	sfx_volume_label.text = str(int($settings_box/sfx_slider.value)) + "%"
	music_volume_label.text = str(int($settings_box/music_slider.value)) + "%"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_music_slider_value_changed(value: float) -> void:
	if music_volume_label:
		music_volume_label.text = str(int(value)) + "%"
		var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)
		if sound_manager:
			sound_manager.set_music_bus_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	if sfx_volume_label:
		sfx_volume_label.text = str(int(value)) + "%"
		var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)
		if sound_manager:
			sound_manager.set_sfx_bus_volume(value)
