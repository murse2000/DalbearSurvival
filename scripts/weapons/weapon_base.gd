class_name WeaponBase
extends Node2D

var player
var level := 1
var data: Dictionary = {}
var timer := 0.25


func setup(p, lv: int) -> void:
	player = p
	level = lv
	data = GameData.weapon_stats(weapon_id(), level)
	timer = 0.25 + randf() * 0.15
	_on_setup()


func set_level(lv: int) -> void:
	level = lv
	data = GameData.weapon_stats(weapon_id(), level)
	_on_level_changed()


func weapon_id() -> String:
	return ""


func element() -> String:
	return GameData.weapon_element(weapon_id())


func cooldown() -> float:
	return float(data.get("cooldown", 1.0)) * player.cooldown_mult


func origin() -> Vector2:
	return player.global_position + Vector2(0, -15)


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	if not Game.running:
		return
	tick(delta)


func tick(_delta: float) -> void:
	pass


func _on_setup() -> void:
	pass


func _on_level_changed() -> void:
	pass
