extends Node2D

## Stage/difficulty-aware spawner, spatial hash and combat queries.

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const PROJECTILE_SCRIPT := preload("res://scripts/projectile.gd")
const PICKUP_SCRIPT := preload("res://scripts/pickup.gd")
const DESTRUCTIBLE_SCRIPT := preload("res://scripts/destructible.gd")
const CELL := 72.0
const MAX_ENEMIES := 340
const MAX_ENEMIES_MOBILE := 280
var _max_enemies := MAX_ENEMIES_MOBILE if OS.has_feature("mobile") else MAX_ENEMIES

var player
var actors: Node2D
var projectiles: Node2D
var pickups: Node2D
var obstacles: Node2D
var enemies: Array[Node2D] = []
var obstacle_list: Array[Node2D] = []
var grid := {}
var spawn_timer := 1.0
var boss_spawned := false
var miniboss_spawned := {}
var _grid_tick := 0
var _next_endless_boss := 170.0
var _next_endless_mini := 160.0
var _endless_mini_index := 0
var _rng := RandomNumberGenerator.new()


func _refresh_enemy_cap() -> void:
	var base := MAX_ENEMIES_MOBILE if OS.has_feature("mobile") else MAX_ENEMIES
	_max_enemies = Settings.enemy_cap(base)


func _ready() -> void:
	_refresh_enemy_cap()
	Settings.changed.connect(_refresh_enemy_cap)
	_rng.randomize()


func setup(p, actors_ref: Node2D, proj_ref: Node2D, pick_ref: Node2D,
		obstacles_ref: Node2D = null) -> void:
	player = p
	actors = actors_ref
	projectiles = proj_ref
	pickups = pick_ref
	obstacles = obstacles_ref


func _process(delta: float) -> void:
	if not Game.running:
		return
	if not boss_spawned and Game.time >= Game.stage_boss_time():
		boss_spawned = true
		_spawn_boss()
	if Game.is_endless():
		if (Game.boss == null or not is_instance_valid(Game.boss) or bool(Game.boss.get("dead"))) \
				and Game.time >= _next_endless_boss:
			_spawn_boss()
		if (Game.miniboss == null or not is_instance_valid(Game.miniboss) or bool(Game.miniboss.get("dead"))) \
				and Game.time >= _next_endless_mini:
			var endless_schedule: Array = Game.stage_data().get("minibosses", [])
			if not endless_schedule.is_empty():
				_spawn_miniboss(String(endless_schedule[_endless_mini_index % endless_schedule.size()][1]))
				_endless_mini_index += 1
				_next_endless_mini = Game.time + 75.0
	var schedule: Array = Game.stage_data().get("minibosses", [])
	for i in schedule.size():
		if not miniboss_spawned.has(i) and Game.time >= float(schedule[i][0]):
			miniboss_spawned[i] = true
			_spawn_miniboss(String(schedule[i][1]))
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	var stage := Game.stage_data()
	var interval := GameData.spawn_interval(Game.stage_id, Game.time, Game.difficulty_id) \
		* Game.run_spawn_mult
	if Game.is_endless():
		interval *= maxf(0.55, pow(0.97, maxf(0.0, Game.time - 240.0) / 10.0))
	spawn_timer = interval
	if enemies.size() >= _max_enemies:
		return
	var batch := GameData.spawn_batch(Game.time, float(stage["duration"]))
	for i in batch:
		_spawn_random()


func _physics_process(_delta: float) -> void:
	_grid_tick += 1
	# Rebuilding the spatial hash every other physics tick is enough: enemies
	# move only a couple of pixels between ticks, while the rebuild itself is
	# one of the hottest loops once hundreds of units are alive.
	if _grid_tick % 2 == 0:
		_rebuild_grid()


func _rebuild_grid() -> void:
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
	var elite_chance := float(Game.difficulty_data()["elite"]) + Game.run_elite_bonus
	var elite := Game.time > 40.0 and _rng.randf() < elite_chance
	spawn_enemy(kind, _spawn_position(), elite)


