extends AudioStreamPlayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const AMBIENT = preload("res://music/ambient.ogg")
const EERIE = preload("res://music/eerie1.ogg")
const BATTLE = preload("res://music/horror_battle.ogg")
const DANGER = preload("res://music/horror_danger.ogg")
const EXPLORE = preload("res://music/horror_explore.ogg")
const MEMORIES = preload("res://music/memories.ogg")

var current_track: AudioStream

func play_track(track_name: AudioStream):
    if track_name != current_track:
        var fade_in = false
        if playing:
            animation_player.play("fade_out")
            await animation_player.animation_finished
            fade_in = true

        current_track = track_name
        stream = track_name
        stream.loop = true
        play()

        if fade_in:
            animation_player.play("fade_in")
