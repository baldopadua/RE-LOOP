extends Node2D

@onready var ui_sfx := {
	"hover": $sfx/ui_sfx/hover_sound,
	"click": $sfx/ui_sfx/click_sound,
	"page_turn": $sfx/ui_sfx/page_turn_sound
}

@onready var music := {
	"main_bgm": $music/main_bgm
}

# RECURSIVELY COLLECT ALL AUDIOSTREAMPLAYER2D NODES UNDER A GIVEN NODE
func _collect_sfx_nodes(parent: Node, dict: Dictionary, prefix: String = ""):
	for child in parent.get_children():
		if child is AudioStreamPlayer2D:
			dict[prefix + child.name] = child
		else:
			_collect_sfx_nodes(child, dict, prefix)

# SFX DICTIONARY FOR ALL SFX (INCLUDING LEVEL-SPECIFIC)
@onready var sfx := _init_sfx()

func _init_sfx() -> Dictionary:
	var dict := {}
	if has_node("sfx"):
		_collect_sfx_nodes($sfx, dict)
		if $sfx/global_sfx.has_node("finish_level_sfx"):
			dict["finish_level_sfx"] = $sfx/global_sfx/finish_level_sfx
	return dict

# GENERAL SFX (FOR LEVEL/GLOBAL SFX)
func play_sfx(sfx_name: String) -> void:
	if sfx.has(sfx_name):
		sfx[sfx_name].play()

func stop_sfx(sfx_name: String) -> void:
	if sfx.has(sfx_name):
		sfx[sfx_name].stop()

# SET PITCH SCALE FOR A SPECIFIC SFX 
func set_sfx_pitch_scale(sfx_name: String, pitch: float) -> void:
	if sfx.has(sfx_name):
		var player = sfx[sfx_name]
		if player is AudioStreamPlayer2D:
			player.pitch_scale = pitch

# ADJUST PITCH SCALE FOR A SPECIFIC SFX 
func adjust_sfx_pitch_scale(sfx_name: String, delta: float) -> void:
	if sfx.has(sfx_name):
		var player = sfx[sfx_name]
		if player is AudioStreamPlayer2D:
			player.pitch_scale += delta

# UI SFX
func play_ui(sound_name: String) -> void:
	if ui_sfx.has(sound_name):
		ui_sfx[sound_name].play()

func stop_ui(sound_name: String) -> void:
	if ui_sfx.has(sound_name):
		ui_sfx[sound_name].stop()

# MUSIC
func play_music(music_name: String) -> void:
	if music.has(music_name):
		music[music_name].play()

func stop_music(music_name: String) -> void:
	if music.has(music_name):
		music[music_name].stop()


# PLAYER SFX
@onready var player_sfx := _init_player_sfx()

func _init_player_sfx() -> Dictionary:
	var dict := {}
	if has_node("sfx/player_sfx"):
		_collect_sfx_nodes($sfx/player_sfx, dict)
	return dict


func play_player_sfx(sfx_name: String) -> void:
	if player_sfx.has(sfx_name):
		player_sfx[sfx_name].play()

func stop_player_sfx(sfx_name: String) -> void:
	if player_sfx.has(sfx_name):
		player_sfx[sfx_name].stop()


# GLOBAL SFX: finish/reset level sound effects 
func play_finish_level_sfx():
	if sfx.has("finish_level_sfx"):
		var finish_sfx = sfx["finish_level_sfx"]
		for sfx_node in finish_sfx.get_children():
			if sfx_node.has_method("play"):
				sfx_node.play()

func play_reset_level_sfx():
	if has_node("sfx/global_sfx/reset_level_sfx"):
		var reset_sfx = $sfx/global_sfx/reset_level_sfx
		for sfx_node in reset_sfx.get_children():
			if sfx_node.has_method("play"):
				sfx_node.play()

# AMBIENCE SFX 
func play_ambience_sfx(sfx_name: String) -> void:
	if has_node("sfx/global_sfx/ambience_sfx/" + sfx_name):
		var player = get_node("sfx/global_sfx/ambience_sfx/" + sfx_name)
		if player is AudioStreamPlayer2D:
			if player.stream and player.stream.has_method("set_loop"):
				player.stream.set_loop(true)
			elif "loop" in player.stream:
				player.stream.loop = true
			player.play()

func stop_ambience_sfx(sfx_name: String) -> void:
	if has_node("sfx/global_sfx/ambience_sfx/" + sfx_name):
		var player = get_node("sfx/global_sfx/ambience_sfx/" + sfx_name)
		if player is AudioStreamPlayer2D:
			player.stop()

func set_ambience_volume(sfx_name: String, volume: float) -> void:
	if has_node("sfx/global_sfx/ambience_sfx/" + sfx_name):
		var player = get_node("sfx/global_sfx/ambience_sfx/" + sfx_name)
		if player is AudioStreamPlayer2D:
			player.volume_db = volume
