extends Node2D

## Alien enemy. One script for every species, configured by GameData.ENEMIES.
## Ground units chase; specialists use ranged shots, burrowing, charges,
## teleports, splitting, turret beams and stage-specific boss patterns.

var kind := "blob"
var data: Dictionary = {}
var manager: Node
var player
var hp := 10.0
var max_hp := 10.0
var damage := 4.0
var speed := 40.0
var xp_value := 1
var radius := 10.0
var height := 26.0
var display_name := ""
var color := Color.WHITE
var elite := false
var boss := false
var behavior := "chase"
var boss_style := ""
var dead := false
var targetable := true
var knockback := Vector2.ZERO
var contact_cd := 0.0
var flash := 0.0
var age := 0.0
var seeded := 0.0

var sprite: Sprite2D
var shadow: Sprite2D
var aura: Sprite2D
var sprite_base_y := 0.0
var visual_scale := 1.0

# specialist attack state
var attack_cd := 1.0
var fuse := -1.0
var exploded := false
var burrowed := false
var burrow_timer := 0.0
var charge_cd := 2.5
var charge_state := 0
var charge_time := 0.0
var charge_dir := Vector2.ZERO
var teleport_cd := 2.0
var beam_cd := 3.0
var beam_charge := -1.0
var beam_line: Line2D
var beam_line2: Line2D
var beam_end := Vector2.ZERO
var beam_style := ""

# boss state
var boss_orb_cd := 2.5
var boss_summon_cd := 7.0
var boss_beam_cd := 6.0
var slam_cd := 4.5
var slam_charge := -1.0
var slam_pos := Vector2.ZERO
var spiral_cd := 5.0
var spiral_left := 0
var spiral_timer := 0.0
var spiral_angle := 0.0
var enraged := false


func _ready() -> void:
	seeded = randf() * 10.0
	z_as_relative = true


func setup(kind_id: String, manager_ref: Node, is_elite: bool = false) -> void:
	kind = kind_id
	manager = manager_ref
	player = manager_ref.player
	data = GameData.ENEMIES[kind]
	boss = bool(data.get("boss", false))
	boss_style = String(data.get("style", ""))
	behavior = String(data.get("behavior", "chase"))
	elite = is_elite
	display_name = String(data["name"])
	color = data["color"]
	var diff := GameData.difficulty(Game.difficulty_id)
	if boss:
		max_hp = float(data["hp"]) * float(diff["boss"])
		damage = float(data["damage"]) * float(diff["damage"])
		speed = float(data["speed"]) * float(diff["speed"])
		xp_value = int(data["xp"])
		radius = float(data["radius"])
		height = float(data["height"])
		visual_scale = float(data.get("scale", 1.0))
	else:
		max_hp = float(data["hp"]) * GameData.enemy_hp_mult(Game.stage_id, Game.time, Game.difficulty_id)
		damage = float(data["damage"]) * GameData.enemy_damage_mult(Game.stage_id, Game.time, Game.difficulty_id)
		speed = float(data["speed"]) * float(diff["speed"])
		xp_value = maxi(1, int(round(float(data["xp"]) * float(diff["xp"]))))
		radius = float(data["radius"])
		height = float(data["height"])
		visual_scale = 1.0
		if elite:
			max_hp *= 4.5
			damage *= 1.2
			xp_value *= 3
			radius *= 1.18
			height *= 1.22
			visual_scale = 1.28
			display_name += " · 정예"
		if kind == "blobling":
			visual_scale = 0.68
	hp = max_hp
	attack_cd = randf_range(1.0, 2.0)
	teleport_cd = randf_range(1.2, 2.4)
	charge_cd = randf_range(1.8, 3.0)
	beam_cd = randf_range(2.4, 3.8)
	slam_cd = randf_range(4.0, 5.5)
	spiral_cd = randf_range(4.0, 6.0)
	_build_visuals()
	if behavior == "burrower":
		burrowed = true
		burrow_timer = 1.4
		targetable = false
		if sprite != null:
			sprite.visible = false
		if shadow != null:
			shadow.visible = false
	if boss:
		Game.boss = self


