extends CanvasLayer

## Level-up cards, pause menu, defeat / dawn screens.

const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")

var player
var hud

var root: Control
var dim: ColorRect
var levelup_root: Control
var relic_root: Control
var relic_box: HBoxContainer
var pause_root: Control
var end_root: Control
var levelup_hint: Label
var levelup_sub: Label
var cards_box: HBoxContainer
var _reroll_button: Button
var _banish_button: Button
var _settings_panel: Control
var pause_stats: Label
var end_title: Label
var end_sub: Label
var end_icon: TextureRect
var end_stats: Label
var end_record: Label
var end_reward: Label
var _choices: Array = []
var _cards: Array = []
var _pause_visible := false
var _end_visible := false
var _levelup_visible := false
var _relic_visible := false
var _relic_choices: Array = []
var _relic_cards: Array = []
var _banish_mode := false
var _end_panel: PanelContainer
var _next_button: Button
var _end_key_hint: Label
var _end_has_next := false
var _backdrop: ColorRect


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0.006, 0.012, 0.022, 0.58)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.visible = false
	add_child(_backdrop)
	root = Control.new()
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.visible = false
	add_child(root)
	_build()
	dim.color = Color(0.006, 0.012, 0.022, 0.0)
	UIFit.fit_canvas_control(root)


func bind(p, h) -> void:
	player = p
	hud = h


