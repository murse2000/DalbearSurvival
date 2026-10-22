class_name Player
extends Node2D

signal hp_changed(current: float, maximum: float)
signal stats_changed
signal died

const WEAPON_SCRIPTS := {
	"moon_shot": preload("res://scripts/weapons/moon_shot_weapon.gd"),
	"satellite": preload("res://scripts/weapons/satellite_weapon.gd"),
	"pulse": preload("res://scripts/weapons/pulse_weapon.gd"),
	"laser": preload("res://scripts/weapons/laser_weapon.gd"),
}
const PICKUP_TEXTURES := {
	0: preload("res://assets/art/fx/gem_0.png"),
	1: preload("res://assets/art/fx/gem_1.png"),
	2: preload("res://assets/art/fx/gem_2.png"),
}
const DASH_SPEED := 560.0
const DASH_TIME := 0.16
const DASH_COOLDOWN := 2.0
const ULTIMATE_MAX := 100.0

var max_hp := 100.0
var hp := 100.0
var speed := 122.0
var damage_mult := 1.0
var cooldown_mult := 1.0
var pickup_radius := 48.0
var armor := 0.0
var crit := 0.05
var crit_mult := 1.75
var regen := 0.0

var weapon_levels := {}
var passive_levels := {}
var weapons := {}
var evolutions := {}
var banned := {}
var _evo_notified := {}
var character: Dictionary = {}
var character_color := Color(1.0, 0.82, 0.45)
var manager: Node
var touch_controls
var look_dir := Vector2.DOWN
var radius := 10.0
var dead := false
var invuln := 0.0
var dash_cd := 0.0
var dash_cd_max := DASH_COOLDOWN
var dash_time := 0.0
var dash_dir := Vector2.DOWN
var ultimate_charge := 0.0
var ultimate_max := ULTIMATE_MAX

var _space_down := false
var _q_down := false
var _joy_dash_down := false
var _joy_ult_down := false
var _last_kills := 0
var _afterimage_timer := 0.0

var _sprite: Sprite2D
var _aura: Sprite2D
var _holder: Node2D
var _row := 0
var _flip := false
var _anim_time := 0.0
var _flash := 0.0
var _regen_acc := 0.0
var _moving := false
var _time := 0.0
var _restoring := false


func _ready() -> void:
	z_as_relative = true
	_sprite = $Sprite
	_aura = $Aura
	_holder = $WeaponHolder
	character = Game.character_data()
	character_color = character.get("color", Color(1.0, 0.82, 0.45))
	_sprite.texture = load(CharacterData.sheet(Game.selected_character))
	_sprite.hframes = 4
	_sprite.vframes = 3
	dash_cd_max = float(character.get("dash_cd", DASH_COOLDOWN))
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_aura.material = mat
	_aura.modulate = Color(character_color.r, character_color.g, character_color.b, 0.16)
	max_hp = 0.0
	hp = 0.0
	recalc_stats()
	hp = max_hp
	_equip_starting_weapons()
	hp_changed.emit(hp, max_hp)
	stats_changed.emit()
	Game.kills_changed.connect(_on_kills_changed)
	_last_kills = Game.kills
	_space_down = Input.is_physical_key_pressed(KEY_SPACE)
	_q_down = Input.is_physical_key_pressed(KEY_Q)


func setup(manager_ref: Node) -> void:
	manager = manager_ref


