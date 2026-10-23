extends Node

## Persistent display / accessibility / feedback settings shared by the game
## and menus. New keys are additive so older save files keep working.

signal changed

const PATH := "user://dalbear_settings.cfg"
const QUALITY_KEYS := ["low", "balanced", "high"]
const SIZE_KEYS := ["small", "normal", "large"]
const WINDOW_KEYS := ["windowed", "borderless", "fullscreen"]
const FPS_KEYS := ["60", "120", "144", "unlimited"]
const FLASH_KEYS := ["off", "reduced", "normal"]
const MOTION_KEYS := ["off", "reduced", "normal"]
const COLORBLIND_KEYS := ["off", "deuteranopia", "protanopia", "tritanopia"]

var bloom := true
var shake := true
var damage_numbers := true
var quality := "balanced"
var hud_size := "normal"
var joystick_side := "left"
var joystick_size := "normal"
var window_mode := "windowed"
var vsync := true
var fps_limit := "unlimited"
var flash_intensity := "normal"
var motion_intensity := "normal"
var colorblind := "off"
var high_contrast := false
var focus_pause := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	_apply_display()


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
		"vsync":
			if vsync == value:
				return
			vsync = value
			_apply_display()
		"high_contrast":
			if high_contrast == value:
				return
			high_contrast = value
		"focus_pause":
			if focus_pause == value:
				return
			focus_pause = value
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
		"vsync":
			return vsync
		"high_contrast":
			return high_contrast
		"focus_pause":
			return focus_pause
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
		"window_mode":
			if not value in WINDOW_KEYS or window_mode == value:
				return
			window_mode = value
			_apply_display()
		"fps_limit":
			if not value in FPS_KEYS or fps_limit == value:
				return
			fps_limit = value
			_apply_display()
		"flash_intensity":
			if not value in FLASH_KEYS or flash_intensity == value:
				return
			flash_intensity = value
		"motion_intensity":
			if not value in MOTION_KEYS or motion_intensity == value:
				return
			motion_intensity = value
		"colorblind":
			if not value in COLORBLIND_KEYS or colorblind == value:
				return
			colorblind = value
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
		"window_mode":
			return window_mode
		"fps_limit":
			return fps_limit
		"flash_intensity":
			return flash_intensity
		"motion_intensity":
			return motion_intensity
		"colorblind":
			return colorblind
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


func flash_scale_value() -> float:
	match flash_intensity:
		"off":
			return 0.0
		"reduced":
			return 0.45
	return 1.0


func motion_scale_value() -> float:
	if not shake:
		return 0.0
	match motion_intensity:
		"off":
			return 0.0
		"reduced":
			return 0.42
	return 1.0


func high_contrast_enabled() -> bool:
	return high_contrast


func colorblind_mode() -> String:
	return colorblind


func toggle_fullscreen() -> void:
	set_choice("window_mode", "windowed" if window_mode == "fullscreen" else "fullscreen")


func _apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode := DisplayServer.WINDOW_MODE_WINDOWED
	if window_mode == "fullscreen":
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,
		window_mode == "borderless")
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)
	Engine.max_fps = 0 if fps_limit == "unlimited" else int(fps_limit)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		toggle_fullscreen()
		get_viewport().set_input_as_handled()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("display", "bloom", bloom)
	cfg.set_value("display", "shake", shake)
	cfg.set_value("display", "damage_numbers", damage_numbers)
	cfg.set_value("display", "quality", quality)
	cfg.set_value("display", "window_mode", window_mode)
	cfg.set_value("display", "vsync", vsync)
	cfg.set_value("display", "fps_limit", fps_limit)
	cfg.set_value("display", "flash_intensity", flash_intensity)
	cfg.set_value("display", "motion_intensity", motion_intensity)
	cfg.set_value("display", "colorblind", colorblind)
	cfg.set_value("display", "high_contrast", high_contrast)
	cfg.set_value("display", "focus_pause", focus_pause)
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
	var loaded_window := String(cfg.get_value("display", "window_mode", "windowed"))
	if loaded_window in WINDOW_KEYS:
		window_mode = loaded_window
	vsync = bool(cfg.get_value("display", "vsync", true))
	var loaded_fps := String(cfg.get_value("display", "fps_limit", "unlimited"))
	if loaded_fps in FPS_KEYS:
		fps_limit = loaded_fps
	var loaded_flash := String(cfg.get_value("display", "flash_intensity", "normal"))
	if loaded_flash in FLASH_KEYS:
		flash_intensity = loaded_flash
	var loaded_motion := String(cfg.get_value("display", "motion_intensity", "normal"))
	if loaded_motion in MOTION_KEYS:
		motion_intensity = loaded_motion
	var loaded_colorblind := String(cfg.get_value("display", "colorblind", "off"))
	if loaded_colorblind in COLORBLIND_KEYS:
		colorblind = loaded_colorblind
	high_contrast = bool(cfg.get_value("display", "high_contrast", false))
	focus_pause = bool(cfg.get_value("display", "focus_pause", true))
	_apply_display()
