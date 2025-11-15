extends Control

var sfx_volume_label: Label
var music_volume_label: Label

var last_sfx_volume: float = 100
var last_music_volume: float = 100


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
		# If not muted, update last_music_volume
		if value > 0:
			last_music_volume = value
		# Update mute button texture state
		var mute_btn = $settings_box/music_mute_button
		if mute_btn:
			mute_btn.set_pressed(value == 0)

func _on_sfx_slider_value_changed(value: float) -> void:
	if sfx_volume_label:
		sfx_volume_label.text = str(int(value)) + "%"
		var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)
		if sound_manager:
			sound_manager.set_sfx_bus_volume(value)
		# If not muted, update last_sfx_volume
		if value > 0:
			last_sfx_volume = value
		# Update mute button texture state
		var mute_btn = $settings_box/sfx_mute_button
		if mute_btn:
			mute_btn.set_pressed(value == 0)



func _on_music_mute_button_pressed() -> void:
	var slider = $settings_box/music_slider
	var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)
	if slider.value > 0:
		last_music_volume = slider.value
		slider.value = 0
	else:
		slider.value = last_music_volume
	# Update label and bus volume
	music_volume_label.text = str(int(slider.value)) + "%"
	if sound_manager:
		sound_manager.set_music_bus_volume(slider.value)


func _on_sfx_mute_button_pressed() -> void:
	var slider = $settings_box/sfx_slider
	var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)
	if slider.value > 0:
		last_sfx_volume = slider.value
		slider.value = 0
	else:
		slider.value = last_sfx_volume
	# Update label and bus volume
	sfx_volume_label.text = str(int(slider.value)) + "%"
	if sound_manager:
		sound_manager.set_sfx_bus_volume(slider.value)
