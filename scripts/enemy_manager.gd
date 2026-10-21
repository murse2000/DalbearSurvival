extends Node2D

## Stage/difficulty-aware spawner, spatial hash and combat queries.

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const PROJECTILE_SCRIPT := preload("res://scripts/projectile.gd")
const PICKUP_SCRIPT := preload("res://scripts/pickup.gd")
const CELL := 72.0
const MAX_ENEMIES := 340

var player
var actors: Node2D
var projectiles: Node2D
var pickups: Node2D
var enemies: Array[Node2D] = []
var grid := {}
var spawn_timer := 1.0
var boss_spawned := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func setup(p, actors_ref: Node2D, proj_ref: Node2D, pick_ref: Node2D) -> void:
	player = p
	actors = actors_ref
	projectiles = proj_ref
	pickups = pick_ref


func _process(delta: float) -> void:
	if not Game.running:
		return
	if not boss_spawned and Game.time >= Game.stage_boss_time():
		boss_spawned = true
		_spawn_boss()
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	var stage := Game.stage_data()
	spawn_timer = GameData.spawn_interval(Game.stage_id, Game.time, Game.difficulty_id)
	if enemies.size() >= MAX_ENEMIES:
		return
	var batch := GameData.spawn_batch(Game.time, float(stage["duration"]))
	for i in batch:
		_spawn_random()


func _physics_process(_delta: float) -> void:
	grid.clear()
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		var key := Vector2i(floori(e.global_position.x / CELL), floori(e.global_position.y / CELL))
		var arr: Array = grid.get(key, [])
		arr.append(e)
		grid[key] = arr


func _spawn_random() -> void:
	var weights := GameData.stage_spawn_weights(Game.stage_id, Game.time)
	var total := 0.0
	for k in weights:
		total += float(weights[k])
	var r := _rng.randf() * total
	var kind := "blob"
	for k in weights:
		r -= float(weights[k])
		if r <= 0.0:
			kind = k
			break
	var elite_chance := float(Game.difficulty_data()["elite"])
	var elite := Game.time > 40.0 and _rng.randf() < elite_chance
	spawn_enemy(kind, _spawn_position(), elite)


func spawn_enemy(kind: String, pos: Vector2, elite: bool = false) -> void:
	if actors == null or enemies.size() >= MAX_ENEMIES:
		return
	if not GameData.ENEMIES.has(kind):
		return
	var e = ENEMY_SCENE.instantiate()
	actors.add_child(e)
	e.global_position = pos
	e.setup(kind, self, elite)
	enemies.append(e)
	if elite:
		FX.rune(pos, Color(1.0, 0.8, 0.4), 60.0, 0.55)
		Audio.play("levelup", 1.4, -14.0)


func spawn_minion(kind: String, pos: Vector2) -> void:
	spawn_enemy(kind, pos, false)


func spawn_bloblings(pos: Vector2) -> void:
	for i in 2:
		var a := TAU * float(i) / 2.0 + _rng.randf_range(-0.5, 0.5)
		spawn_enemy("blobling", pos + Vector2.from_angle(a) * 18.0, false)


func _spawn_position() -> Vector2:
	for i in 12:
		var a := _rng.randf_range(0.0, TAU)
		var d := _rng.randf_range(400.0, 540.0)
		var p: Vector2 = player.global_position + Vector2.from_angle(a) * d
		p.x = clampf(p.x, -GameData.ARENA_HALF + 70.0, GameData.ARENA_HALF - 70.0)
		p.y = clampf(p.y, -GameData.ARENA_HALF + 70.0, GameData.ARENA_HALF - 70.0)
		if p.distance_to(player.global_position) > 300.0:
			return p
	var fallback: Vector2 = player.global_position + Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized() * 360.0
	fallback.x = clampf(fallback.x, -GameData.ARENA_HALF + 70.0, GameData.ARENA_HALF - 70.0)
	fallback.y = clampf(fallback.y, -GameData.ARENA_HALF + 70.0, GameData.ARENA_HALF - 70.0)
	return fallback


func _spawn_boss() -> void:
	if actors == null:
		return
	var stage := Game.stage_data()
	var kind := String(stage["boss"])
	var a := _rng.randf_range(0.0, TAU)
	var pos: Vector2 = player.global_position + Vector2.from_angle(a) * 330.0
	pos.x = clampf(pos.x, -GameData.ARENA_HALF + 120.0, GameData.ARENA_HALF - 120.0)
	pos.y = clampf(pos.y, -GameData.ARENA_HALF + 120.0, GameData.ARENA_HALF - 120.0)
	var e = ENEMY_SCENE.instantiate()
	actors.add_child(e)
	e.global_position = pos
	e.setup(kind, self, false)
	enemies.append(e)
	FX.boss_spawn(pos)
	FX.flash(Color(0.7, 0.4, 1.0), 0.5, 1.0)
	FX.shake(12.0, 1.0)
	Audio.play("boss", 1.0, 0.0)
	var boss_name := String(GameData.ENEMIES[kind]["name"])
	Game.warning.emit("%s 접근 — 전선이 흔들린다" % boss_name, 4.0)