func _build() -> void:
	dim = UIKit.dimmer(0.72)
	root.add_child(dim)

	# ---------------------------------------------------------- level up
	levelup_root = Control.new()
	levelup_root.size = Vector2(1280, 720)
	levelup_root.visible = false
	levelup_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(levelup_root)

	var glow := TextureRect.new()
	glow.texture = load("res://assets/art/fx/glow_gold.png")
	glow.position = Vector2(340, -30)
	glow.size = Vector2(600, 300)
	glow.modulate = Color(1, 0.85, 0.45, 0.18)
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	levelup_root.add_child(glow)

	var header := UIKit.label("레벨 업!", 56, UIKit.GOLD, 8)
	header.position = Vector2(0, 70)
	header.size = Vector2(1280, 70)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	levelup_root.add_child(header)
	levelup_sub = UIKit.label("달빛 강화를 선택하세요", 22, UIKit.MUTED)
	levelup_sub.position = Vector2(0, 148)
	levelup_sub.size = Vector2(1280, 30)
	levelup_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	levelup_root.add_child(levelup_sub)

	cards_box = HBoxContainer.new()
	cards_box.position = Vector2(170, 216)
	cards_box.size = Vector2(940, 396)
	cards_box.add_theme_constant_override("separation", 30)
	cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	levelup_root.add_child(cards_box)

	levelup_hint = UIKit.label("1 / 2 / 3 선택 · R 리롤 · B 밴", 17, UIKit.MUTED)
	levelup_hint.position = Vector2(0, 674)
	levelup_hint.size = Vector2(1280, 26)
	levelup_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	levelup_root.add_child(levelup_hint)

	_reroll_button = UIKit.button("리롤 (R) ×2", Vector2(170, 40))
	_reroll_button.position = Vector2(462, 622)
	_reroll_button.add_theme_font_size_override("font_size", 16)
	_reroll_button.pressed.connect(_reroll)
	levelup_root.add_child(_reroll_button)

	_banish_button = UIKit.button("밴 (B) ×1", Vector2(170, 40))
	_banish_button.position = Vector2(648, 622)
	_banish_button.add_theme_font_size_override("font_size", 16)
	_banish_button.pressed.connect(_toggle_banish)
	levelup_root.add_child(_banish_button)

	# ---------------------------------------------------------- relics
	relic_root = Control.new()
	relic_root.size = Vector2(1280, 720)
	relic_root.visible = false
	relic_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(relic_root)

	var relic_glow := TextureRect.new()
	relic_glow.texture = load("res://assets/art/fx/glow_green.png")
	relic_glow.position = Vector2(390, -30)
	relic_glow.size = Vector2(500, 300)
	relic_glow.modulate = Color(0.72, 0.65, 1.0, 0.2)
	relic_glow.stretch_mode = TextureRect.STRETCH_SCALE
	relic_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	relic_root.add_child(relic_glow)

	var relic_header := UIKit.label("유물 발견!", 56, UIKit.GOLD, 8)
	relic_header.position = Vector2(0, 70)
	relic_header.size = Vector2(1280, 70)
	relic_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_root.add_child(relic_header)

	var relic_sub := UIKit.label("이번 런의 방향을 바꿀 유물을 하나 선택하세요", 22, UIKit.MUTED)
	relic_sub.position = Vector2(0, 148)
	relic_sub.size = Vector2(1280, 30)
	relic_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_root.add_child(relic_sub)

	relic_box = HBoxContainer.new()
	relic_box.position = Vector2(170, 216)
	relic_box.size = Vector2(940, 396)
	relic_box.add_theme_constant_override("separation", 30)
	relic_box.alignment = BoxContainer.ALIGNMENT_CENTER
	relic_root.add_child(relic_box)

	var relic_hint := UIKit.label("1 / 2 / 3 선택", 17, UIKit.MUTED)
	relic_hint.position = Vector2(0, 674)
	relic_hint.size = Vector2(1280, 26)
	relic_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_root.add_child(relic_hint)

	# ---------------------------------------------------------- pause
	pause_root = Control.new()
	pause_root.size = Vector2(1280, 720)
	pause_root.visible = false
	pause_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pause_root)
	var pause_panel := UIKit.panel_container(Color(0.047, 0.075, 0.114, 0.98), UIKit.BORDER, 2, 26)
	pause_panel.position = Vector2(420, 110)
	pause_panel.custom_minimum_size = Vector2(440, 500)
	pause_panel.size = Vector2(440, 500)
	pause_root.add_child(pause_panel)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 12)
	pause_panel.add_child(pv)
	var ptitle := UIKit.label("일시정지", 46, UIKit.GOLD, 5)
	ptitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(ptitle)
	var psub := UIKit.label("무기 6Lv + 지정 패시브 3Lv → 진화", 17, UIKit.MUTED)
	psub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(psub)
	pause_stats = UIKit.label("", 16, UIKit.MINT)
	pause_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_stats.custom_minimum_size = Vector2(380, 0)
	pv.add_child(pause_stats)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	pv.add_child(spacer)
	var b1 := UIKit.button("계속하기", Vector2(360, 56))
	b1.pressed.connect(_resume)
	pv.add_child(b1)
	var b2 := UIKit.button("다시 시작", Vector2(360, 56))
	b2.pressed.connect(_restart)
	pv.add_child(b2)
	var b3 := UIKit.button("전선 선택", Vector2(360, 56))
	b3.pressed.connect(_go_stage_select)
	pv.add_child(b3)
	var b4 := UIKit.button("설정", Vector2(360, 56))
	b4.pressed.connect(_open_settings)
	pv.add_child(b4)

	# ---------------------------------------------------------- end
	end_root = Control.new()
	end_root.size = Vector2(1280, 720)
	end_root.visible = false
	end_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(end_root)
	var end_panel := UIKit.panel_container(Color(0.047, 0.075, 0.114, 0.98), UIKit.GOLD, 2, 30)
	_end_panel = end_panel
	end_panel.position = Vector2(270, 80)
	end_panel.custom_minimum_size = Vector2(740, 560)
	end_panel.size = Vector2(740, 560)
	end_root.add_child(end_panel)
	var ev := VBoxContainer.new()
	ev.add_theme_constant_override("separation", 10)
	end_panel.add_child(ev)
	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 74)
	ev.add_child(icon_center)
	end_icon = UIKit.icon("res://assets/art/ui/icon_trophy.png", 64)
	icon_center.add_child(end_icon)
	end_title = UIKit.label("새벽이 밝았다!", 54, UIKit.GOLD, 7)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ev.add_child(end_title)
	end_sub = UIKit.label("", 19, UIKit.MUTED)
	end_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ev.add_child(end_sub)
	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.35)
	line.custom_minimum_size = Vector2(0, 2)
	ev.add_child(line)
	var stat_center := CenterContainer.new()
	stat_center.custom_minimum_size = Vector2(0, 92)
	ev.add_child(stat_center)
	end_stats = UIKit.label("", 24, UIKit.CREAM)
	end_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat_center.add_child(end_stats)
	end_record = UIKit.label("", 16, UIKit.MINT)
	end_record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ev.add_child(end_record)
	end_reward = UIKit.label("", 14, UIKit.GOLD)
	end_reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_reward.custom_minimum_size = Vector2(0, 22)
	ev.add_child(end_reward)
	var spacer2 := Control.new()
	spacer2.custom_minimum_size.y = 4
	ev.add_child(spacer2)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	ev.add_child(buttons)
	_next_button = UIKit.button("다음 전선", Vector2(190, 58))
	_next_button.pressed.connect(_next_stage)
	buttons.add_child(_next_button)
	var retry := UIKit.button("다시 도전", Vector2(190, 58))
	retry.pressed.connect(_restart)
	buttons.add_child(retry)
	var select_btn := UIKit.button("전선 선택", Vector2(190, 58))
	select_btn.pressed.connect(_go_stage_select)
	buttons.add_child(select_btn)
	_end_key_hint = UIKit.label("ENTER 다시 도전   ·   ESC 전선 선택", 13, UIKit.MUTED)
	_end_key_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ev.add_child(_end_key_hint)

	_settings_panel = SettingsPanel.new()
	root.add_child(_settings_panel)