func _process(delta: float) -> void:
	if dead:
		return
	_time += delta
	invuln = maxf(0.0, invuln - delta)
	_flash = maxf(0.0, _flash - delta)
	dash_cd = maxf(0.0, dash_cd - delta)
	dash_time = maxf(0.0, dash_time - delta)
	if not Game.running:
		return

	var input := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input.y += 1.0
	var joy := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if joy.length() > 0.25:
		input = joy
	if touch_controls != null and is_instance_valid(touch_controls) and touch_controls.visible:
		var touch_move: Vector2 = touch_controls.move_vector
		if touch_move.length() > 0.08:
			input = touch_move
	_handle_abilities(input)
	_moving = input.length() > 0.05
	if dash_time > 0.0:
		position += dash_dir * DASH_SPEED * delta
		position.x = clampf(position.x, -GameData.ARENA_HALF + 30.0, GameData.ARENA_HALF - 30.0)
		position.y = clampf(position.y, -GameData.ARENA_HALF + 30.0, GameData.ARENA_HALF - 30.0)
		_moving = true
		look_dir = dash_dir
		_update_facing(dash_dir)
		_anim_time += delta * 18.0
		_afterimage_timer -= delta
		if _afterimage_timer <= 0.0:
			_afterimage_timer = 0.045
			_spawn_afterimage()
	elif _moving:
		input = input.normalized()
		look_dir = input
		position += input * speed * delta
		position.x = clampf(position.x, -GameData.ARENA_HALF + 30.0, GameData.ARENA_HALF - 30.0)
		position.y = clampf(position.y, -GameData.ARENA_HALF + 30.0, GameData.ARENA_HALF - 30.0)
		_anim_time += delta * 9.5
		_update_facing(input)
	else:
		_anim_time += delta * 1.6

	# animation
	var col := 0
	if _moving:
		col = int(_anim_time) % 4
	_sprite.frame = _row * 4 + col
	_sprite.flip_h = _flip
	_sprite.position.y = -18.0 + sin(_time * 2.2) * 0.6
	var aura_color := character_color
	aura_color.a = 0.10 + sin(_time * 2.6) * 0.03
	_aura.modulate = aura_color

	# damage blink / flash
	var a := 1.0
	if invuln > 0.0:
		a = 0.45 + 0.45 * absf(sin(_time * 26.0))
	elif _flash > 0.0:
		a = 1.0
	_sprite.modulate = Color(1.0, 1.0, 1.0, a) if _flash <= 0.0 else Color(2.4, 2.4, 2.4, a)

	# regen
	if regen > 0.0 and hp < max_hp:
		_regen_acc += regen * delta
		if _regen_acc >= 1.0:
			var amount := floorf(_regen_acc)
			_regen_acc -= amount
			heal(amount, false)


func _update_facing(input: Vector2) -> void:
	if absf(input.x) >= absf(input.y) * 0.75:
		_row = 1
		_flip = input.x < 0.0
	elif input.y > 0.0:
		_row = 0
		_flip = false
	else:
		_row = 2
		_flip = false


func _handle_abilities(input: Vector2) -> void:
	var space_now := Input.is_physical_key_pressed(KEY_SPACE)
	var joy_dash := Input.is_joy_button_pressed(0, JOY_BUTTON_B)
	if space_now and not _space_down:
		_try_dash(input)
	if joy_dash and not _joy_dash_down:
		_try_dash(input)
	_space_down = space_now
	_joy_dash_down = joy_dash

	var q_now := Input.is_physical_key_pressed(KEY_Q)
	var joy_ult := Input.is_joy_button_pressed(0, JOY_BUTTON_Y)
	if q_now and not _q_down:
		_try_ultimate()
	if joy_ult and not _joy_ult_down:
		_try_ultimate()
	_q_down = q_now
	_joy_ult_down = joy_ult

	if touch_controls != null and is_instance_valid(touch_controls):
		if touch_controls.consume_dash():
			_try_dash(input)
		if touch_controls.consume_ultimate():
			_try_ultimate()


func _try_dash(input: Vector2) -> void:
	if dead or not Game.running or dash_cd > 0.0:
		return
	dash_dir = input.normalized() if input.length() > 0.1 else look_dir
	if dash_dir.length() < 0.1:
		dash_dir = Vector2.DOWN
	dash_time = DASH_TIME
	dash_cd = dash_cd_max
	_afterimage_timer = 0.0
	invuln = maxf(invuln, DASH_TIME + 0.12)
	var fx_color := character_color.lerp(Color.WHITE, 0.35)
	Audio.play("dash", randf_range(0.96, 1.05), -3.0)
	FX.ring(global_position + Vector2(0, -10), fx_color, 30.0, 0.25)
	FX.particles(global_position + Vector2(0, -12), "star", fx_color,
		10, 0.35, 40, 130, 0.24, 180, Vector2(0, 60), true, 200)
	FX.flash(fx_color, 0.035, 0.2)
	FX.shake(2.2, 0.12)
	FX.punch(0.02)
	FX.speed_lines(0.18, fx_color)
	FX.screen_shock(0.16, 0.007, 0.18, fx_color)
	_spawn_afterimage()