func on_enemy_died(e: Node2D) -> void:
	enemies.erase(e)


func on_boss_died(e: Node2D) -> void:
	enemies.erase(e)
	Game.boss = null
	Game.stage_clear(true)


func trigger_victory() -> void:
	Game.stage_clear(true)


func spawn_player_projectile(pos: Vector2, vel: Vector2, damage: float, pierce: int, source) -> void:
	if projectiles == null:
		return
	var p = PROJECTILE_SCRIPT.new()
	projectiles.add_child(p)
	p.setup_friendly(source, self, pos, vel, damage, pierce)


func spawn_enemy_orb(pos: Vector2, vel: Vector2, damage: float, variant: String = "orb") -> void:
	if projectiles == null:
		return
	var p = PROJECTILE_SCRIPT.new()
	projectiles.add_child(p)
	p.setup_enemy(pos, vel, damage, player, variant)


func clear_enemy_projectiles() -> void:
	if projectiles == null:
		return
	for p in projectiles.get_children():
		if is_instance_valid(p) and p.get("friendly") == false:
			p.queue_free()


func player_damage_area(pos: Vector2, radius: float, amount: float) -> void:
	if player == null or not is_instance_valid(player) or player.dead:
		return
	if pos.distance_to(player.global_position + Vector2(0, -10)) <= radius + player.radius:
		player.take_damage(amount)


func drop_xp(pos: Vector2, value: int, big: bool = false) -> void:
	if pickups == null:
		return
	var pk = PICKUP_SCRIPT.new()
	pickups.add_child(pk)
	var toss := Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized() * _rng.randf_range(20.0, 80.0)
	pk.setup(player, pos, "xp", maxi(1, value), toss if not big else toss * 1.5)


func drop_heart(pos: Vector2) -> void:
	if pickups == null:
		return
	var pk = PICKUP_SCRIPT.new()
	pickups.add_child(pk)
	var toss := Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)).normalized() * 30.0
	pk.setup(player, pos, "heart", 1, toss)


func nearest(pos: Vector2, max_range: float):
	var best = null
	var best_d := max_range * max_range
	for e in enemies:
		if not is_instance_valid(e) or e.dead or not e.targetable:
			continue
		var d: float = pos.distance_squared_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func query_circle(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var minx := floori((pos.x - radius) / CELL)
	var maxx := floori((pos.x + radius) / CELL)
	var miny := floori((pos.y - radius) / CELL)
	var maxy := floori((pos.y + radius) / CELL)
	for cx in range(minx, maxx + 1):
		for cy in range(miny, maxy + 1):
			var arr: Array = grid.get(Vector2i(cx, cy), [])
			for e in arr:
				if not is_instance_valid(e) or e.dead or not e.targetable:
					continue
				if pos.distance_to(e.global_position) <= radius + e.radius:
					result.append(e)
	return result


func has_enemy_within(pos: Vector2, radius: float) -> bool:
	return not query_circle(pos, radius).is_empty()


func damage_circle(pos: Vector2, radius: float, base_damage: float, knock: float, source) -> void:
	for e in query_circle(pos, radius):
		if not is_instance_valid(e) or e.dead:
			continue
		var roll: Dictionary = source.roll_damage(base_damage)
		e.take_damage(roll["damage"], roll["crit"], pos, knock)


func damage_line(start: Vector2, end: Vector2, width: float, base_damage: float, source) -> void:
	var dir := end - start
	var length := dir.length()
	if length < 1.0:
		return
	var hit := {}
	var step := 22.0
	var n := int(length / step) + 1
	for i in n + 1:
		var p := start + dir * (float(i) / float(n))
		for e in query_circle(p, width * 0.5):
			if not is_instance_valid(e) or e.dead:
				continue
			var id: int = e.get_instance_id()
			if hit.has(id):
				continue
			hit[id] = true
			var roll: Dictionary = source.roll_damage(base_damage)
			e.take_damage(roll["damage"], roll["crit"], start, 120.0)


func damage_all(base_damage: float, source) -> void:
	for e in enemies.duplicate():
		if not is_instance_valid(e) or e.dead or not e.targetable:
			continue
		var roll: Dictionary = source.roll_damage(base_damage)
		e.take_damage(roll["damage"], roll["crit"], player.global_position, 120.0)
