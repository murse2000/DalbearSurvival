extends Node2D

## Selected moon companion. Behaviour comes from CompanionData.

var player
var manager
var level := 1
var companion_id := "star"
var data: Dictionary = {}
var _timer := 0.8
var _bob := 0.0
var _sprite: Sprite2D


func setup(player_ref, manager_ref, companion_level: int, id: String = "star") -> void:
	player = player_ref
	manager = manager_ref
	level = maxi(1, companion_level)
	companion_id = id
	data = CompanionData.get_companion(id)
	_timer = 0.8
	_bob = randf() * TAU
	_sprite = Sprite2D.new()
	_sprite.texture = load(String(data.get("sheet", "res://assets/art/char/friend_star.png")))
	_sprite.hframes = 4
	_sprite.vframes = 5
	_sprite.frame = 0
	_sprite.scale = Vector2(0.72, 0.72)
	_sprite.modulate = data.get("color", Color(0.78, 0.92, 1.0))
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
		_timer = maxf(0.65, (1.55 - float(level) * 0.12) * float(data.get("interval", 1.0)))
		_fire()


func _fire() -> void:
	var kind := String(data.get("kind", "bolt"))
	if kind == "heal" and player != null and is_instance_valid(player):
		player.heal(4.0 + float(level) * 2.0)
		FX.ring(global_position, Color(1.0, 0.9, 0.55), 54.0, 0.35)
		FX.float_text(global_position + Vector2(0, -30), "+치유", Color(1.0, 0.9, 0.55), 14)
	if manager == null or not is_instance_valid(manager):
		return
	var candidates: Array = manager.query_circle(global_position, 380.0)
	var targets: Array = []
	for enemy in candidates:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		targets.append(enemy)
	targets.sort_custom(func(a, b) -> bool:
		return global_position.distance_squared_to(a.global_position) \
			< global_position.distance_squared_to(b.global_position))
	if targets.is_empty():
		return
	match kind:
		"double":
			for i in mini(2, targets.size()):
				_hit(targets[i], float(data.get("damage", 0.7)))
		"aoe":
			var target = targets[0]
			manager.damage_circle(target.global_position, 62.0,
				(6.0 + float(level) * 3.0) * float(data.get("damage", 0.9)), 34.0,
				player, String(data.get("element", "fire")))
			FX.explosion(target.global_position, data.get("color", Color.ORANGE), 0.55)
			FX.laser_fx(global_position, target.global_position + Vector2(0, -8),
				data.get("color", Color.ORANGE), 3.0)
			Audio.play("laser", 1.3, -16.0)
		"crit":
			var target = targets[0]
			var roll: Dictionary = player.roll_damage((6.0 + float(level) * 3.0) \
				* float(data.get("damage", 1.2)))
			target.take_damage(float(roll["damage"]) * 1.55, true, global_position, 42.0,
				String(data.get("element", "void")))
			FX.laser_fx(global_position, target.global_position + Vector2(0, -8),
				data.get("color", Color.MEDIUM_PURPLE), 4.0)
			FX.hit(target.global_position + Vector2(0, -8), data.get("color", Color.MEDIUM_PURPLE), true)
			Audio.play("laser", 1.2, -12.0)
		_:
			_hit(targets[0], float(data.get("damage", 1.0)))


func _hit(target, multiplier: float) -> void:
	var base := (6.0 + float(level) * 3.0) * multiplier
	var roll: Dictionary = player.roll_damage(base)
	target.take_damage(roll["damage"], roll["crit"], global_position, 36.0,
		String(data.get("element", "frost")))
	FX.laser_fx(global_position, target.global_position + Vector2(0, -8),
		data.get("color", Color(0.72, 0.9, 1.0)), 3.0)
	FX.hit(target.global_position + Vector2(0, -8), data.get("color", Color(0.72, 0.9, 1.0)), false)
	Audio.play("laser", 1.35, -18.0)
