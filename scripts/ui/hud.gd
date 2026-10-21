extends CanvasLayer

## In-game HUD: XP, timer, kills, HP, skills, passives, boss bar, warnings.

const WEAPON_ORDER := ["moon_shot", "satellite", "pulse", "laser"]
const PASSIVE_ORDER := ["boots", "core", "coolant", "heart", "magnet", "star", "armor", "nano"]

var player
var manager
var world

var root: Control
var xp_bar: PixelBar
var level_label: Label
var stage_label: Label
var timer_label: Label
var timer_sub: Label
var kills_label: Label
var hp_bar: PixelBar
var hp_label: Label
var boss_panel: Panel
var boss_bar: PixelBar
var boss_name: Label
var boss_hp_text: Label
var warning_panel: Panel
var warning_label: Label
var hp_panel: Panel
var _weapon_slots: Array = []
var _passive_slots: Array = []
var _dash_overlay: ColorRect
var _ult_overlay: ColorRect
var _dash_key: Label
var _ult_slot: Panel
var _ult_icon: TextureRect
var _ult_key: Label
var _hint: Label
var _xp_bg: ColorRect
var _timer_panel: Panel
var _kills_panel: Panel
var _weapon_panel: Panel
var _passive_panel: Panel
var _dash_root: Panel
var _ult_root: Panel
var _ult_ready := false
var _last_level := 0
var _warning_id := 0
var _warning_tw: Tween
var _time := 0.0


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.name = "HUDRoot"
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build()
	_fit_ui()
	get_viewport().size_changed.connect(_fit_ui)