func _spawn_afterimage() -> void:
	if _sprite == null or FX.fx_root == null or not is_instance_valid(FX.fx_root):
		return
	var ghost := Sprite2D.new()
	ghost.texture = _sprite.texture
	ghost.hframes = _sprite.hframes
	ghost.vframes = _sprite.vframes
	ghost.frame = _sprite.frame
	ghost.flip_h = _sprite.flip_h
	ghost.scale = _sprite.scale
	ghost.modulate = Color(character_color.r, character_color.g, character_color.b, 0.45)
	ghost.z_index = 11
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ghost.material = mat
	FX.fx_root.add_child(ghost)
	ghost.global_position = _sprite.global_position
	var tw := ghost.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ghost, "modulate:a", 0.0, 0.24)
	tw.tween_property(ghost, "scale", ghost.scale * 1.06, 0.24)
	tw.chain().tween_callback(ghost.queue_free)


func _try_ultimate() -> void:
	if dead or not Game.running or ultimate_charge < ultimate_max:
		return
	ultimate_charge = 0.0
	invuln = maxf(invuln, 1.3)
	var center := global_position + Vector2(0, -10)
	var fx_color := character_color.lerp(Color.WHITE, 0.25)
	Audio.play("ultimate", 1.0, -1.0)
	FX.rune(center, fx_color, 230.0, 0.9, 0.7)
	FX.ring(center, fx_color, 120.0, 0.9)
	FX.ring(center, fx_color, 260.0, 1.2, "halo")
	FX.laser_fx(center + Vector2(0, -560), center, fx_color, 86.0)
	FX.explosion(center, fx_color, 1.5)
	FX.flash(fx_color, 0.62, 1.0)
	FX.boost_bloom(2.0)
	FX.shake(12.0, 0.8)
	FX.punch(0.1)
	FX.grade(fx_color, 0.18, 1.8)
	FX.screen_shock(0.9, 0.06, 0.9, fx_color)
	FX.hitstop(0.055, 0.08)
	if manager != null:
		manager.damage_circle(center, 470.0, 180.0, 360.0, self)
		manager.clear_enemy_projectiles()
	for i in 6:
		var a := TAU * float(i) / 6.0 + randf() * 0.3
		var p := center + Vector2.from_angle(a) * randf_range(120.0, 320.0)
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 0.1 + 0.07 * i
		add_child(t)
		t.timeout.connect(_ultimate_strike.bind(p))
		t.start()


func _ultimate_strike(p: Vector2) -> void:
	if not is_inside_tree() or not Game.running or manager == null:
		return
	var fx_color := character_color.lerp(Color.WHITE, 0.25)
	FX.laser_fx(p + Vector2(0, -360), p, fx_color, 30.0)
	FX.explosion(p, fx_color, 0.8)
	FX.screen_shock(0.22, 0.008, 0.12, fx_color)
	manager.damage_circle(p, 88.0, 70.0, 160.0, self)


func _on_kills_changed(kills: int) -> void:
	var gained := kills - _last_kills
	_last_kills = kills
	if gained <= 0:
		return
	var was_full := ultimate_charge >= ultimate_max
	ultimate_charge = minf(ultimate_max, ultimate_charge + gained * 1.6)
	if not was_full and ultimate_charge >= ultimate_max:
		Audio.play("levelup", 1.35, -10.0)
		FX.float_text(global_position + Vector2(0, -44), "궁극기 준비!", Color(0.55, 1.0, 0.9), 22)
		FX.ring(global_position, Color(0.55, 1.0, 0.9), 42.0, 0.4)