func is_blocking() -> bool:
	return _levelup_visible or _pause_visible or _end_visible or _relic_visible


func _set_hud_visible(v: bool) -> void:
	if hud != null and is_instance_valid(hud):
		hud.visible = v


# ------------------------------------------------------------------ level up
func show_levelup(choices: Array) -> void:
	_choices = choices
	_pause_visible = false
	_end_visible = false
	_relic_visible = false
	_banish_mode = false
	pause_root.visible = false
	end_root.visible = false
	relic_root.visible = false
	_levelup_visible = true
	root.visible = true
	dim.visible = true
	_backdrop.visible = true
	levelup_root.visible = true
	_set_hud_visible(false)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	levelup_hint.visible = true
	levelup_hint.text = "1 / 2 / 3 선택 · R 리롤 · B 밴"
	levelup_sub.text = "달빛 강화를 선택하세요 · Lv.%d" % Game.level
	levelup_sub.add_theme_color_override("font_color", UIKit.MUTED)
	_update_levelup_buttons()
	for c in _cards:
		if is_instance_valid(c):
			cards_box.remove_child(c)
			c.queue_free()
	_cards.clear()
	for i in choices.size():
		var card := _make_card(choices[i], i)
		cards_box.add_child(card)
		_cards.append(card)
	await get_tree().create_timer(0.02, true, false, true).timeout
	for i in _cards.size():
		var card: Control = _cards[i]
		card.pivot_offset = card.size * 0.5
		card.scale = Vector2(0.92, 0.92)
		card.modulate.a = 0.0
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_interval(i * 0.045)
		tw.set_parallel(true)
		tw.tween_property(card, "modulate:a", 1.0, 0.2)
		tw.tween_property(card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _make_card(choice: Dictionary, index: int) -> PanelContainer:
	var accent: Color = choice.get("color", UIKit.GOLD)
	var card := UIKit.panel_container(Color(0.06, 0.095, 0.14, 0.98), accent.darkened(0.25), 3, 16)
	card.custom_minimum_size = Vector2(290, 386)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)

	var stripe := ColorRect.new()
	stripe.color = accent
	stripe.custom_minimum_size = Vector2(0, 4)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(stripe)

	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 96)
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(icon_center)
	var glow := TextureRect.new()
	glow.texture = load("res://assets/art/fx/glow_gold.png")
	glow.custom_minimum_size = Vector2(100, 100)
	glow.modulate = Color(accent.r, accent.g, accent.b, 0.2)
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(glow)
	var icon := UIKit.icon(String(choice.get("icon", "")), 76)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(icon)

	var kind := String(choice.get("kind", ""))
	var type_text := "무기 강화"
	if kind == "weapon" and bool(choice.get("is_new", false)):
		type_text = "새 무기"
	elif kind == "passive":
		type_text = "패시브"
	elif kind == "heal":
		type_text = "회복"
	elif kind == "xp":
		type_text = "달빛"
	elif kind == "nova":
		type_text = "필살기"
	elif kind == "evolution":
		type_text = "무기 진화"
	var type_label := UIKit.label(type_text, 14, accent)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(type_label)

	var name_label := UIKit.label(String(choice.get("name", "")), 25, UIKit.CREAM, 3)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(name_label)

	var lv := int(choice.get("level", 0))
	var old_lv := int(choice.get("old_level", 0))
	var level_text := ""
	if kind == "evolution":
		level_text = "MAX · EVOLUTION"
	elif old_lv > 0 and lv > old_lv:
		level_text = "Lv.%d → Lv.%d" % [old_lv, lv]
	elif lv > 0:
		level_text = "Lv.%d" % lv
	var level_label := UIKit.label(level_text, 15, UIKit.MUTED)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(level_label)

	var desc := UIKit.label(String(choice.get("desc", "")), 16, Color(0.82, 0.85, 0.88))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.custom_minimum_size = Vector2(244, 96)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	v.add_child(desc)

	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(fill)

	var key_panel := CenterContainer.new()
	key_panel.custom_minimum_size = Vector2(0, 34)
	key_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(key_panel)
	var key_label := UIKit.label("[ %d ]" % (index + 1), 17, accent, 2)
	key_panel.add_child(key_label)

	card.gui_input.connect(_on_card_input.bind(index))
	card.mouse_entered.connect(_on_card_hover.bind(card, accent, true))
	card.mouse_exited.connect(_on_card_hover.bind(card, accent, false))
	card.set_meta("accent", accent)
	return card


