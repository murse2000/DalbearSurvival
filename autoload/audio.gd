extends Node

## Tiny pooled audio player with music ducking.

const SFX := ["shoot", "hit", "kill", "pickup", "heal", "hurt", "levelup",
	"click", "laser", "pulse", "boss", "victory", "gameover", "dash", "ultimate"]
const MUSIC := "res://assets/audio/music_loop.ogg"

var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _pool_index := 0
var _last := {}
var _music: AudioStreamPlayer
var _music_base := -15.0
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for name in SFX:
		var path := "res://assets/audio/%s.wav" % name
		if ResourceLoader.exists(path):
			_streams[name] = load(path)
	for i in 18:
		var p := AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.process_mode = Node.PROCESS_MODE_ALWAYS
	_music.volume_db = -40.0
	add_child(_music)
	var stream = load(MUSIC)
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_music.stream = stream
	_music.play()
	_duck_to(_music_base, 3.0)


func play(name: String, pitch: float = 1.0, db: float = 0.0) -> void:
	if not _streams.has(name):
		return
	var now := Time.get_ticks_msec()
	var gap := 30
	if name == "hit":
		gap = 45
	elif name == "kill":
		gap = 60
	elif name == "pickup":
		gap = 25
	elif name in ["shoot", "laser"]:
		gap = 60
	if _last.has(name) and now - int(_last[name]) < gap:
		return
	_last[name] = now
	var p := _pool[_pool_index]
	_pool_index = (_pool_index + 1) % _pool.size()
	p.stream = _streams[name]
	p.pitch_scale = clampf(pitch, 0.5, 2.0)
	p.volume_db = db
	p.play()


func play_pickup(value: int) -> void:
	var pitch := 1.0 + clampf(float(value) / 30.0, 0.0, 0.35)
	play("pickup", pitch, -2.0)


func play_click() -> void:
	play("click", randf_range(0.96, 1.05), -3.0)
	Haptics.play("tick")


func duck_music(on: bool) -> void:
	_duck_to(_music_base - 6.0 if on else _music_base, 0.35)


func set_music_volume(db: float, fade: float = 0.5) -> void:
	_music_base = db
	_duck_to(db, fade)


func set_music_pitch(pitch: float) -> void:
	if _music != null:
		_music.pitch_scale = clampf(pitch, 0.7, 1.35)


func _duck_to(db: float, duration: float) -> void:
	if _music == null:
		return
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_property(_music, "volume_db", db, duration)


func stop_music(fade: float = 1.0) -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_property(_music, "volume_db", -50.0, fade)
	_music_tween.tween_callback(_music.stop)
