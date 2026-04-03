extends Node

const STREAMS := {
	"ambient": preload("res://assets/audio/ambient_hum.wav"),
	"jump": preload("res://assets/audio/jump.wav"),
	"interact": preload("res://assets/audio/interact.wav"),
	"switch": preload("res://assets/audio/switch.wav"),
	"success": preload("res://assets/audio/success.wav"),
	"fail": preload("res://assets/audio/fail.wav"),
}

const MUSIC_SAMPLE_RATE := 44100.0
const THIRD_RATIO := 1.25992105
const FIFTH_RATIO := 1.49830708

const THEME_PROFILES := {
	"title": {
		"progression": [220.0, 261.63, 196.0, 246.94],
		"bpm": 90.0,
	},
	"level1": {
		"progression": [246.94, 293.66, 220.0, 277.18],
		"bpm": 98.0,
	},
	"level2": {
		"progression": [277.18, 329.63, 246.94, 311.13],
		"bpm": 108.0,
	},
	"level3": {
		"progression": [311.13, 369.99, 293.66, 349.23],
		"bpm": 118.0,
	},
}

var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var music_generator: AudioStreamGenerator
var music_playback: AudioStreamGeneratorPlayback
var active_theme_id := "title"
var level_music_keys := {
	1: "level1",
	2: "level2",
	3: "level3",
}
var music_time := 0.0


func _ready() -> void:
	music_player = _build_player("Music", -9.0)
	ambient_player = _build_player("Ambient", -30.0)
	sfx_players.append(_build_player("SfxA", -8.0))
	sfx_players.append(_build_player("SfxB", -8.0))

	_configure_loop(STREAMS.ambient)
	ambient_player.stream = STREAMS.ambient

	music_generator = AudioStreamGenerator.new()
	music_generator.mix_rate = MUSIC_SAMPLE_RATE
	music_generator.buffer_length = 0.4
	music_player.stream = music_generator
	music_player.play()
	music_playback = music_player.get_stream_playback()

	ambient_player.finished.connect(_on_ambient_finished)
	GameManager.level_loaded.connect(_on_level_loaded)
	GameManager.title_requested.connect(_on_title_requested)


func start_gameplay_audio() -> void:
	if not music_player.playing:
		music_player.play()
		music_playback = music_player.get_stream_playback()
	if not ambient_player.playing:
		ambient_player.play()


func play_sfx(name: String) -> void:
	if not STREAMS.has(name):
		return

	for player in sfx_players:
		if not player.playing:
			player.stream = STREAMS[name]
			player.play()
			return

	sfx_players[0].stop()
	sfx_players[0].stream = STREAMS[name]
	sfx_players[0].play()


func _on_level_loaded(_level_name: String, _objective: String, index: int, _total: int) -> void:
	active_theme_id = level_music_keys.get(index, "title")
	_restart_music()


func _on_title_requested() -> void:
	active_theme_id = "title"
	_restart_music()


func _on_ambient_finished() -> void:
	ambient_player.play()


func _process(_delta: float) -> void:
	if not music_player.playing:
		music_player.play()
		music_playback = music_player.get_stream_playback()

	if music_playback == null:
		music_playback = music_player.get_stream_playback()
		if music_playback == null:
			return

	_fill_music_buffer()


func _restart_music() -> void:
	music_time = 0.0
	if not music_player.playing:
		music_player.play()
		music_playback = music_player.get_stream_playback()
	if music_playback and music_playback.has_method("clear_buffer"):
		music_playback.clear_buffer()


func _fill_music_buffer() -> void:
	var frames_available := music_playback.get_frames_available()
	for _i in range(frames_available):
		var sample := _generate_music_sample(music_time)
		var pan := sin(music_time * 0.7) * 0.08
		var left := clampf(sample * (1.0 - pan), -1.0, 1.0)
		var right := clampf(sample * (1.0 + pan), -1.0, 1.0)
		music_playback.push_frame(Vector2(left, right))
		music_time += 1.0 / MUSIC_SAMPLE_RATE


func _generate_music_sample(time_value: float) -> float:
	var theme: Dictionary = THEME_PROFILES.get(active_theme_id, THEME_PROFILES["title"])
	var progression: Array = theme["progression"]
	var bpm: float = theme["bpm"]
	var beat := 60.0 / bpm
	var bar := beat * 4.0
	var root: float = progression[int(floor(time_value / bar)) % progression.size()]
	var third := root * THIRD_RATIO
	var fifth := root * FIFTH_RATIO

	var beat_phase := fposmod(time_value, beat) / beat
	var gate := 1.0 if beat_phase < 0.24 else 0.32

	var lead_step := int(floor(time_value / (beat * 0.5))) % 8
	var arp := [
		root * 2.0,
		third * 2.0,
		fifth * 2.0,
		root * 4.0,
		fifth * 2.0,
		third * 2.0,
		root * 2.0,
		fifth * 2.0,
	]
	var lead_freq: float = arp[lead_step]

	var lead := 0.46 * _square_wave(lead_freq, time_value)
	lead += 0.18 * sin(TAU * lead_freq * 2.0 * time_value)

	var pad := 0.16 * sin(TAU * root * time_value)
	pad += 0.12 * sin(TAU * third * time_value)
	pad += 0.10 * sin(TAU * fifth * time_value)

	var kick_env := 0.0
	if beat_phase < 0.12:
		kick_env = 1.0 - (beat_phase / 0.12)
	var kick := 0.34 * kick_env * sin(TAU * 72.0 * time_value)

	var sample := gate * lead + pad + kick
	return clampf(sample * 0.72, -1.0, 1.0)


func _square_wave(freq: float, time_value: float) -> float:
	return 1.0 if sin(TAU * freq * time_value) >= 0.0 else -1.0


func _build_player(node_name: String, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.volume_db = volume_db
	add_child(player)
	return player


func _configure_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