func spawn_enemy(kind: String, pos: Vector2, elite: bool = false) -> void:
	if actors == null or enemies.size() >= _max_enemies:
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
	if Game.is_endless():
		Game.endless_boss_wave += 1
		_next_endless_boss = Game.time + 90.0
	e.setup(kind, self, false)
	enemies.append(e)
	FX.boss_spawn(pos)
	FX.flash(Color(0.7, 0.4, 1.0), 0.5, 1.0)
	FX.shake(12.0, 1.0)
	Audio.play("boss", 1.0, 0.0)
	var boss_name := String(GameData.ENEMIES[kind]["name"])
	Game.warning.emit("%s 접근 — 전선이 흔들린다" % boss_name, 4.0)


func restore_boss(kind: String, pos: Vector2, hp_ratio: float) -> void:
	if not GameData.ENEMIES.has(kind):
		return
	spawn_enemy(kind, pos, false)
	if enemies.is_empty():
		return
	var e = enemies.back()
	e.hp = clampf(e.max_hp * clampf(hp_ratio, 0.01, 1.0), 1.0, e.max_hp)
	boss_spawned = true


func _spawn_miniboss(kind: String) -> void:
	if not GameData.ENEMIES.has(kind):
		return
	var a := _rng.randf_range(0.0, TAU)
	var pos: Vector2 = player.global_position + Vector2.from_angle(a) * 320.0
	pos.x = clampf(pos.x, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)
	pos.y = clampf(pos.y, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)
	var e = _create_miniboss(kind, pos)
	if e == null:
		return
	FX.rune(pos, e.color, 150.0, 0.9, 0.7)
	FX.ring(pos, e.color, 110.0, 0.7, "halo")
	FX.flash(e.color, 0.25, 0.6)
	FX.shake(8.0, 0.6)
	Audio.play("boss", 0.82, -1.0)
	Game.warning.emit("중간 보스 · %s 접근!" % e.display_name, 3.6)


func _create_miniboss(kind: String, pos: Vector2):
	if actors == null:
		return null
	var e = ENEMY_SCENE.instantiate()
	actors.add_child(e)
	e.global_position = pos
	e.setup(kind, self, false)
	enemies.append(e)
	return e


func mark_passed_minibosses(t: float) -> void:
	var schedule: Array = Game.stage_data().get("minibosses", [])
	for i in schedule.size():
		if t >= float(schedule[i][0]):
			miniboss_spawned[i] = true


func restore_miniboss(kind: String, pos: Vector2, hp_ratio: float) -> void:
	if not GameData.ENEMIES.has(kind):
		return
	var e = _create_miniboss(kind, pos)
	if e == null:
		return
	e.hp = clampf(e.max_hp * clampf(hp_ratio, 0.01, 1.0), 1.0, e.max_hp)
	Game.miniboss = e


func on_miniboss_died(e: Node2D) -> void:
	enemies.erase(e)
	if Game.miniboss == e:
		Game.miniboss = null


func on_enemy_died(e: Node2D) -> void:
	enemies.erase(e)


func on_boss_died(e: Node2D) -> void:
	enemies.erase(e)
	Game.boss = null
	if Game.is_endless():
		Game.warning.emit("보스 격추! 다음 보스가 접근 중...", 2.8)
	Game.note_boss_kill()
	if not Game.is_endless():
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


func separation_push(pos: Vector2, self_ref: Node2D, body_radius: float) -> Vector2:
	# Allocation-free version of the old query_circle + distance loop, used by
	# every enemy each frame. Returns the push-out vector from up to 6
	# overlapping neighbours.
	var push := Vector2.ZERO
	var count := 0
	var reach := body_radius + 16.0
	var minx := floori((pos.x - reach) / CELL)
	var maxx := floori((pos.x + reach) / CELL)
	var miny := floori((pos.y - reach) / CELL)
	var maxy := floori((pos.y + reach) / CELL)
	for cx in range(minx, maxx + 1):
		for cy in range(miny, maxy + 1):
			var arr: Array = grid.get(Vector2i(cx, cy), [])
			for e in arr:
				if e == self_ref or not is_instance_valid(e) or e.dead:
					continue
				var dx: float = pos.x - e.global_position.x
				var dy: float = pos.y - e.global_position.y
				var min_dist: float = body_radius + float(e.radius)
				var d2 := dx * dx + dy * dy
				if d2 >= min_dist * min_dist or d2 < 0.0001:
					continue
				var d := sqrt(d2)
				var scale := (min_dist - d) / d * 5.0
				push.x += dx * scale
				push.y += dy * scale
				count += 1
				if count >= 6:
					return push
	return push


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