func recalc_stats() -> void:
	var old_max := max_hp
	if character.is_empty():
		character = Game.character_data()
	var heart := int(passive_levels.get("heart", 0))
	var boots := int(passive_levels.get("boots", 0))
	var core := int(passive_levels.get("core", 0))
	var coolant := int(passive_levels.get("coolant", 0))
	var magnet := int(passive_levels.get("magnet", 0))
	var star := int(passive_levels.get("star", 0))
	var alloy := int(passive_levels.get("armor", 0))
	var nano := int(passive_levels.get("nano", 0))
	var gear: Dictionary = Game.equipment_bonuses()
	var base_hp := float(character.get("max_hp", GameData.BASE_STATS["max_hp"]))
	var base_speed := float(character.get("speed", GameData.BASE_STATS["speed"]))
	var base_damage := float(character.get("damage", 1.0))
	var base_cooldown := float(character.get("cooldown", 1.0))
	var base_pickup := float(character.get("pickup", 48.0))
	var base_armor := float(character.get("armor", 0.0))
	var base_crit := float(character.get("crit", 0.05))
	var base_regen := float(character.get("regen", 0.0))
	max_hp = base_hp + heart * 20.0 + float(gear.get("max_hp", 0.0))
	speed = base_speed * (1.0 + boots * 0.08) * (1.0 + float(gear.get("speed_pct", 0.0)))
	damage_mult = base_damage * (1.0 + core * 0.12) * (1.0 + float(gear.get("damage_pct", 0.0)))
	cooldown_mult = maxf(0.3, base_cooldown * (1.0 - coolant * 0.07) * (1.0 - float(gear.get("cooldown_pct", 0.0))))
	pickup_radius = base_pickup + magnet * 28.0 + float(gear.get("pickup", 0.0))
	armor = base_armor + alloy * 1.0 + float(gear.get("armor", 0.0))
	crit = clampf(base_crit + star * 0.05 + float(gear.get("crit", 0.0)), 0.0, 0.9)
	crit_mult = 1.75
	regen = base_regen + nano * 0.5 + float(gear.get("regen", 0.0))
	dash_cd_max = float(character.get("dash_cd", DASH_COOLDOWN))
	if max_hp > old_max:
		hp += max_hp - old_max
	hp = clampf(hp, 0.0, max_hp)
	hp_changed.emit(hp, max_hp)
	stats_changed.emit()


func _equip_starting_weapons() -> void:
	var entries: Array = Game.equipped_weapons()
	var seen := {}
	var fallback := String(character.get("fallback_weapon", "moon_shot"))
	if entries.is_empty():
		add_weapon(fallback)
		return
	for entry in entries:
		if not (entry is Dictionary):
			continue
		var item: Dictionary = entry.get("item", {})
		var wid := String(item.get("weapon_id", ""))
		if not WEAPON_SCRIPTS.has(wid) or seen.has(wid):
			continue
		seen[wid] = true
		add_weapon(wid)
		var start_level := EquipmentData.starting_weapon_level(item)
		while int(weapon_levels.get(wid, 0)) < start_level:
			upgrade_weapon(wid)
	if weapon_levels.is_empty():
		add_weapon(fallback)


func restore_run_state(snap: Dictionary) -> bool:
	if snap.is_empty():
		return false
	_restoring = true
	for id in weapons.keys():
		var old = weapons[id]
		if old != null and is_instance_valid(old):
			old.queue_free()
	weapons.clear()
	weapon_levels.clear()
	passive_levels.clear()
	evolutions.clear()
	banned.clear()
	_evo_notified.clear()

	var banned_data = snap.get("banned", {})
	if banned_data is Dictionary:
		for id in banned_data.keys():
			if bool(banned_data[id]):
				banned[String(id)] = true
	var passive_data = snap.get("passive_levels", {})
	if passive_data is Dictionary:
		for id in passive_data.keys():
			if GameData.PASSIVES.has(String(id)):
				passive_levels[String(id)] = maxi(0, int(passive_data[id]))
	var weapon_data = snap.get("weapon_levels", {})
	if weapon_data is Dictionary:
		for id in weapon_data.keys():
			var wid := String(id)
			if not GameData.WEAPONS.has(wid):
				continue
			add_weapon(wid)
			var target := clampi(int(weapon_data[id]), 1, int(GameData.WEAPONS[wid]["max_level"]))
			while int(weapon_levels.get(wid, 0)) < target:
				upgrade_weapon(wid)
	var evo_data = snap.get("evolutions", {})
	if evo_data is Dictionary:
		for id in evo_data.keys():
			var base_id := String(id)
			if GameData.EVOLUTIONS.has(base_id) and int(weapon_levels.get(base_id, 0)) >= 6:
				evolve_weapon(base_id)

	recalc_stats()
	var saved_pos = snap.get("position", Vector2.ZERO)
	if saved_pos is Vector2:
		var limit := GameData.ARENA_HALF - 30.0
		global_position = Vector2(
			clampf(saved_pos.x, -limit, limit),
			clampf(saved_pos.y, -limit, limit)
		)
	hp = clampf(float(snap.get("hp", max_hp)), 1.0, max_hp)
	ultimate_charge = clampf(float(snap.get("ultimate_charge", 0.0)), 0.0, ultimate_max)
	invuln = maxf(invuln, 2.0)
	dash_cd = 0.0
	dash_time = 0.0
	_last_kills = Game.kills
	_flash = 0.0
	_restoring = false
	hp_changed.emit(hp, max_hp)
	stats_changed.emit()
	return true