func _build() -> void:
	# top XP strip
	var xp_bg := ColorRect.new()
	xp_bg.color = Color(0.02, 0.035, 0.055, 0.9)
	xp_bg.position = Vector2(0, 0)
	xp_bg.size = Vector2(1280, 18)
	xp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(xp_bg)
	_xp_bg = xp_bg
	xp_bar = PixelBar.new()
	xp_bar.position = Vector2(0, 0)
	xp_bar.size = Vector2(1280, 14)
	xp_bar.fill_color = UIKit.GOLD
	xp_bar.border_color = Color(0.20, 0.17, 0.10)
	root.add_child(xp_bar)

	var badge := UIKit.panel(Color(0.055, 0.082, 0.12, 0.98), UIKit.GOLD, 2)
	UIKit.place(badge, 18, 24, 104, 36)
	root.add_child(badge)
	level_label = UIKit.label("LV.1", 20, UIKit.GOLD)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.size = Vector2(104, 36)
	badge.add_child(level_label)

	var stage_chip := UIKit.panel(Color(0.045, 0.07, 0.105, 0.9), UIKit.BORDER, 2)
	UIKit.place(stage_chip, 132, 24, 188, 36)
	root.add_child(stage_chip)
	stage_label = UIKit.label("", 14, UIKit.CREAM)
	stage_label.position = Vector2(10, 8)
	stage_label.size = Vector2(168, 22)
	stage_chip.add_child(stage_label)

	_hint = UIKit.label("WASD 이동 · Space 대시 · Q 궁극기 · 공격 자동", 13, UIKit.MUTED)
	_hint.position = Vector2(22, 66)
	root.add_child(_hint)

	# timer
	var timer_panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.94), Color(0.58, 0.47, 0.27, 0.9), 2)
	UIKit.place(timer_panel, 520, 20, 240, 78)
	root.add_child(timer_panel)
	_timer_panel = timer_panel
	var moon_icon := UIKit.icon("res://assets/art/ui/icon_moon.png", 28)
	moon_icon.position = Vector2(16, 20)
	timer_panel.add_child(moon_icon)
	timer_label = UIKit.label("10:00", 40, UIKit.CREAM, 4)
	timer_label.position = Vector2(52, 6)
	timer_label.size = Vector2(176, 48)
	timer_panel.add_child(timer_label)
	timer_sub = UIKit.label("새벽까지", 15, UIKit.MUTED)
	timer_sub.position = Vector2(54, 50)
	timer_panel.add_child(timer_sub)

	# kills
	var kills_panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.9), UIKit.BORDER, 2)
	UIKit.place(kills_panel, 1116, 24, 146, 40)
	root.add_child(kills_panel)
	_kills_panel = kills_panel
	var alien_icon := UIKit.icon("res://assets/art/ui/icon_alien.png", 26)
	alien_icon.position = Vector2(10, 7)
	kills_panel.add_child(alien_icon)
	kills_label = UIKit.label("0", 22, UIKit.CREAM)
	kills_label.position = Vector2(44, 7)
	kills_label.size = Vector2(92, 26)
	kills_panel.add_child(kills_label)

	# boss bar
	boss_panel = UIKit.panel(Color(0.06, 0.045, 0.10, 0.94), Color(0.55, 0.32, 0.8, 0.95), 2)
	UIKit.place(boss_panel, 390, 568, 500, 58)
	boss_panel.visible = false
	root.add_child(boss_panel)
	boss_name = UIKit.label("외계 모선", 22, Color(0.9, 0.75, 1.0), 3)
	boss_name.position = Vector2(14, 4)
	boss_panel.add_child(boss_name)
	boss_hp_text = UIKit.label("100%", 15, UIKit.MUTED)
	boss_hp_text.position = Vector2(424, 6)
	boss_hp_text.size = Vector2(56, 20)
	boss_hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boss_panel.add_child(boss_hp_text)
	boss_bar = PixelBar.new()
	boss_bar.position = Vector2(14, 34)
	boss_bar.size = Vector2(472, 16)
	boss_bar.fill_color = Color(0.78, 0.35, 0.9)
	boss_bar.border_color = Color(0.25, 0.12, 0.3)
	boss_panel.add_child(boss_bar)

	# warning banner
	warning_panel = UIKit.panel(Color(0.10, 0.045, 0.055, 0.96), Color(0.95, 0.45, 0.4, 0.95), 2)
	UIKit.place(warning_panel, 280, 196, 720, 58)
	warning_panel.visible = false
	root.add_child(warning_panel)
	warning_label = UIKit.label("외계 함대 접근", 26, Color(1.0, 0.82, 0.7), 4)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.size = Vector2(716, 54)
	warning_panel.add_child(warning_label)

	# HP
	hp_panel = UIKit.panel(Color(0.045, 0.07, 0.105, 0.94), Color(0.42, 0.18, 0.18), 2)
	UIKit.place(hp_panel, 24, 646, 348, 52)
	root.add_child(hp_panel)
	var heart := UIKit.icon("res://assets/art/ui/icon_heart.png", 30)
	heart.position = Vector2(10, 11)
	hp_panel.add_child(heart)
	hp_bar = PixelBar.new()
	hp_bar.position = Vector2(44, 13)
	hp_bar.size = Vector2(292, 26)
	hp_bar.fill_color = Color(0.86, 0.31, 0.31)
	hp_bar.border_color = Color(0.28, 0.12, 0.14)
	hp_panel.add_child(hp_bar)
	hp_label = UIKit.label("100 / 100", 16, UIKit.CREAM, 3)
	hp_label.position = Vector2(52, 17)
	hp_label.size = Vector2(276, 22)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_panel.add_child(hp_label)

	# weapon slots
	var weapon_panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.92), UIKit.BORDER, 2)
	UIKit.place(weapon_panel, 475, 646, 330, 52)
	root.add_child(weapon_panel)
	_weapon_panel = weapon_panel
	for i in WEAPON_ORDER.size():
		var info: Dictionary = GameData.WEAPONS[WEAPON_ORDER[i]]
		var slot := _make_weapon_slot(info)
		slot["root"].position = Vector2(18 + i * 77, 3)
		weapon_panel.add_child(slot["root"])
		_weapon_slots.append(slot)

	# passive slots
	var passive_panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.88), UIKit.BORDER, 2)
	UIKit.place(passive_panel, 916, 646, 340, 52)
	root.add_child(passive_panel)
	_passive_panel = passive_panel
	for i in PASSIVE_ORDER.size():
		var info: Dictionary = GameData.PASSIVES[PASSIVE_ORDER[i]]
		var slot := _make_passive_slot(info)
		slot["root"].position = Vector2(14 + i * 39, 9)
		passive_panel.add_child(slot["root"])
		_passive_slots.append(slot)

	# ability slots: dash and ultimate
	var dash_slot := _make_ability_slot(
		"res://assets/art/ui/icon_dash.png", "SPACE", 808, Color(0.55, 1.0, 0.92))
	_dash_key = dash_slot["key"]
	_dash_overlay = dash_slot["overlay"]
	_dash_root = dash_slot["root"]
	var ult_slot_data := _make_ability_slot(
		"res://assets/art/ui/icon_ultimate.png", "Q", 860, UIKit.GOLD)
	_ult_overlay = ult_slot_data["overlay"]
	_ult_slot = ult_slot_data["root"]
	_ult_root = ult_slot_data["root"]
	_ult_icon = ult_slot_data["icon"]
	_ult_key = ult_slot_data["key"]
	_ult_key.add_theme_color_override("font_color", UIKit.MUTED)
	_ult_icon.modulate = Color(1.0, 1.0, 1.0, 0.8)