func _on_card_hover(card: PanelContainer, accent: Color, hovered: bool) -> void:
	if not is_instance_valid(card):
		return
	if _banish_mode:
		card.add_theme_stylebox_override("panel", UIKit.style(
			Color(0.15, 0.065, 0.075, 0.99) if hovered else Color(0.095, 0.06, 0.075, 0.99),
			UIKit.CORAL if hovered else UIKit.CORAL.darkened(0.2), 3, 0))
		return
	card.add_theme_stylebox_override("panel", UIKit.style(
		Color(0.085, 0.13, 0.19, 0.99) if hovered else Color(0.06, 0.095, 0.14, 0.98),
		accent if hovered else accent.darkened(0.25), 3, 0))


func _refresh_card_styles() -> void:
	for card in _cards:
		if not is_instance_valid(card):
			continue
		var accent: Color = card.get_meta("accent", UIKit.GOLD)
		var bg := Color(0.095, 0.06, 0.075, 0.99) if _banish_mode else Color(0.06, 0.095, 0.14, 0.98)
		var border := UIKit.CORAL.darkened(0.2) if _banish_mode else accent.darkened(0.25)
		card.add_theme_stylebox_override("panel", UIKit.style(bg, border, 3, 0))


func _on_card_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _banish_mode:
			_banish(index)
		else:
			_choose(index)


func _choose(index: int) -> void:
	if not _levelup_visible or index < 0 or index >= _choices.size():
		return
	_levelup_visible = false
	levelup_root.visible = false
	var choice: Dictionary = _choices[index]
	player.apply_upgrade(choice)
	Audio.play("click", 1.15, -2.0)
	Audio.play("pickup", 1.25, -5.0)
	FX.flash(Color(1, 0.9, 0.7), 0.12, 0.3)
	if Game.finish_levelup():
		_close_all()
		if Game.running:
			get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Audio.duck_music(false)
	else:
		await get_tree().create_timer(0.08, true, false, true).timeout
		show_levelup(player.get_upgrade_choices(3))


