extends Node

@onready var ui_sfx = {
    "hover": $sfx/ui_sfx/hover_sound,
    "click": $sfx/ui_sfx/click_sound,
    "page_turn": $sfx/ui_sfx/page_turn_sound
}

@onready var music = {
    "main_bgm": $music/main_bgm
}

func play_ui(sound_name: String) -> void:
    if ui_sfx.has(sound_name):
        ui_sfx[sound_name].play()

func stop_ui(sound_name: String) -> void:
    if ui_sfx.has(sound_name):
        ui_sfx[sound_name].stop()

func play_music(music_name: String) -> void:
    if music.has(music_name):
        music[music_name].play()

func stop_music(music_name: String) -> void:
    if music.has(music_name):
        music[music_name].stop()