func _make_ability_slot(icon_path: String, key_text: String, x: float, accent: Color) -> Dictionary:
	var p := UIKit.panel(Color(0.045, 0.07, 0.105, 0.95), UIKit.BORDER, 2)
	UIKit.place(p, x, 650, 48, 46)
	root.add_child(p)
	var icon := UIKit.icon(icon_path, 28)
	icon.position = Vector2(10, 3)
	icon.modulate.a = 0.9
	p.add_child(icon)
	var key := UIKit.label(key_text, 8, accent)
	key.position = Vector2(0, 31)
	key.size = Vector2(48, 12)
	key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(key)
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.015, 0.025, 0.72)
	overlay.position = Vector2(2, 2)
	overlay.size = Vector2(44, 28)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(overlay)
	return {"root": p, "icon": icon, "key": key, "overlay": overlay}


func _make_weapon_slot(info: Dictionary) -> Dictionary:
	var p := UIKit.panel(Color(0.065, 0.10, 0.145, 0.95), UIKit.BORDER, 2)
	p.size = Vector2(62, 46)
	var icon := UIKit.icon(info["icon"], 38)
	icon.position = Vector2(11, 3)
	icon.modulate.a = 0.13
	p.add_child(icon)
	var lv := UIKit.label("", 13, UIKit.GOLD, 2)
	lv.position = Vector2(42, 28)
	lv.size = Vector2(16, 14)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p.add_child(lv)
	var accent := ColorRect.new()
	accent.color = Color(info["color"].r, info["color"].g, info["color"].b, 0.0)
	accent.position = Vector2(2, 42)
	accent.size = Vector2(58, 2)
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(accent)
	return {"root": p, "icon": icon, "level": lv, "accent": accent, "id": info}


func _make_passive_slot(info: Dictionary) -> Dictionary:
	var p := UIKit.panel(Color(0.065, 0.10, 0.145, 0.85), UIKit.BORDER, 1)
	p.size = Vector2(31, 31)
	var icon := UIKit.icon(info["icon"], 25)
	icon.position = Vector2(3, 3)
	icon.modulate.a = 0.14
	p.add_child(icon)
	var lv := UIKit.label("", 11, UIKit.CREAM, 2)
	lv.position = Vector2(17, 16)
	lv.size = Vector2(12, 12)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p.add_child(lv)
	return {"root": p, "icon": icon, "level": lv}


func bind(p, m, w) -> void:
	player = p
	manager = m
	world = w
	player.hp_changed.connect(_on_hp)
	player.stats_changed.connect(_refresh_skills)
	Game.xp_changed.connect(_on_xp)
	Game.kills_changed.connect(_on_kills)
	_on_hp(player.hp, player.max_hp)
	_on_xp(Game.xp, Game.xp_need, Game.level)
	_on_kills(Game.kills)
	_refresh_stage()
	_refresh_skills()


