extends Node2D

## Map-specific breakable cover. It blocks player/enemy movement through the
## manager's circle resolver and is damaged by weapons, projectiles and dashes.

var manager
var kind := ""
var radius := 24.0
var hp := 100.0
var max_hp := 100.0
var color := Color.WHITE
var drop_value := 1
var burst := ""
var dead := false
var _sprite: Sprite2D
var _shadow: Sprite2D
var _flash := 0.0
var _base_scale := Vector2.ONE


func setup(kind_id: String, manager_ref) -> void:
	kind = kind_id
	manager = manager_ref
	var data: Dictionary = GameData.DESTRUCTIBLES.get(kind, {})
	radius = float(data.get("radius", 24.0))
	hp = float(data.get("hp", 100.0))
	max_hp = hp
	color = data.get("color", Color.WHITE)
	drop_value = int(data.get("drop", 1))
	burst = String(data.get("burst", ""))
	var tex: Texture2D = load(String(data.get("texture", "res://assets/art/world/rock_1.png")))
	_shadow = Sprite2D.new()
	_shadow.texture = load("res://assets/art/char/shadow_big.png")
	_shadow.modulate = Color(1, 1, 1, 0.38)
	_shadow.scale = Vector2(1.15, 0.75)
	_shadow.position = Vector2(0, 3)
	add_child(_shadow)
	_sprite = Sprite2D.new()
	_sprite.texture = tex
	_sprite.offset = Vector2(0, -tex.get_height() * 0.5)
	_sprite.scale = Vector2.ONE
	_sprite.modulate = color.lerp(Color.WHITE, 0.35)
	add_child(_sprite)
	_base_scale = _sprite.scale
	LightRig.make_receiver(_sprite)
	var tex_size := Vector2(tex.get_width(), tex.get_height())
	LightRig.add_occluder(self, tex_size, Vector2(0, -tex_size.y * 0.5))
	if kind in ["forest_crystal", "hive_egg", "ship_pod"]:
		LightRig.add_point_light(self, color, 125.0, 0.42, false,
			Vector2(0, -tex_size.y * 0.45))


func _process(delta: float) -> void:
	if dead:
		return
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta)
		if _sprite != null:
			_sprite.modulate = Color(2.2, 2.2, 2.2) if _flash > 0.0 else color.lerp(Color.WHITE, 0.35)


func take_damage(amount: float, from_pos: Vector2) -> void:
	if dead:
		return
	hp -= amount
	_flash = 0.08
	FX.hit(global_position + Vector2(0, -radius * 0.7), color, false)
	FX.shake(0.8, 0.08)
	if _sprite != null:
		_sprite.scale = _base_scale * 1.08
		var tw := create_tween()
		tw.tween_property(_sprite, "scale", _base_scale, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if hp <= 0.0:
		_shatter(from_pos)


func _shatter(from_pos: Vector2) -> void:
	if dead:
		return
	dead = true
	if manager != null:
		manager.on_obstacle_died(self)
		manager.drop_xp(global_position, drop_value, false)
	var shard_color := color
	FX.explosion(global_position + Vector2(0, -radius * 0.5), shard_color, 0.8)
	FX.ring(global_position, shard_color, radius * 2.2, 0.45)
	FX.particles(global_position + Vector2(0, -radius * 0.5), "dirt", shard_color,
		12, 0.7, 40, 180, 0.35, 180, Vector2(0, 220), false)
	FX.particles(global_position + Vector2(0, -radius * 0.5), "spark", shard_color,
		10, 0.5, 60, 220, 0.28, 180, Vector2(0, 90), true)
	FX.shake(3.5, 0.25)
	Audio.play("kill", 0.75, -4.0)
	if burst == "acid" and manager != null:
		FX.flash(Color(0.5, 1.0, 0.5), 0.06, 0.18)
		FX.ring(global_position, Color(0.5, 1.0, 0.5), 80.0, 0.45)
		manager.damage_circle(global_position, 74.0, 12.0, 100.0, manager.player)
	elif burst == "shock" and manager != null:
		FX.flash(Color(0.4, 0.9, 1.0), 0.07, 0.2)
		FX.ring(global_position, Color(0.4, 0.9, 1.0), 86.0, 0.45)
		manager.damage_circle(global_position, 82.0, 15.0, 120.0, manager.player)
	elif burst == "shard" and manager != null:
		FX.particles(global_position, "star", Color(0.45, 1.0, 1.0), 14, 0.55, 60, 230, 0.3, 180, Vector2.ZERO, true)
		manager.damage_circle(global_position, 58.0, 8.0, 60.0, manager.player)
	queue_free()