func add_weapon(id: String) -> void:
	if banned.has(id):
		return
	if weapon_levels.has(id):
		upgrade_weapon(id)
		return
	var script: Script = WEAPON_SCRIPTS.get(id)
	if script == null:
		return
	var w = script.new()
	_holder.add_child(w)
	w.setup(self, 1)
	weapons[id] = w
	weapon_levels[id] = 1
	stats_changed.emit()


func upgrade_weapon(id: String) -> void:
	if evolutions.has(id) or banned.has(id):
		return
	var lv := int(weapon_levels.get(id, 1)) + 1
	var info: Dictionary = GameData.WEAPONS[id]
	if lv > int(info.max_level):
		return
	weapon_levels[id] = lv
	if weapons.has(id) and is_instance_valid(weapons[id]):
		weapons[id].set_level(lv)
	stats_changed.emit()


func evolve_weapon(base_id: String) -> void:
	if banned.has(base_id):
		return
	var evo := GameData.evolution_for(base_id)
	if evo.is_empty() or evolutions.has(base_id):
		return
	if int(weapon_levels.get(base_id, 0)) < 6:
		return
	if int(passive_levels.get(String(evo["passive"]), 0)) < int(evo["passive_level"]):
		return
	if weapons.has(base_id) and is_instance_valid(weapons[base_id]):
		weapons[base_id].queue_free()
	var script: Script = load(String(evo["scene"]))
	var w = script.new()
	_holder.add_child(w)
	w.setup(self, 1)
	weapons[base_id] = w
	evolutions[base_id] = String(evo["id"])
	_evo_notified[base_id + ":ready"] = true
	stats_changed.emit()
	if not _restoring:
		FX.levelup_burst(global_position + Vector2(0, -10))
		FX.flash(Color(1.0, 0.9, 0.6), 0.35, 0.8)
		FX.shake(7.0, 0.5)
		Audio.play("levelup", 0.85, -2.0)
		Game.warning.emit("무기 진화! %s" % String(evo["name"]), 3.2)


func check_evolution_ready() -> void:
	for base_id in GameData.EVOLUTIONS.keys():
		if banned.has(base_id):
			continue
		if evolutions.has(base_id) or int(weapon_levels.get(base_id, 0)) < 6:
			continue
		var evo: Dictionary = GameData.EVOLUTIONS[base_id]
		var base_info: Dictionary = GameData.WEAPONS[base_id]
		var passive_info: Dictionary = GameData.PASSIVES[evo["passive"]]
		var need := int(evo["passive_level"])
		if int(passive_levels.get(String(evo["passive"]), 0)) < need:
			var hint_key := String(base_id) + ":hint"
			if not _evo_notified.has(hint_key):
				_evo_notified[hint_key] = true
				Game.warning.emit("%s 완성 · %s %dLv → %s" % [
					String(base_info["name"]), String(passive_info["name"]), need, String(evo["name"])
				], 3.2)
				FX.float_text(global_position + Vector2(0, -38), "진화 조건", Color(1.0, 0.82, 0.4), 20)
		else:
			var ready_key := String(base_id) + ":ready"
			if not _evo_notified.has(ready_key):
				_evo_notified[ready_key] = true
				Game.warning.emit("진화 조건 충족! %s → %s" % [
					String(base_info["name"]), String(evo["name"])
				], 3.4)
				FX.float_text(global_position + Vector2(0, -42), "진화 가능!", Color(1.0, 0.86, 0.45), 24)
				Audio.play("levelup", 1.25, -10.0)