func _fit_ui() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	root.position = Vector2.ZERO
	root.size = vp
	root.scale = Vector2.ONE
	if _xp_bg != null:
		_xp_bg.size = Vector2(vp.x, 18)
	if xp_bar != null:
		xp_bar.size = Vector2(vp.x, 14)
	if _timer_panel != null:
		_timer_panel.position = Vector2(vp.x * 0.5 - 120.0, 20)
	if _kills_panel != null:
		_kills_panel.position = Vector2(vp.x - 164.0, 24)
	if warning_panel != null:
		warning_panel.position = Vector2(vp.x * 0.5 - 360.0, 196)
	if boss_panel != null:
		boss_panel.position = Vector2(vp.x * 0.5 - 250.0, vp.y - 152.0)
	if hp_panel != null:
		hp_panel.position = Vector2(24, vp.y - 74.0)
	if _weapon_panel != null:
		_weapon_panel.position = Vector2(vp.x * 0.5 - 165.0, vp.y - 74.0)
	if _passive_panel != null:
		_passive_panel.position = Vector2(vp.x - 364.0, vp.y - 74.0)
	if _dash_root != null:
		_dash_root.position = Vector2(vp.x * 0.5 + 168.0, vp.y - 70.0)
	if _ult_root != null:
		_ult_root.position = Vector2(vp.x * 0.5 + 220.0, vp.y - 70.0)


func set_touch_mode(enabled: bool) -> void:
	if _hint != null:
		_hint.visible = not enabled
	if _dash_key != null:
		_dash_key.visible = not enabled
	if _ult_key != null:
		_ult_key.visible = not enabled


func _on_hp(current: float, maximum: float) -> void:
	hp_bar.set_values(current, maximum, true)
	hp_label.text = "%d / %d" % [int(round(current)), int(round(maximum))]
	hp_label.add_theme_color_override("font_color", UIKit.GOLD_L if current < maximum * 0.3 else UIKit.CREAM)


