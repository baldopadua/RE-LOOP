extends Node2D

@onready var ui_sfx := {
	"hover": $sfx/ui_sfx/hover_sound,
	"click": $sfx/ui_sfx/click_sound,
	"page_turn": $sfx/ui_sfx/page_turn_sound
}

@onready var music := {
	"main_bgm": $music/main_bgm
}

# Recursively collect all AudioStreamPlayer2D nodes under a given node
func _collect_sfx_nodes(parent: Node, dict: Dictionary, prefix: String = ""):
	for child in parent.get_children():
		if child is AudioStreamPlayer2D:
			dict[prefix + child.name] = child
		else:
			_collect_sfx_nodes(child, dict, prefix)

# SFX dictionary for all sfx (including level-specific)
@onready var sfx := _init_sfx()

func _init_sfx() -> Dictionary:
	var dict := {}
	if has_node("sfx"):
		_collect_sfx_nodes($sfx, dict)
	return dict

# --- UI SFX ---
func play_ui(sound_name: String) -> void:
	if ui_sfx.has(sound_name):
		ui_sfx[sound_name].play()

func stop_ui(sound_name: String) -> void:
	if ui_sfx.has(sound_name):
		ui_sfx[sound_name].stop()

# --- Music ---
func play_music(music_name: String) -> void:
	if music.has(music_name):
		music[music_name].play()

func stop_music(music_name: String) -> void:
	if music.has(music_name):
		music[music_name].stop()

# --- General SFX (for level/global sfx) ---
func play_sfx(sfx_name: String) -> void:
	if sfx.has(sfx_name):
		sfx[sfx_name].play()

func stop_sfx(sfx_name: String) -> void:
	if sfx.has(sfx_name):
		sfx[sfx_name].stop()

# --- Set pitch scale for a specific SFX ---
func set_sfx_pitch_scale(sfx_name: String, pitch: float) -> void:
	if sfx.has(sfx_name):
		var player = sfx[sfx_name]
		if player is AudioStreamPlayer2D:
			player.pitch_scale = pitch

# --- Adjust pitch scale for a specific SFX by delta ---
func adjust_sfx_pitch_scale(sfx_name: String, delta: float) -> void:
	if sfx.has(sfx_name):
		var player = sfx[sfx_name]
		if player is AudioStreamPlayer2D:
			player.pitch_scale += delta