extends Node

## Persistent display/feedback settings shared by the game and menus.

signal changed

const PATH := "user://dalbear_settings.cfg"

var bloom := true
var shake := true
var damage_numbers := true


func _ready() -> void:
	load_settings()


func set_option(key: String, value: bool) -> void:
	match key:
		"bloom":
			bloom = value
		"shake":
			shake = value
		"damage_numbers":
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


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("display", "bloom", bloom)
	cfg.set_value("display", "shake", shake)
	cfg.set_value("display", "damage_numbers", damage_numbers)
	cfg.save(PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	bloom = bool(cfg.get_value("display", "bloom", true))
	shake = bool(cfg.get_value("display", "shake", true))
	damage_numbers = bool(cfg.get_value("display", "damage_numbers", true))