func show_relics(choices: Array) -> void:
	if choices.is_empty():
		return
	_relic_choices = choices
	_levelup_visible = false
	_pause_visible = false
	_end_visible = false
	_banish_mode = false
	_relic_visible = true
	levelup_root.visible = false
	pause_root.visible = false
	end_root.visible = false
	root.visible = true
	dim.visible = true
	_backdrop.visible = true
	relic_root.visible = true
	_set_hud_visible(false)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Audio.duck_music(true)
	Audio.play("levelup", 1.1, -3.0)
	for c in _relic_cards:
		if is_instance_valid(c):
			relic_box.remove_child(c)
			c.queue_free()
	_relic_cards.clear()
	for i in choices.size():
		var card := _make_relic_card(choices[i], i)
		relic_box.add_child(card)
		_relic_cards.append(card)


func _make_relic_card(choice: Dictionary, index: int) -> PanelContainer:
	var accent: Color = choice.get("color", UIKit.GOLD)
	var card := UIKit.panel_container(Color(0.06, 0.095, 0.14, 0.98), accent.darkened(0.25), 3, 16)
	card.custom_minimum_size = Vector2(290, 386)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)

	var stripe := ColorRect.new()
	stripe.color = accent
	stripe.custom_minimum_size = Vector2(0, 4)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(stripe)

	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 120)
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(icon_center)
	var glow := TextureRect.new()
	glow.texture = load("res://assets/art/fx/glow_gold.png")
	glow.custom_minimum_size = Vector2(120, 120)
	glow.modulate = Color(accent.r, accent.g, accent.b, 0.24)
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(glow)
	var icon := UIKit.icon(String(choice.get("icon", "")), 88)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(icon)

	var type_label := UIKit.label("유물", 14, accent)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(type_label)

	var name_label := UIKit.label(String(choice.get("name", "")), 25, UIKit.CREAM, 3)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(name_label)

	var tag_label := UIKit.label(String(choice.get("tag", "")), 13, UIKit.MUTED)
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tag_label)

	var desc := UIKit.label(String(choice.get("desc", "")), 16, Color(0.82, 0.85, 0.88))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.custom_minimum_size = Vector2(244, 80)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	v.add_child(desc)

	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(fill)

	var pick := UIKit.label("[%d]" % (index + 1), 16, accent)
	pick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(pick)

	card.gui_input.connect(_on_relic_input.bind(index))
	return card


func _on_relic_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_choose_relic(index)


func _choose_relic(index: int) -> void:
	if not _relic_visible or index < 0 or index >= _relic_choices.size():
		return
	_relic_visible = false
	relic_root.visible = false
	var relic: Dictionary = _relic_choices[index]
	if player != null and is_instance_valid(player):
		player.add_relic(String(relic.get("id", "")))
		Game.warning.emit("유물 · %s" % String(relic.get("name", "")), 2.6)
	Audio.play("click", 1.15, -2.0)
	Audio.play("pickup", 1.25, -5.0)
	FX.flash(Color(0.7, 0.9, 1.0), 0.14, 0.3)
	FX.ring(player.global_position if player != null and is_instance_valid(player) else Vector2.ZERO,
		Color(0.75, 0.9, 1.0), 70.0, 0.5, "halo")
	_close_all()
	if Game.running:
		get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Audio.duck_music(false)


func _close_all() -> void:
	_levelup_visible = false
	_pause_visible = false
	_end_visible = false
	_relic_visible = false
	_banish_mode = false
	levelup_root.visible = false
	relic_root.visible = false
	pause_root.visible = false
	end_root.visible = false
	root.visible = false
	_backdrop.visible = false
	_set_hud_visible(true)