func apply_upgrade(choice: Dictionary) -> void:
	match String(choice.get("kind", "")):
		"weapon":
			var id := String(choice["id"])
			if weapon_levels.has(id):
				upgrade_weapon(id)
			else:
				add_weapon(id)
		"passive":
			var id := String(choice["id"])
			passive_levels[id] = int(passive_levels.get(id, 0)) + 1
			recalc_stats()
		"heal":
			heal(35.0)
		"xp":
			Game.add_xp(30)
		"nova":
			if manager != null:
				manager.damage_all(120.0, self)
			FX.flash(Color(0.7, 1.0, 0.9), 0.2, 0.4)
			FX.shake(6.0, 0.3)
		"evolution":
			evolve_weapon(String(choice["id"]))
	stats_changed.emit()
	check_evolution_ready()


func get_upgrade_choices(count: int = 3) -> Array:
	var pool: Array = []
	for id in GameData.WEAPONS.keys():
		if evolutions.has(id) or banned.has(id):
			continue
		var info: Dictionary = GameData.WEAPONS[id]
		var lv := int(weapon_levels.get(id, 0))
		if lv == 0:
			pool.append({
				"kind": "weapon", "id": id, "name": info.name, "tag": info.tag,
				"icon": info.icon, "desc": String(info.desc) + "\n" + GameData.weapon_detail(id, 1),
				"level": 1, "old_level": 0, "max_level": int(info.max_level),
				"color": info.color, "is_new": true, "weight": 1.8,
			})
		elif lv < int(info.max_level):
			pool.append({
				"kind": "weapon", "id": id, "name": info.name, "tag": info.tag,
				"icon": info.icon, "desc": GameData.weapon_detail(id, lv + 1),
				"level": lv + 1, "old_level": lv, "max_level": int(info.max_level),
				"color": info.color, "is_new": false, "weight": 1.2,
			})
	for id in GameData.PASSIVES.keys():
		if banned.has(id):
			continue
		var info: Dictionary = GameData.PASSIVES[id]
		var lv := int(passive_levels.get(id, 0))
		if lv >= int(info.max_level):
			continue
		pool.append({
			"kind": "passive", "id": id, "name": info.name, "tag": info.tag,
			"icon": info.icon, "desc": GameData.passive_detail(id, lv + 1),
			"level": lv + 1, "old_level": lv, "max_level": int(info.max_level),
			"color": info.color, "is_new": lv == 0, "weight": 1.0,
		})
	var evo_cards: Array = []
	for base_id in GameData.EVOLUTIONS.keys():
		if evolutions.has(base_id) or banned.has(base_id) or int(weapon_levels.get(base_id, 0)) < 6:
			continue
		var evo: Dictionary = GameData.EVOLUTIONS[base_id]
		if int(passive_levels.get(String(evo["passive"]), 0)) < int(evo["passive_level"]):
			continue
		var base_info: Dictionary = GameData.WEAPONS[base_id]
		var passive_info: Dictionary = GameData.PASSIVES[evo["passive"]]
		evo_cards.append({
			"kind": "evolution", "id": base_id, "evo_id": evo["id"],
			"name": evo["name"], "tag": evo["tag"], "icon": evo["icon"],
			"desc": "%s 6Lv + %s %dLv\n%s" % [
				String(base_info["name"]), String(passive_info["name"]),
				int(evo["passive_level"]), String(evo["desc"])
			],
			"level": 1, "old_level": 6, "max_level": 1,
			"color": evo["color"], "is_new": false, "weight": 0.0,
		})
	var evo_slots := 1 if not evo_cards.is_empty() else 0
	if pool.size() + evo_slots < count:
		pool.append({
			"kind": "heal", "id": "heal", "name": "달빛 회복", "tag": "MOON HEAL",
			"icon": "res://assets/art/ui/icon_heart.png",
			"desc": "체력을 35 회복합니다.", "level": 0, "old_level": 0, "max_level": 0,
			"color": Color(0.92, 0.45, 0.42), "is_new": false, "weight": 0.7,
		})
	if pool.size() + evo_slots < count:
		pool.append({
			"kind": "xp", "id": "xp", "name": "응축된 달빛", "tag": "MOON XP",
			"icon": "res://assets/art/ui/icon_moon.png",
			"desc": "경험치를 30 얻습니다.", "level": 0, "old_level": 0, "max_level": 0,
			"color": Color(0.7, 0.9, 1.0), "is_new": false, "weight": 0.6,
		})
	if pool.size() + evo_slots < count:
		pool.append({
			"kind": "nova", "id": "nova", "name": "달빛 폭발", "tag": "MOON BURST",
			"icon": "res://assets/art/ui/icon_pulse.png",
			"desc": "화면의 모든 적에게 120 피해를 줍니다.", "level": 0, "old_level": 0,
			"max_level": 0, "color": Color(0.6, 0.95, 1.0), "is_new": false, "weight": 0.6,
		})
	var picked: Array = []
	if not evo_cards.is_empty():
		picked.append(evo_cards[randi() % evo_cards.size()])
	while picked.size() < count and pool.size() > 0:
		var total := 0.0
		for c in pool:
			total += float(c["weight"])
		var r := randf() * total
		var idx := 0
		for i in pool.size():
			r -= float(pool[i]["weight"])
			if r <= 0.0:
				idx = i
				break
		picked.append(pool[idx])
		pool.remove_at(idx)
	return picked


