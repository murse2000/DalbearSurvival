extends Node

## Persistent display/feedback settings shared by the game and menus.

signal changed

const PATH := "user://dalbear_settings.cfg"
const QUALITY_KEYS := ["low", "balanced", "high"]
const SIZE_KEYS := ["small", "normal", "large"]

var bloom := true
var shake := true
var damage_numbers := true
var quality := "balanced"
var hud_size := "normal"
var joystick_side := "left"
var joystick_size := "normal"


func _ready() -> void:
	load_settings()


func set_option(key: String, value: bool) -> void:
	match key:
		"bloom":
			if bloom == value:
				return
			bloom = value
		"shake":
			if shake == value:
				return
			shake = value
		"damage_numbers":
			if damage_numbers == value:
				return
			damage_numbers = value
		_:
			return
	save_settings()
	changed.emit()


func get_option(key: String) -> bool:
	match key:
		"bloom":
			return bloom
		"shake":
			return shake
		"damage_numbers":
			return damage_numbers
	return true


func set_choice(key: String, value: String) -> void:
	match key:
		"quality":
			if not value in QUALITY_KEYS or quality == value:
				return
			quality = value
			if quality == "low":
				bloom = false
				damage_numbers = false
			elif quality == "high":
				bloom = true
				damage_numbers = true
		"hud_size":
			if not value in SIZE_KEYS or hud_size == value:
				return
			hud_size = value
		"joystick_side":
			if not value in ["left", "right"] or joystick_side == value:
				return
			joystick_side = value
		"joystick_size":
			if not value in SIZE_KEYS or joystick_size == value:
				return
			joystick_size = value
		_:
			return
	save_settings()
	changed.emit()


func get_choice(key: String) -> String:
	match key:
		"quality":
			return quality
		"hud_size":
			return hud_size
		"joystick_side":
			return joystick_side
		"joystick_size":
			return joystick_size
	return ""


func quality_index() -> int:
	return maxi(0, QUALITY_KEYS.find(quality))


func hud_scale_value() -> float:
	match hud_size:
		"small":
			return 0.9
		"large":
			return 1.12
	return 1.0


func joystick_scale_value() -> float:
	match joystick_size:
		"small":
			return 0.88
		"large":
			return 1.14
	return 1.0


func joystick_right() -> bool:
	return joystick_side == "right"


func fx_cap() -> int:
	var caps := [80, 160, 260]
	var cap: int = caps[quality_index()]
	if OS.has_feature("mobile"):
		cap = int(float(cap) * 0.7)
	return cap


func particle_scale() -> float:
	return [0.55, 0.85, 1.0][quality_index()]


func light_cap() -> int:
	return [2, 6, 14][quality_index()]


func damage_numbers_enabled() -> bool:
	return damage_numbers


func bloom_enabled() -> bool:
	return bloom


func bloom_quality() -> float:
	if OS.has_feature("mobile"):
		return 0.0
	return [0.35, 0.55, 1.0][quality_index()]


func decals_enabled() -> bool:
	return quality_index() > 0 and not OS.has_feature("mobile")


func enemy_cap(base: int) -> int:
	return int(float(base) * [0.7, 1.0, 1.0][quality_index()])


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("display", "bloom", bloom)
	cfg.set_value("display", "shake", shake)
	cfg.set_value("display", "damage_numbers", damage_numbers)
	cfg.set_value("display", "quality", quality)
	cfg.set_value("ui", "hud_size", hud_size)
	cfg.set_value("touch", "joystick_side", joystick_side)
	cfg.set_value("touch", "joystick_size", joystick_size)
	cfg.save(PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	bloom = bool(cfg.get_value("display", "bloom", true))
	shake = bool(cfg.get_value("display", "shake", true))
	damage_numbers = bool(cfg.get_value("display", "damage_numbers", true))
	var loaded_quality := String(cfg.get_value("display", "quality", "balanced"))
	if loaded_quality in QUALITY_KEYS:
		quality = loaded_quality
	var loaded_hud := String(cfg.get_value("ui", "hud_size", "normal"))
	if loaded_hud in SIZE_KEYS:
		hud_size = loaded_hud
	var loaded_side := String(cfg.get_value("touch", "joystick_side", "left"))
	if loaded_side in ["left", "right"]:
		joystick_side = loaded_side
	var loaded_touch := String(cfg.get_value("touch", "joystick_size", "normal"))
	if loaded_touch in SIZE_KEYS:
		joystick_size = loaded_touch