# ------------------------------------------------------------------ reroll / banish
func _update_levelup_buttons() -> void:
	if _reroll_button == null or _banish_button == null:
		return
	_reroll_button.text = "리롤 (R) ×%d" % Game.rerolls
	_reroll_button.disabled = Game.rerolls <= 0 or _banish_mode
	_reroll_button.modulate.a = 0.45 if _reroll_button.disabled else 1.0
	if _banish_mode:
		_banish_button.text = "취소 (B)"
		_banish_button.disabled = false
	else:
		_banish_button.text = "밴 (B) ×%d" % Game.banishes
		_banish_button.disabled = Game.banishes <= 0
	_banish_button.modulate.a = 0.45 if _banish_button.disabled else 1.0


func _reroll() -> void:
	if not _levelup_visible or _banish_mode:
		return
	if not Game.use_reroll():
		return
	Audio.play("click", 1.2, -4.0)
	Audio.play("levelup", 1.35, -14.0)
	show_levelup(player.get_upgrade_choices(3))
	levelup_sub.text = "선택지를 다시 뽑았습니다 · Lv.%d" % Game.level
	levelup_sub.add_theme_color_override("font_color", UIKit.MINT)


func _set_banish_mode(on: bool) -> void:
	_banish_mode = on
	if on:
		levelup_sub.text = "제외할 카드를 선택하세요 · 남은 밴 %d" % Game.banishes
		levelup_sub.add_theme_color_override("font_color", UIKit.CORAL)
		levelup_hint.text = "제외할 카드를 클릭하거나 1 / 2 / 3 · ESC 취소"
		Audio.play("click", 0.9, -5.0)
	else:
		levelup_sub.text = "달빛 강화를 선택하세요 · Lv.%d" % Game.level
		levelup_sub.add_theme_color_override("font_color", UIKit.MUTED)
		levelup_hint.text = "1 / 2 / 3 선택 · R 리롤 · B 밴"
	_refresh_card_styles()
	_update_levelup_buttons()


func _toggle_banish() -> void:
	if not _levelup_visible:
		return
	if _banish_mode:
		_set_banish_mode(false)
		return
	if Game.banishes <= 0:
		return
	_set_banish_mode(true)


func _banish(index: int) -> void:
	if not _levelup_visible or not _banish_mode:
		return
	if index < 0 or index >= _choices.size():
		return
	var choice: Dictionary = _choices[index]
	var kind := String(choice.get("kind", ""))
	if kind not in ["weapon", "passive", "evolution"]:
		levelup_sub.text = "이 카드는 제외할 수 없습니다"
		levelup_sub.add_theme_color_override("font_color", UIKit.CORAL)
		Audio.play("click", 0.75, -8.0)
		return
	if not Game.use_banish():
		return
	var id := String(choice.get("id", ""))
	player.banned[id] = true
	_banish_mode = false
	Audio.play("click", 0.8, -2.0)
	show_levelup(player.get_upgrade_choices(3))
	levelup_sub.text = "%s 제외됨 · 강화를 선택하세요" % String(choice.get("name", ""))
	levelup_sub.add_theme_color_override("font_color", UIKit.CORAL)


func _open_settings() -> void:
	if _settings_panel != null:
		_settings_panel.open()


# ------------------------------------------------------------------ pause
func toggle_pause() -> void:
	if _levelup_visible or _end_visible or _relic_visible:
		return
	if _pause_visible:
		_resume()
	else:
		_show_pause()


