extends Node2D

@onready var ui_sfx := {
	"hover": $sfx/ui_sfx/hover_sound,
	"click": $sfx/ui_sfx/click_sound,
	"page_turn": $sfx/ui_sfx/page_turn_sound
}

@onready var music := {
	"main_bgm": $music/main_bgm,
	"final_level_bgm": $music/final_level_bgm
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
			if player.pitch_scale > 0.0:
				player.pitch_scale += delta

# SET VOLUME FOR A SPECIFIC SFX
func set_sfx_volume(sfx_name: String, volume_db: float) -> void:
	if sfx.has(sfx_name):
		var player = sfx[sfx_name]
		if player is AudioStreamPlayer2D:
			player.volume_db = volume_db

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

# AMBIENCE MUSIC 
func play_ambience_music(music_name: String) -> void:
	if has_node("music/ambience/" + music_name):
		var player = get_node("music/ambience/" + music_name)
		if player is AudioStreamPlayer2D:
			player.play()

func stop_ambience_music(music_name: String) -> void:
	if has_node("music/ambience/" + music_name):
		var player = get_node("music/ambience/" + music_name)
		if player is AudioStreamPlayer2D:
			player.stop()

func set_ambience_music_volume(music_name: String, volume: float) -> void:
	if has_node("music/ambience/" + music_name):
		var player = get_node("music/ambience/" + music_name)
		if player is AudioStreamPlayer2D:
			player.volume_db = volume

func _ready():
	_set_bus_for_all_sfx()
	_set_bus_for_all_music()
	_setup_music_looping()

# Recursively set bus for all AudioStreamPlayer2D nodes under sfx
func _set_bus_for_all_sfx():
	if has_node("sfx"):
		_set_bus_recursive($sfx, "sfx")

func _set_bus_for_all_music():
	if has_node("music"):
		_set_bus_recursive($music, "music")

func _set_bus_recursive(parent: Node, bus_name: String):
	for child in parent.get_children():
		if child is AudioStreamPlayer2D:
			if child.bus == "Master":
				child.bus = bus_name
		else:
			_set_bus_recursive(child, bus_name)

# Setup looping by connecting to finished signal
func _setup_music_looping():
	# Setup main_bgm looping
	if music.has("main_bgm"):
		var player = music["main_bgm"]
		if not player.finished.is_connected(_loop_music):
			player.finished.connect(_loop_music.bind("main_bgm"))
	
	# Setup final_level_bgm looping
	if music.has("final_level_bgm"):
		var player = music["final_level_bgm"]
		if not player.finished.is_connected(_loop_music):
			player.finished.connect(_loop_music.bind("final_level_bgm"))
	
	# Setup space_ambience looping (for level 12)
	if has_node("music/ambience/space_ambience"):
		var player = $music/ambience/space_ambience
		if not player.finished.is_connected(_loop_ambience):
			player.finished.connect(_loop_ambience.bind("space_ambience"))
	
	# Setup bird_chirp looping (for levels 1-11)
	if has_node("music/ambience/bird_chirp"):
		var player = $music/ambience/bird_chirp
		if not player.finished.is_connected(_loop_ambience):
			player.finished.connect(_loop_ambience.bind("bird_chirp"))
	
	# Setup cricket looping (for levels 1-11)
	if has_node("music/ambience/cricket"):
		var player = $music/ambience/cricket
		if not player.finished.is_connected(_loop_ambience):
			player.finished.connect(_loop_ambience.bind("cricket"))
	
	# Setup idle_wind looping (for levels 1-11)
	if has_node("music/ambience/idle_wind"):
		var player = $music/ambience/idle_wind
		if not player.finished.is_connected(_loop_ambience):
			player.finished.connect(_loop_ambience.bind("idle_wind"))

func _loop_music(music_name: String):
	if music.has(music_name):
		music[music_name].play()

func _loop_ambience(ambience_name: String):
	if has_node("music/ambience/" + ambience_name):
		get_node("music/ambience/" + ambience_name).play()

# Play all level ambience sounds (bird_chirp, cricket, idle_wind) for levels 1-11
func play_level_ambience():
	play_ambience_music("bird_chirp")
	play_ambience_music("cricket")
	play_ambience_music("idle_wind")

# Stop all level ambience sounds
func stop_level_ambience():
	stop_ambience_music("bird_chirp")
	stop_ambience_music("cricket")
	stop_ambience_music("idle_wind")

# Volume control for buses
func set_sfx_bus_volume(volume: float) -> void:
	var db = linear_to_db(volume / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), db)

func set_music_bus_volume(volume: float) -> void:
	var db = linear_to_db(volume / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), db)