func _build_visuals() -> void:
	var big_shadow := boss or elite
	shadow = Sprite2D.new()
	shadow.texture = load("res://assets/art/char/shadow_big.png" if big_shadow else "res://assets/art/char/shadow.png")
	shadow.modulate = Color(1, 1, 1, 0.55 if not boss else 0.45)
	shadow.scale = Vector2(1.4, 1.1) if boss else Vector2(1.0 if not elite else 1.35, 0.9)
	add_child(shadow)

	if boss or elite:
		aura = Sprite2D.new()
		aura.texture = load("res://assets/art/char/boss_aura.png")
		aura.modulate = Color(data["color"].r, data["color"].g, data["color"].b, 0.28)
		aura.scale = Vector2.ONE * ((1.15 if boss_style == "queen" else 1.0) if boss else 0.45)
		var am := CanvasItemMaterial.new()
		am.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		aura.material = am
		add_child(aura)
		aura.position.y = 0.0 if boss else -height * 0.35

	sprite = Sprite2D.new()
	sprite.texture = load(String(data["texture"]))
	sprite.scale = Vector2.ONE * visual_scale
	if boss:
		sprite.position.y = 0.0
		sprite_base_y = 0.0
		shadow.position.y = height * 0.42
		shadow.scale = Vector2(1.7, 1.2)
	else:
		sprite.position.y = -height * 0.5
		sprite_base_y = sprite.position.y
	add_child(sprite)
	sprite.z_index = 1
	if elite:
		sprite.modulate = Color(1.08, 1.05, 1.18)
	var target_scale := Vector2.ONE * visual_scale
	sprite.scale = target_scale * 0.15
	var tw := create_tween()
	tw.tween_property(sprite, "scale", target_scale, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if dead or not Game.running:
		return
	age += delta
	contact_cd = maxf(0.0, contact_cd - delta)
	flash = maxf(0.0, flash - delta)
	if player == null or not is_instance_valid(player):
		return
	var to: Vector2 = player.global_position - global_position
	var dist := to.length()
	var dir := to / maxf(0.001, dist)

	if boss:
		_boss_move(delta, dir, dist)
		_boss_attacks(delta)
	else:
		match behavior:
			"spitter":
				_spitter_behavior(delta, dir, dist)
			"bomber":
				_bomber_behavior(delta, dir, dist)
			"burrower":
				_burrower_behavior(delta, dir, dist)
			"brute":
				_brute_behavior(delta, dir, dist)
			"sentinel":
				_sentinel_behavior(delta, dir, dist)
			"phase":
				_phase_behavior(delta, dir, dist)
			_:
				_default_move(delta, dir, dist)

	knockback = knockback.lerp(Vector2.ZERO, 1.0 - exp(-delta * 7.5))

	# visual motion
	if boss:
		sprite.position.y = sprite_base_y + sin(age * 1.5) * 9.0
		if boss_style != "queen":
			sprite.rotation = sin(age * 0.6) * 0.12
		if aura != null:
			aura.scale = Vector2.ONE * ((1.15 if boss_style == "queen" else 1.0) * (1.0 + sin(age * 2.2) * 0.04))
			aura.modulate.a = 0.22 + sin(age * 3.0) * 0.05
	elif kind == "drone" or kind == "jelly" or kind == "sentinel":
		sprite.position.y = sprite_base_y + sin(age * 4.0 + seeded) * 3.0
	else:
		sprite.position.y = sprite_base_y + sin(age * 7.0 + seeded) * 0.8

	var tint := Color.WHITE
	if enraged:
		tint = Color(1.25, 0.75, 0.75) if boss_style == "ship" else Color(0.8, 1.3, 0.8)
	elif elite:
		tint = Color(1.08, 1.05, 1.18)
	sprite.modulate = Color(2.6, 2.6, 2.6) if flash > 0.0 else tint

	# contact damage
	if behavior != "bomber" and dist < radius + player.radius + 2.0 and contact_cd <= 0.0:
		var dmg := damage * (1.6 if charge_state == 2 else 1.0)
		player.take_damage(dmg)
		contact_cd = 0.85
		knockback += -dir * 60.0


func _default_move(delta: float, dir: Vector2, dist: float) -> void:
	var v := dir * speed
	if kind == "drone":
		v += Vector2(-dir.y, dir.x) * sin(age * 3.0 + seeded) * 34.0
	elif kind == "jelly":
		v += Vector2(-dir.y, dir.x) * sin(age * 1.7 + seeded) * 22.0
	v += _separation()
	global_position += (v + knockback) * delta
	_clamp_arena()
	if dist > 1700.0:
		queue_free()


func _clamp_arena() -> void:
	global_position.x = clampf(global_position.x, -GameData.ARENA_HALF, GameData.ARENA_HALF)
	global_position.y = clampf(global_position.y, -GameData.ARENA_HALF, GameData.ARENA_HALF)


func _separation() -> Vector2:
	var push := Vector2.ZERO
	var count := 0
	for other in manager.query_circle(global_position, radius + 16.0):
		if other == self or other.dead:
			continue
		var d: float = global_position.distance_to(other.global_position)
		if d > 0.01:
			var overlap: float = (radius + other.radius) - d
			if overlap > 0.0:
				push += (global_position - other.global_position) / d * overlap * 5.0
				count += 1
				if count >= 6:
					break
	return push


# ---------------------------------------------------------------- specialists
func _spitter_behavior(delta: float, dir: Vector2, dist: float) -> void:
	var v := Vector2.ZERO
	if dist > 190.0:
		v = dir * speed
	elif dist < 115.0:
		v = -dir * speed * 0.85
	else:
		v = Vector2(-dir.y, dir.x) * speed * 0.55 * (1.0 if sin(age + seeded) > 0 else -1.0)
	v += _separation()
	global_position += (v + knockback) * delta
	_clamp_arena()
	attack_cd -= delta
	if attack_cd <= 0.0 and dist < 430.0:
		var aim: Vector2 = (player.global_position + Vector2(0, -10) - global_position).normalized()
		var count := 2 if not elite else 3
		for i in count:
			var a := deg_to_rad(7.0) * (float(i) - (count - 1) * 0.5)
			manager.spawn_enemy_orb(global_position + aim * 12.0, aim.rotated(a) * 205.0, damage * 0.7, "acid")
		FX.muzzle(global_position + aim * 14.0, aim.angle(), color)
		FX.particles(global_position + aim * 10.0, "star", color, 3, 0.3, 20, 60, 0.2, 180, Vector2.ZERO, true)
		Audio.play("shoot", 0.72, -10.0)
		attack_cd = 2.3 if not enraged else 1.8


func _bomber_behavior(delta: float, dir: Vector2, dist: float) -> void:
	if fuse >= 0.0:
		fuse -= delta
		global_position += knockback * delta
		if fuse <= 0.0:
			_explode()
		return
	var v := dir * speed
	v += _separation()
	global_position += (v + knockback) * delta
	_clamp_arena()
	if dist < 78.0:
		fuse = 0.9
		FX.ring(global_position, Color(1.0, 0.55, 0.2), 34.0, 0.45)
		Audio.play("click", 0.7, -6.0)


func _burrower_behavior(delta: float, dir: Vector2, dist: float) -> void:
	if burrowed:
		global_position += dir * speed * 1.7 * delta
		_clamp_arena()
		burrow_timer -= delta
		if burrow_timer <= 0.0:
			burrowed = false
			targetable = true
			burrow_timer = 4.2
			if sprite != null:
				sprite.visible = true
			if shadow != null:
				shadow.visible = true
			FX.ring(global_position, color, 52.0, 0.45)
			FX.particles(global_position, "dirt", Color(0.6, 0.45, 0.5), 10, 0.55, 40, 150, 0.3, 180, Vector2(0, 180), false)
			Audio.play("kill", 0.7, -8.0)
	else:
		_default_move(delta, dir, dist)
		burrow_timer -= delta
		if burrow_timer <= 0.0:
			burrowed = true
			targetable = false
			burrow_timer = 2.0
			if sprite != null:
				sprite.visible = false
			if shadow != null:
				shadow.visible = false
			FX.ring(global_position, Color(0.6, 0.4, 0.8), 40.0, 0.35)
			FX.particles(global_position, "dirt", Color(0.5, 0.35, 0.45), 8, 0.4, 30, 100, 0.25, 180, Vector2(0, 120), false)


func _brute_behavior(delta: float, dir: Vector2, dist: float) -> void:
	if charge_state == 1:
		charge_time -= delta
		if charge_time <= 0.0:
			charge_state = 2
			charge_time = 0.48
			FX.ring(global_position, Color(1.0, 0.55, 0.3), 46.0, 0.35)
			Audio.play("pulse", 0.55, -7.0)
		return
	if charge_state == 2:
		charge_time -= delta
		global_position += charge_dir * speed * 4.6 * delta
		_clamp_arena()
		if charge_time <= 0.0:
			charge_state = 0
			charge_cd = 3.4
		return
	_default_move(delta, dir, dist)
	charge_cd -= delta
	if charge_cd <= 0.0 and dist < 420.0:
		charge_state = 1
		charge_time = 0.65
		charge_dir = dir
		FX.ring(global_position, Color(1.0, 0.6, 0.3), 50.0, 0.5)
		FX.float_text(global_position, "돌진!", Color(1.0, 0.65, 0.35), 18)
		Audio.play("click", 0.65, -4.0)


func _sentinel_behavior(delta: float, dir: Vector2, dist: float) -> void:
	var v := Vector2.ZERO
	if dist > 260.0:
		v = dir * speed
	else:
		v = Vector2(-dir.y, dir.x) * speed * 0.35
	global_position += (v + knockback) * delta
	_clamp_arena()
	if beam_charge >= 0.0:
		beam_charge -= delta
		_update_beam()
		if beam_charge <= 0.0:
			_fire_beam()
	else:
		beam_cd -= delta
		if beam_cd <= 0.0 and dist < 560.0:
			_start_beam("sentinel")


func _phase_behavior(delta: float, dir: Vector2, dist: float) -> void:
	_default_move(delta, dir, dist)
	teleport_cd -= delta
	if teleport_cd <= 0.0 and dist < 520.0:
		teleport_cd = 3.4
		var old := global_position
		var a := randf() * TAU
		var target_pos: Vector2 = player.global_position + Vector2.from_angle(a) * randf_range(90.0, 140.0)
		target_pos.x = clampf(target_pos.x, -GameData.ARENA_HALF + 40.0, GameData.ARENA_HALF - 40.0)
		target_pos.y = clampf(target_pos.y, -GameData.ARENA_HALF + 40.0, GameData.ARENA_HALF - 40.0)
		FX.rune(old, Color(0.75, 0.5, 1.0), 38.0, 0.4)
		FX.particles(old, "star", Color(0.75, 0.55, 1.0), 8, 0.4, 30, 100, 0.25, 180, Vector2.ZERO, true)
		global_position = target_pos
		FX.rune(global_position, Color(0.75, 0.5, 1.0), 42.0, 0.4)
		Audio.play("click", 1.4, -8.0)


# ---------------------------------------------------------------- boss
func _boss_move(delta: float, dir: Vector2, dist: float) -> void:
	var keep := 160.0 if boss_style == "queen" else 190.0
	if dist > keep:
		global_position += dir * speed * delta
	else:
		global_position += Vector2(-dir.y, dir.x) * speed * 0.65 * delta
	global_position.x = clampf(global_position.x, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)
	global_position.y = clampf(global_position.y, -GameData.ARENA_HALF + 90.0, GameData.ARENA_HALF - 90.0)


func _boss_attacks(delta: float) -> void:
	if enraged:
		boss_orb_cd = minf(boss_orb_cd, 1.6)
		boss_summon_cd = minf(boss_summon_cd, 5.0)
	match boss_style:
		"queen":
			boss_orb_cd -= delta
			if boss_orb_cd <= 0.0:
				_acid_fan()
				boss_orb_cd = 2.2 if enraged else 3.0
			boss_summon_cd -= delta
			if boss_summon_cd <= 0.0:
				_boss_summon()
				boss_summon_cd = 7.5
			if slam_charge >= 0.0:
				slam_charge -= delta
				if slam_charge <= 0.0:
					_fire_slam()
			else:
				slam_cd -= delta
				if slam_cd <= 0.0:
					_start_slam()
		"ship":
			boss_orb_cd -= delta
			if boss_orb_cd <= 0.0:
				_boss_orbs()
				boss_orb_cd = 2.1 if enraged else 3.2
			boss_summon_cd -= delta
			if boss_summon_cd <= 0.0:
				_boss_summon()
				boss_summon_cd = 8.0
			if beam_charge >= 0.0:
				beam_charge -= delta
				_update_beam()
				if beam_charge <= 0.0:
					_fire_beam()
			else:
				boss_beam_cd -= delta
				if boss_beam_cd <= 0.0:
					_start_beam("ship")
			spiral_cd -= delta
			if spiral_left <= 0 and spiral_cd <= 0.0:
				spiral_left = 24
				spiral_angle = randf() * TAU
				spiral_cd = 6.5
				spiral_timer = 0.0
			if spiral_left > 0:
				spiral_timer -= delta
				if spiral_timer <= 0.0:
					spiral_timer = 0.06
					var start := global_position + Vector2(0, -10)
					manager.spawn_enemy_orb(start, Vector2.from_angle(spiral_angle) * 165.0, damage * 0.45)
					spiral_angle += 0.43
					spiral_left -= 1
		_:
			boss_orb_cd -= delta
			if boss_orb_cd <= 0.0:
				_boss_orbs()
				boss_orb_cd = 2.3 if enraged else 3.4
			boss_summon_cd -= delta
			if boss_summon_cd <= 0.0:
				_boss_summon()
				boss_summon_cd = 8.5


func _boss_orbs() -> void:
	var count := 18 if boss_style == "ship" else 12
	var start := global_position + Vector2(0, -10)
	for i in count:
		var a := TAU * float(i) / float(count) + age * 0.3
		manager.spawn_enemy_orb(start, Vector2.from_angle(a) * (165.0 if boss_style == "ship" else 135.0), damage * 0.55)
	FX.ring(start, Color(0.8, 0.45, 1.0), 80.0, 0.3)
	FX.particles(start, "star", Color(0.8, 0.45, 1.0), 12, 0.4, 40, 120, 0.3, 180, Vector2.ZERO, true, 250)
	Audio.play("pulse", 0.7, -8.0)
	FX.shake(1.8, 0.18)


func _acid_fan() -> void:
	var start := global_position + Vector2(0, -20)
	var aim: Vector2 = (player.global_position + Vector2(0, -10) - start).normalized()
	for i in 7:
		var a := deg_to_rad(11.0) * (float(i) - 3.0)
		manager.spawn_enemy_orb(start, aim.rotated(a) * 215.0, damage * 0.55, "acid")
	FX.ring(start, Color(0.55, 1.0, 0.6), 70.0, 0.3)
	FX.particles(start, "star", Color(0.55, 1.0, 0.6), 12, 0.4, 40, 120, 0.3, 180, Vector2.ZERO, true, 250)
	Audio.play("shoot", 0.65, -6.0)
	FX.shake(1.5, 0.15)


func _start_slam() -> void:
	slam_pos = player.global_position + Vector2(0, -10)
	slam_charge = 1.0
	slam_cd = 5.2 if not enraged else 3.8
	FX.rune(slam_pos, Color(0.55, 1.0, 0.6), 120.0, 1.0)
	FX.ring(slam_pos, Color(0.55, 1.0, 0.6), 130.0, 1.0, "halo")
	FX.float_text(slam_pos, "슬램!", Color(0.6, 1.0, 0.6), 22)
	Audio.play("boss", 1.4, -10.0)


func _fire_slam() -> void:
	slam_charge = -1.0
	manager.player_damage_area(slam_pos, 125.0, damage * 1.25)
	FX.explosion(slam_pos, Color(0.55, 1.0, 0.6), 1.1)
	FX.shake(7.0, 0.4)


func _boss_summon() -> void:
	var count := 5 if enraged else 4
	var summon_kinds := ["drone", "grey"]
	if boss_style == "queen":
		summon_kinds = ["spitter", "bomber"]
	elif boss_style == "ship":
		summon_kinds = ["phase", "sentinel", "splitter"]
	for i in count:
		var a := TAU * float(i) / float(count) + randf()
		var pos := global_position + Vector2.from_angle(a) * 110.0
		manager.spawn_minion(summon_kinds[i % summon_kinds.size()], pos)
		FX.rune(pos, color, 58.0, 0.6)
		FX.particles(pos, "star", color, 8, 0.5, 30, 110, 0.28, 180, Vector2.ZERO, true)


func _start_beam(style: String = "ship") -> void:
	beam_style = style
	beam_charge = 0.95
	beam_end = player.global_position + Vector2(0, -10)
	var col := Color(1.0, 0.15, 0.35, 0.16)
	var col2 := Color(1.0, 0.55, 0.65, 0.85)
	var w1 := 22.0
	var w2 := 4.0
	if style == "sentinel":
		col = Color(1.0, 0.35, 0.2, 0.14)
		col2 = Color(1.0, 0.75, 0.5, 0.85)
		w1 = 16.0
		w2 = 3.0
		Audio.play("laser", 0.55, -10.0)
	else:
		Audio.play("boss", 1.15, -8.0)
	beam_line = Line2D.new()
	beam_line.width = w1
	beam_line.z_index = 6
	beam_line.top_level = true
	beam_line.default_color = col
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	beam_line.material = mat
	FX.fx_root.add_child(beam_line)
	beam_line2 = Line2D.new()
	beam_line2.width = w2
	beam_line2.z_index = 7
	beam_line2.top_level = true
	beam_line2.default_color = col2
	beam_line2.material = mat
	FX.fx_root.add_child(beam_line2)
	if boss:
		FX.float_text(global_position, "빔 충전!", Color(1.0, 0.4, 0.45), 22)


func _update_beam() -> void:
	if beam_line == null or not is_instance_valid(beam_line):
		return
	var start := global_position + Vector2(0, -12)
	beam_line.clear_points()
	beam_line.add_point(start)
	beam_line.add_point(beam_end)
	beam_line2.clear_points()
	beam_line2.add_point(start)
	beam_line2.add_point(beam_end)
	var pulse := 0.5 + 0.5 * absf(sin(age * 22.0))
	if beam_style == "sentinel":
		beam_line.default_color = Color(1.0, 0.35, 0.2, 0.10 + 0.16 * pulse)
		beam_line2.default_color = Color(1.0, 0.75, 0.5, 0.55 + 0.4 * pulse)
	else:
		beam_line.default_color = Color(1.0, 0.15, 0.35, 0.10 + 0.16 * pulse)
		beam_line2.default_color = Color(1.0, 0.55, 0.65, 0.55 + 0.4 * pulse)


func _fire_beam() -> void:
	var start := global_position + Vector2(0, -12)
	var end := beam_end
	if beam_line != null and is_instance_valid(beam_line):
		beam_line.queue_free()
	if beam_line2 != null and is_instance_valid(beam_line2):
		beam_line2.queue_free()
	beam_line = null
	beam_line2 = null
	beam_charge = -1.0
	if boss:
		boss_beam_cd = 8.0 if not enraged else 5.5
	else:
		beam_cd = 3.4
	var width := 46.0 if beam_style == "ship" else 30.0
	var col := Color(1.0, 0.42, 0.55) if beam_style == "ship" else Color(1.0, 0.65, 0.35)
	if player != null and is_instance_valid(player):
		var closest := Geometry2D.get_closest_point_to_segment(player.global_position, start, end)
		var hit_radius := width * 0.5
		if player.global_position.distance_to(closest) < hit_radius + 12.0:
			player.take_damage(damage * (0.9 if boss else 1.1))
	FX.laser_fx(start, end, col, width)
	Audio.play("laser", 0.62 if boss else 1.0, -1.0)
	FX.flash(col, 0.16, 0.3)
	FX.shake(6.0, 0.3)


# ---------------------------------------------------------------- damage
func take_damage(amount: float, crit: bool, source_pos: Vector2, knock: float = 90.0) -> void:
	if dead or not targetable:
		return
	hp -= amount
	flash = 0.08
	var above := global_position + Vector2(0, -height * visual_scale * 0.72)
	FX.damage_number(above, amount, Color(1.0, 0.86, 0.45) if crit else Color(0.97, 0.95, 0.9), crit)
	FX.hit(global_position + Vector2(0, -height * visual_scale * 0.4), color, crit)
	if boss:
		knockback += (global_position - source_pos).normalized() * knock * 0.06
		FX.shake(1.2, 0.08)
	else:
		var k := 0.35 if behavior == "brute" else 1.0
		knockback += (global_position - source_pos).normalized() * knock * k
	if boss and not enraged and hp < max_hp * 0.4:
		enraged = true
		FX.grade(Color(0.9, 0.25, 0.35), 0.28, 3.0)
		FX.shake(8.0, 0.6)
		Game.warning.emit("%s · 폭주!" % display_name, 2.6)
		Audio.play("boss", 1.3, -5.0)
	if hp <= 0.0:
		if behavior == "bomber":
			_explode()
		else:
			_die()


func _explode() -> void:
	if dead or exploded:
		return
	exploded = true
	dead = true
	manager.on_enemy_died(self)
	Game.add_kill()
	manager.player_damage_area(global_position, 92.0, damage * 1.35)
	FX.explosion(global_position, Color(1.0, 0.6, 0.25), 1.0)
	Audio.play("kill", 0.75, -2.0)
	Audio.play("pulse", 0.55, -6.0)
	manager.drop_xp(global_position, xp_value, false)
	if randf() < 0.025:
		manager.drop_heart(global_position)
	queue_free()


func _die() -> void:
	if dead:
		return
	dead = true
	Game.add_kill()
	if beam_line != null and is_instance_valid(beam_line):
		beam_line.queue_free()
	if beam_line2 != null and is_instance_valid(beam_line2):
		beam_line2.queue_free()
	if boss:
		manager.on_enemy_died(self)
		Game.warning.emit("%s 격추!" % display_name, 3.0)
		FX.boss_death(global_position)
		Audio.play("boss", 0.7, 0.0)
		for i in 12:
			var a := TAU * float(i) / 12.0
			manager.drop_xp(global_position + Vector2.from_angle(a) * 52.0, 8, true)
		manager.drop_heart(global_position + Vector2(-36, 4))
		manager.drop_heart(global_position + Vector2(36, -4))
		manager.on_boss_died(self)
	else:
		manager.on_enemy_died(self)
		if behavior == "splitter":
			manager.spawn_bloblings(global_position)
		FX.enemy_death(global_position + Vector2(0, -height * 0.25), color, elite)
		Audio.play("kill", randf_range(0.9, 1.15), -5.0)
		var total := xp_value
		if total >= 10:
			var gems := mini(6, 2 + int(total / 4))
			for i in gems:
				var a := TAU * float(i) / float(gems) + randf() * 0.4
				manager.drop_xp(global_position + Vector2.from_angle(a) * 12.0, int(maxf(1.0, float(total) / gems)), false)
		else:
			manager.drop_xp(global_position, total, false)
		if elite:
			manager.drop_heart(global_position + Vector2(0, 6))
		elif randf() < 0.025:
			manager.drop_heart(global_position)
	queue_free()