func _on_xp(_xp: int, _need: int, level: int) -> void:
	xp_bar.set_values(float(_xp), float(_need), false)
	level_label.text = "LV.%d" % level
	if level > _last_level and _last_level > 0:
		level_label.pivot_offset = Vector2(52, 18)
		level_label.scale = Vector2(1.35, 1.35)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(level_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_last_level = level


func _on_kills(kills: int) -> void:
	kills_label.text = str(kills)


func _refresh_stage() -> void:
	var st := Game.stage_data()
	var diff := Game.difficulty_data()
	stage_label.text = "%s · %s" % [String(st["short"]), String(diff["name"])]
	stage_label.add_theme_color_override("font_color", diff["color"])
	timer_sub.text = "%s · %s" % [String(st["short"]), String(diff["name"])]
	timer_sub.add_theme_color_override("font_color", UIKit.MUTED)


func _refresh_skills() -> void:
	for i in _weapon_slots.size():
		var slot: Dictionary = _weapon_slots[i]
		var id: String = WEAPON_ORDER[i]
		var lv := int(player.weapon_levels.get(id, 0))
		var evo_id := String(player.evolutions.get(id, ""))
		var info: Dictionary = GameData.WEAPONS[id]
		if evo_id != "":
			var evo: Dictionary = GameData.EVOLUTIONS[id]
			slot["icon"].texture = load(String(evo["icon"]))
			slot["icon"].modulate.a = 1.0
			slot["level"].text = "★"
			slot["accent"].color = evo["color"]
			slot["accent"].color.a = 0.9
		else:
			slot["icon"].texture = load(String(info["icon"]))
			slot["icon"].modulate.a = 1.0 if lv > 0 else 0.13
			slot["level"].text = str(lv) if lv > 0 else ""
			slot["accent"].color = info["color"]
			slot["accent"].color.a = 0.9 if lv > 0 else 0.0
	for i in _passive_slots.size():
		var slot: Dictionary = _passive_slots[i]
		var id: String = PASSIVE_ORDER[i]
		var lv := int(player.passive_levels.get(id, 0))
		slot["icon"].modulate.a = 1.0 if lv > 0 else 0.14
		slot["level"].text = str(lv) if lv > 0 else ""


func tick(delta: float) -> void:
	_time += delta
	if Game.running:
		var t := Game.time_left()
		timer_label.text = GameData.format_time(t)
		var st := Game.stage_data()
		if t <= 35.0:
			var pulse := 0.65 + 0.35 * absf(sin(_time * 6.0))
			timer_label.add_theme_color_override("font_color", UIKit.CORAL.lerp(UIKit.GOLD_L, pulse))
			timer_sub.text = String(st.get("goal", "새벽까지"))
			timer_sub.add_theme_color_override("font_color", UIKit.CORAL)
		else:
			timer_label.add_theme_color_override("font_color", UIKit.CREAM)
			timer_sub.text = "%s · %s" % [String(st["short"]), String(Game.difficulty_data()["name"])]
			timer_sub.add_theme_color_override("font_color", UIKit.MUTED)
	var b = Game.boss
	if b != null and is_instance_valid(b) and not b.dead:
		boss_panel.visible = true
		boss_bar.set_values(b.hp, b.max_hp, false)
		boss_name.text = String(b.display_name)
		boss_hp_text.text = "%d%%" % int(maxf(0.0, b.hp / b.max_hp) * 100.0)
		boss_bar.fill_color = Color(1.0, 0.28, 0.3) if b.enraged else Color(0.78, 0.35, 0.9)
	else:
		boss_panel.visible = false
	# low HP pulse
	if player != null and is_instance_valid(player) and player.hp < player.max_hp * 0.3:
		hp_bar.fill_color = Color(0.95, 0.25, 0.24).lerp(Color(1.0, 0.55, 0.3), 0.5 + 0.5 * sin(_time * 7.0))
	# ability cooldowns
	if player != null and is_instance_valid(player):
		var dash_frac := clampf(player.dash_cd / maxf(0.001, player.dash_cd_max), 0.0, 1.0)
		var dh := 28.0 * dash_frac
		_dash_overlay.visible = dash_frac > 0.001
		_dash_overlay.position.y = 2.0 + (28.0 - dh)
		_dash_overlay.size.y = dh
		var ult_frac := clampf(1.0 - player.ultimate_charge / maxf(0.001, player.ultimate_max), 0.0, 1.0)
		var uh := 28.0 * ult_frac
		_ult_overlay.visible = ult_frac > 0.001
		_ult_overlay.position.y = 2.0 + (28.0 - uh)
		_ult_overlay.size.y = uh
		var ready: bool = player.ultimate_charge >= player.ultimate_max
		if ready != _ult_ready:
			_ult_ready = ready
			_ult_slot.add_theme_stylebox_override("panel", UIKit.style(
				Color(0.13, 0.11, 0.07, 0.98) if ready else Color(0.045, 0.07, 0.105, 0.95),
				UIKit.GOLD if ready else UIKit.BORDER, 2))
			_ult_icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if ready else Color(1.0, 1.0, 1.0, 0.8)
			_ult_key.add_theme_color_override("font_color", UIKit.GOLD if ready else UIKit.MUTED)


func show_warning(text: String, duration: float = 3.0) -> void:
	_warning_id += 1
	warning_label.text = text
	warning_panel.visible = true
	warning_panel.modulate.a = 0.0
	warning_panel.scale = Vector2(0.92, 0.92)
	warning_panel.pivot_offset = Vector2(360, 29)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_parallel(true)
	tw.tween_property(warning_panel, "modulate:a", 1.0, 0.18)
	tw.tween_property(warning_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _warning_tw != null and _warning_tw.is_valid():
		_warning_tw.kill()
	_warning_tw = create_tween()
	_warning_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_warning_tw.tween_interval(duration)
	_warning_tw.tween_property(warning_panel, "modulate:a", 0.0, 0.3)
	_warning_tw.tween_callback(func(): warning_panel.visible = false)