func _show_pause() -> void:
	_pause_visible = true
	root.visible = true
	dim.visible = true
	_backdrop.visible = true
	pause_root.visible = true
	_set_hud_visible(false)
	var st := Game.stage_data()
	var diff := Game.difficulty_data()
	if Game.is_endless():
		pause_stats.text = "무한 모드 · %s\n생존 %s · Lv.%d · %d 킬" % [
			String(st["short"]), GameData.format_time(Game.time), Game.level, Game.kills,
		]
	elif Game.is_daily():
		var mod: Dictionary = Game.daily_info.get("modifier", {})
		pause_stats.text = "오늘의 도전 · %s · %s\n%s · Lv.%d · %d 킬" % [
			String(st["short"]), String(mod.get("name", "")),
			GameData.format_time(Game.time), Game.level, Game.kills,
		]
	else:
		pause_stats.text = "%s · %s\n%s · Lv.%d · %d 킬" % [
			String(st["short"]), String(diff["name"]),
			GameData.format_time(Game.time), Game.level, Game.kills,
		]
	if player != null and is_instance_valid(player) and not player.relics.is_empty():
		var relic_names: Array = []
		for id in player.relics:
			relic_names.append(String(RelicData.get_relic(String(id)).get("name", id)))
		pause_stats.text += "\n유물 · " + ", ".join(relic_names)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Audio.duck_music(true)
	Audio.play_click()


func _resume() -> void:
	if not _pause_visible:
		return
	_pause_visible = false
	pause_root.visible = false
	_close_all()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Audio.duck_music(false)
	Audio.play_click()


func _restart() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	Game.retry_stage()


func _next_stage() -> void:
	var next := GameData.next_stage_id(Game.stage_id)
	if next == "":
		_restart()
		return
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	Game.start_stage(next, Game.difficulty_id)


func _go_stage_select() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	Game.go_stage_select()


func _go_title() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	Game.go_title()