func spawn_stage_obstacles() -> void:
	if obstacles == null or not obstacle_list.is_empty():
		return
	var kinds: Array = []
	var count := 22
	if GameData.NEW_STAGE_OBSTACLES.has(Game.stage_id):
		kinds = GameData.NEW_STAGE_OBSTACLES[Game.stage_id]
		count = 24
	else:
		match Game.stage_id:
			"hive":
				kinds = ["hive_egg", "hive_pod", "hive_coral"]
				count = 24
			"ship":
				kinds = ["ship_pod", "ship_console", "ship_wall"]
				count = 24
			_:
				kinds = ["forest_tree", "forest_rock", "forest_crystal"]
				count = 22
	for i in count:
		var placed := false
		for tries in 28:
			var a := _rng.randf_range(0.0, TAU)
			var d := _rng.randf_range(145.0, 205.0) if i < 5 else (
				_rng.randf_range(260.0, 520.0) if i < 11 else _rng.randf_range(520.0, 1200.0))
			var pos: Vector2 = player.global_position + Vector2.from_angle(a) * d
			pos.x = clampf(pos.x, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)
			pos.y = clampf(pos.y, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)
			if pos.distance_to(player.global_position) < 110.0:
				continue
			var clear := true
			for other in obstacle_list:
				if is_instance_valid(other) and pos.distance_to(other.global_position) < other.radius + 75.0:
					clear = false
					break
			if not clear:
				continue
			_spawn_obstacle(String(kinds[i % kinds.size()]), pos)
			placed = true
			break
		if not placed:
			continue


func _spawn_obstacle(kind: String, pos: Vector2) -> void:
	if obstacles == null:
		return
	var o = DESTRUCTIBLE_SCRIPT.new()
	obstacles.add_child(o)
	o.global_position = pos
	o.setup(kind, self)
	obstacle_list.append(o)


func damage_obstacles_circle(pos: Vector2, radius: float, amount: float) -> void:
	for o in obstacle_list:
		if not is_instance_valid(o) or o.dead:
			continue
		if pos.distance_to(o.global_position) <= radius + o.radius:
			o.take_damage(amount, pos)


func damage_obstacles_line(start: Vector2, end: Vector2, width: float, amount: float) -> void:
	var hit := {}
	for o in obstacle_list:
		if not is_instance_valid(o) or o.dead:
			continue
		var id: int = o.get_instance_id()
		if hit.has(id):
			continue
		var closest := Geometry2D.get_closest_point_to_segment(o.global_position, start, end)
		if o.global_position.distance_to(closest) <= width * 0.5 + o.radius:
			hit[id] = true
			o.take_damage(amount, closest)


func hit_obstacle(pos: Vector2, radius: float, amount: float) -> bool:
	for o in obstacle_list:
		if not is_instance_valid(o) or o.dead:
			continue
		if pos.distance_to(o.global_position) <= radius + o.radius:
			o.take_damage(amount, pos)
			return true
	return false


func resolve_obstacles(pos: Vector2, body_radius: float) -> Vector2:
	for o in obstacle_list:
		if not is_instance_valid(o) or o.dead:
			continue
		var delta := pos - o.global_position
		var min_dist: float = o.radius + body_radius
		var d := delta.length()
		if d < min_dist:
			if d < 0.01:
				delta = Vector2.RIGHT
				d = 1.0
			pos = o.global_position + delta / d * min_dist
	return pos


func on_obstacle_died(o: Node2D) -> void:
	obstacle_list.erase(o)


func damage_circle(pos: Vector2, radius: float, base_damage: float, knock: float, source) -> void:
	for e in query_circle(pos, radius):
		if not is_instance_valid(e) or e.dead:
			continue
		var roll: Dictionary = source.roll_damage(base_damage)
		e.take_damage(roll["damage"], roll["crit"], pos, knock)
	damage_obstacles_circle(pos, radius, base_damage)


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
	damage_obstacles_line(start, end, width, base_damage)


func damage_all(base_damage: float, source) -> void:
	for e in enemies.duplicate():
		if not is_instance_valid(e) or e.dead or not e.targetable:
			continue
		var roll: Dictionary = source.roll_damage(base_damage)
		e.take_damage(roll["damage"], roll["crit"], player.global_position, 120.0)
	damage_obstacles_circle(player.global_position, 1800.0, base_damage)