func roll_damage(base: float) -> Dictionary:
	var dmg := base * damage_mult
	var is_crit := randf() < crit
	if is_crit:
		dmg *= crit_mult
	return {"damage": dmg, "crit": is_crit}


func take_damage(amount: float) -> bool:
	if dead or invuln > 0.0 or not Game.running:
		return false
	var dmg := maxf(1.0, amount - armor)
	hp = maxf(0.0, hp - dmg)
	invuln = 0.75
	_flash = 0.12
	hp_changed.emit(hp, max_hp)
	FX.hurt(global_position)
	FX.damage_number(global_position + Vector2(0, -30), dmg, Color(1.0, 0.45, 0.42))
	Audio.play("hurt", randf_range(0.9, 1.06), -2.0)
	FX.set_low_hp(hp < max_hp * 0.3)
	if hp <= 0.0:
		_die()
	return true


func heal(amount: float, show_fx: bool = true) -> void:
	if dead:
		return
	var before := hp
	hp = minf(max_hp, hp + amount)
	if hp > before:
		hp_changed.emit(hp, max_hp)
		FX.set_low_hp(hp < max_hp * 0.3)
		if show_fx:
			FX.float_text(global_position + Vector2(0, -34), "+%d" % int(amount), Color(0.6, 1.0, 0.75), 20)


func _die() -> void:
	if dead:
		return
	dead = true
	Game.end_run(false)
	Audio.play("gameover", 1.0, -1.0)
	FX.enemy_death(global_position + Vector2(0, -10), Color(0.95, 0.8, 0.55), true)
	FX.flash(Color(0.9, 0.2, 0.15), 0.35, 0.8)
	FX.shake(12.0, 0.7)
	_sprite.visible = false
	_aura.visible = false
	set_process(false)
	died.emit()


func collect(value: int, kind: String = "xp") -> void:
	if dead:
		return
	if kind == "heart":
		heal(20.0)
		Audio.play("heal", 1.0, -2.0)
		FX.pickup_fx(global_position, Color(1.0, 0.5, 0.5), 5)
	else:
		Game.add_xp(value)
		Audio.play_pickup(value)
		FX.pickup_fx(global_position + Vector2(0, -8), Color(0.65, 0.9, 1.0), value)


func set_low_hp_state() -> void:
	FX.set_low_hp(hp < max_hp * 0.3)