# ------------------------------------------------------------------ end
func show_end(victory: bool, boss_killed: bool = false) -> void:
	_end_visible = true
	_levelup_visible = false
	_pause_visible = false
	_relic_visible = false
	levelup_root.visible = false
	relic_root.visible = false
	pause_root.visible = false
	root.visible = true
	dim.visible = true
	_backdrop.visible = true
	end_root.visible = true
	levelup_hint.visible = false
	_set_hud_visible(false)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Audio.duck_music(true)
	var stage := Game.stage_data()
	var diff := Game.difficulty_data()
	var next := GameData.next_stage_id(Game.stage_id)
	var endless := Game.is_endless()
	var daily := Game.is_daily()
	_end_has_next = victory and next != "" and not endless and not daily
	_next_button.visible = _end_has_next
	if endless:
		end_title.text = "무한 모드 종료"
		end_title.add_theme_color_override("font_color", UIKit.GOLD)
		end_sub.text = "%s · 생존 기록을 세웠습니다" % String(stage["short"])
		end_icon.texture = load("res://assets/art/ui/icon_trophy.png")
		_end_panel.add_theme_stylebox_override("panel", UIKit.style(Color(0.047, 0.075, 0.114, 0.98), UIKit.GOLD, 2, 30))
	elif daily:
		end_title.text = ("오늘의 도전 성공!" if victory else "오늘의 도전 종료")
		end_title.add_theme_color_override("font_color", UIKit.GOLD if victory else UIKit.CORAL)
		var mod: Dictionary = Game.daily_info.get("modifier", {})
		end_sub.text = "%s · %s · %s" % [String(stage["short"]), String(diff["name"]), String(mod.get("name", ""))]
		end_icon.texture = load("res://assets/art/ui/icon_trophy.png" if victory else "res://assets/art/ui/icon_alien.png")
		_end_panel.add_theme_stylebox_override("panel", UIKit.style(Color(0.047, 0.075, 0.114, 0.98), UIKit.GOLD if victory else UIKit.CORAL.darkened(0.25), 2, 30))
	elif victory:
		if next == "":
			end_title.text = "지구를 지켜냈다!"
			end_title.add_theme_color_override("font_color", UIKit.GOLD)
			end_sub.text = "모선을 격추하고 지구를 구했다" if boss_killed else "새벽이 밝았다 · 지구는 살아남았다"
		else:
			end_title.text = "전선 확보!"
			end_title.add_theme_color_override("font_color", UIKit.GOLD)
			end_sub.text = ("%s 격추" % String(GameData.ENEMIES[stage["boss"]]["name"])) if boss_killed else ("%s 사수 완료" % String(stage["short"]))
		end_icon.texture = load("res://assets/art/ui/icon_trophy.png")
		_end_panel.add_theme_stylebox_override("panel", UIKit.style(Color(0.047, 0.075, 0.114, 0.98), UIKit.GOLD, 2, 30))
	else:
		end_title.text = "전선 붕괴..."
		end_title.add_theme_color_override("font_color", UIKit.CORAL)
		end_sub.text = "%s · 다시 일어나자" % String(stage["short"])
		end_icon.texture = load("res://assets/art/ui/icon_alien.png")
		_end_panel.add_theme_stylebox_override("panel", UIKit.style(Color(0.047, 0.075, 0.114, 0.98), UIKit.CORAL.darkened(0.25), 2, 30))
	end_stats.text = "생존 %s      Lv.%d      %d 킬" % [GameData.format_time(Game.time), Game.level, Game.kills]
	if endless:
		var er: Dictionary = Game.endless_best(Game.stage_id)
		end_record.text = "무한 · 최고 생존 %s · %d 킬" % [
			GameData.format_time(float(er.get("best_time", 0.0))),
			int(er.get("best_kills", 0)),
		]
	elif daily:
		var dr: Dictionary = Game.daily_record()
		end_record.text = "오늘의 도전 · 최고 %s · %d 킬 · 클리어 %d" % [
			GameData.format_time(float(dr.get("best_time", 0.0))),
			int(dr.get("best_kills", 0)), int(dr.get("clears", 0)),
		]
	else:
		end_record.text = "%s · %s" % [String(diff["name"]), Game.stage_record_text(Game.stage_id, Game.difficulty_id)]
	var reward_parts: Array = []
	if not Game.last_rewards.is_empty():
		reward_parts.append("◈ +%d" % int(Game.last_rewards.get("shards", 0)))
		for item in Game.last_rewards.get("items", []):
			if item is Dictionary:
				reward_parts.append(EquipmentData.item_name(item))
		end_reward.text = "이번 밤 보상  " + " · ".join(reward_parts)
	else:
		end_reward.text = ""
	end_reward.visible = not end_reward.text.is_empty()
	_end_key_hint.text = ("ENTER 다음 전선   ·   ESC 전선 선택" if _end_has_next else "ENTER 다시 도전   ·   ESC 전선 선택")
	end_root.modulate.a = 0.0
	end_root.scale = Vector2(0.96, 0.96)
	end_root.pivot_offset = Vector2(640, 360)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_parallel(true)
	tw.tween_property(end_root, "modulate:a", 1.0, 0.35)
	tw.tween_property(end_root, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _input(event: InputEvent) -> void:
	if _settings_panel != null and _settings_panel.visible:
		return
	if _relic_visible and event is InputEventKey and event.pressed and not event.echo:
		var ridx := -1
		match event.keycode:
			KEY_1, KEY_KP_1:
				ridx = 0
			KEY_2, KEY_KP_2:
				ridx = 1
			KEY_3, KEY_KP_3:
				ridx = 2
		if ridx >= 0:
			_choose_relic(ridx)
			get_viewport().set_input_as_handled()
		return
	if _levelup_visible and event is InputEventKey and event.pressed and not event.echo:
		var idx := -1
		match event.keycode:
			KEY_1, KEY_KP_1:
				idx = 0
			KEY_2, KEY_KP_2:
				idx = 1
			KEY_3, KEY_KP_3:
				idx = 2
		if _banish_mode:
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_B:
				_set_banish_mode(false)
				get_viewport().set_input_as_handled()
			elif idx >= 0:
				_banish(idx)
				get_viewport().set_input_as_handled()
			return
		if idx >= 0:
			_choose(idx)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R:
			_reroll()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_B:
			_toggle_banish()
			get_viewport().set_input_as_handled()
	elif _pause_visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_resume()
		get_viewport().set_input_as_handled()
	elif _end_visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if _end_has_next:
				_next_stage()
			else:
				_restart()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			_go_stage_select()
			get_viewport().set_input_as_handled()
