extends Node

## Context-aware haptics hub for phones and connected gamepads.
## The same gameplay event drives Android/iOS vibration and, when available,
## the weak/strong motors of every connected controller.

const EVENTS := {
	"tick": [
		{"delay": 0.0, "duration": 0.025, "weak": 0.16, "strong": 0.06, "mobile": 12},
	],
	"dash": [
		{"delay": 0.0, "duration": 0.055, "weak": 0.3, "strong": 0.12, "mobile": 22},
	],
	"hurt": [
		{"delay": 0.0, "duration": 0.13, "weak": 0.45, "strong": 0.92, "mobile": 90},
		{"delay": 0.12, "duration": 0.08, "weak": 0.22, "strong": 0.4, "mobile": 45},
	],
	"heal": [
		{"delay": 0.0, "duration": 0.08, "weak": 0.15, "strong": 0.32, "mobile": 35},
	],
	"levelup": [
		{"delay": 0.0, "duration": 0.09, "weak": 0.22, "strong": 0.58, "mobile": 50},
		{"delay": 0.1, "duration": 0.12, "weak": 0.16, "strong": 0.42, "mobile": 55},
	],
	"relic": [
		{"delay": 0.0, "duration": 0.08, "weak": 0.28, "strong": 0.66, "mobile": 55},
	],
	"combo": [
		{"delay": 0.0, "duration": 0.05, "weak": 0.2, "strong": 0.38, "mobile": 28},
	],
	"boss": [
		{"delay": 0.0, "duration": 0.18, "weak": 0.25, "strong": 0.9, "mobile": 120},
		{"delay": 0.22, "duration": 0.25, "weak": 0.15, "strong": 0.65, "mobile": 150},
	],
	"miniboss": [
		{"delay": 0.0, "duration": 0.12, "weak": 0.22, "strong": 0.62, "mobile": 85},
		{"delay": 0.16, "duration": 0.16, "weak": 0.12, "strong": 0.42, "mobile": 110},
	],
	"boss_down": [
		{"delay": 0.0, "duration": 0.12, "weak": 0.22, "strong": 0.72, "mobile": 90},
		{"delay": 0.14, "duration": 0.3, "weak": 0.12, "strong": 0.5, "mobile": 160},
	],
	"ultimate": [
		{"delay": 0.0, "duration": 0.24, "weak": 0.2, "strong": 1.0, "mobile": 180},
		{"delay": 0.2, "duration": 0.18, "weak": 0.1, "strong": 0.5, "mobile": 100},
	],
	"victory": [
		{"delay": 0.0, "duration": 0.16, "weak": 0.2, "strong": 0.72, "mobile": 80},
		{"delay": 0.2, "duration": 0.34, "weak": 0.16, "strong": 0.55, "mobile": 200},
	],
	"defeat": [
		{"delay": 0.0, "duration": 0.42, "weak": 0.18, "strong": 0.55, "mobile": 240},
	],
	"achievement": [
		{"delay": 0.0, "duration": 0.08, "weak": 0.2, "strong": 0.5, "mobile": 40},
		{"delay": 0.1, "duration": 0.08, "weak": 0.2, "strong": 0.5, "mobile": 40},
	],
	"heartbeat": [
		{"delay": 0.0, "duration": 0.09, "weak": 0.1, "strong": 0.22, "mobile": 35},
	],
}

var _mobile := false
var _generation := 0
var _low_hp := false
var _low_hp_severity := 0.0
var _low_hp_timer := 0.0
var _last_kill_milestone := 0
var _last_event := ""
var _play_count := 0


func _ready() -> void:
	_mobile = OS.has_feature("mobile")
	Settings.changed.connect(_on_settings_changed)
	Game.run_ended.connect(_on_run_ended)
	Game.achievement_unlocked.connect(_on_achievement_unlocked)
	Game.kills_changed.connect(_on_kills_changed)


func play(event_id: String, strength: float = 1.0) -> void:
	var scale := Settings.haptic_scale_value()
	if scale <= 0.0:
		return
	var pattern: Array = EVENTS.get(event_id, [])
	if pattern.is_empty():
		return
	_last_event = event_id
	_play_count += 1
	_generation += 1
	var token := _generation
	_stop_controllers()
	_run_pattern(pattern, token, scale * clampf(strength, 0.25, 1.5))


func set_low_hp(active: bool, severity: float = 0.0) -> void:
	_low_hp = active
	_low_hp_severity = clampf(severity, 0.0, 1.0)
	if not active:
		_low_hp_timer = 0.0


func is_available() -> bool:
	return _mobile or Input.get_connected_joypads().size() > 0


func last_event() -> String:
	return _last_event


func play_count() -> int:
	return _play_count


func _process(delta: float) -> void:
	if not _low_hp or Settings.haptic_scale_value() <= 0.0:
		return
	if get_tree().paused:
		return
	_low_hp_timer -= delta
	if _low_hp_timer <= 0.0:
		play("heartbeat", 0.55 + _low_hp_severity * 0.45)
		_low_hp_timer = lerpf(1.2, 0.72, _low_hp_severity)


func _run_pattern(pattern: Array, token: int, scale: float) -> void:
	for pulse in pattern:
		var delay := float(pulse.get("delay", 0.0))
		if delay > 0.0:
			await get_tree().create_timer(delay, true, false, true).timeout
		if token != _generation:
			return
		_pulse(pulse, scale)


func _pulse(pulse: Dictionary, scale: float) -> void:
	var weak := clampf(float(pulse.get("weak", 0.0)) * scale, 0.0, 1.0)
	var strong := clampf(float(pulse.get("strong", 0.0)) * scale, 0.0, 1.0)
	var duration := maxf(0.01, float(pulse.get("duration", 0.05)))
	for device in Input.get_connected_joypads():
		Input.start_joy_vibration(device, weak, strong, duration)
	if _mobile:
		var mobile_ms := int(clampf(float(pulse.get("mobile", 30.0)) * (0.65 + scale * 0.5), 1.0, 250.0))
		Input.vibrate_handheld(mobile_ms, clampf(scale, 0.0, 1.0))


func _stop_controllers() -> void:
	for device in Input.get_connected_joypads():
		Input.stop_joy_vibration(device)


func _on_settings_changed() -> void:
	if Settings.haptic_scale_value() <= 0.0:
		_generation += 1
		_stop_controllers()
		_low_hp_timer = 0.0


func _on_run_ended(victory: bool, _boss_killed: bool) -> void:
	_low_hp = false
	play("victory" if victory else "defeat")


func _on_achievement_unlocked(_id: String) -> void:
	play("achievement")


func _on_kills_changed(kills: int) -> void:
	if kills < _last_kill_milestone:
		_last_kill_milestone = 0
	var milestone := 0
	for m in [10, 25, 50, 100, 150, 200]:
		if kills >= m:
			milestone = m
	if milestone > _last_kill_milestone:
		_last_kill_milestone = milestone
		play("combo", 0.8)
