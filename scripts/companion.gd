extends Node2D

## Permanent altar companion. Floats beside the player and fires moon bolts.

var player
var manager
var level := 1
var _timer := 0.8
var _bob := 0.0
var _sprite: Sprite2D


func setup(player_ref, manager_ref, companion_level: int) -> void:
	player = player_ref
	manager = manager_ref
	level = maxi(1, companion_level)
	_bob = randf() * TAU
	_sprite = Sprite2D.new()
	_sprite.texture = load("res://assets/art/char/friend_star.png")
	_sprite.hframes = 4
	_sprite.vframes = 5
	_sprite.frame = 0
	_sprite.scale = Vector2(0.72, 0.72)
	_sprite.modulate = Color(0.78, 0.92, 1.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_sprite)
	z_index = 8
	if player != null and is_instance_valid(player):
		global_position = player.global_position + Vector2(-46, -34)


func _process(delta: float) -> void:
	if not Game.running or player == null or not is_instance_valid(player) or player.dead:
		visible = false
		return
	visible = true
	_bob += delta * 3.0
	var target_pos: Vector2 = player.global_position + Vector2(
		-46.0 + sin(_bob) * 6.0, -34.0 + cos(_bob * 1.3) * 4.0)
	global_position = global_position.lerp(target_pos, 1.0 - exp(-delta * 6.0))
	_sprite.position.y = sin(_bob * 1.7) * 2.0
	_timer -= delta
	if _timer <= 0.0:
		_timer = maxf(0.7, 1.55 - float(level) * 0.12)
		_fire()


func _fire() -> void:
	if manager == null or not is_instance_valid(manager):
		return
	var candidates: Array = manager.query_circle(global_position, 380.0)
	var target = null
	var best := 1.0e20
	for enemy in candidates:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		var d: float = global_position.distance_squared_to(enemy.global_position)
		if d < best:
			best = d
			target = enemy
	if target == null:
		return
	var roll: Dictionary = player.roll_damage(6.0 + float(level) * 3.0)
	target.take_damage(roll["damage"], roll["crit"], global_position, 36.0, "moon")
	FX.laser_fx(global_position, target.global_position + Vector2(0, -8),
		Color(0.72, 0.9, 1.0), 3.0)
	FX.hit(target.global_position + Vector2(0, -8), Color(0.75, 0.92, 1.0), false)
	Audio.play("laser", 1.35, -18.0)
