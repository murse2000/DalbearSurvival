extends Control

## Campaign hub: choose one of three fronts and a difficulty.

var _cards := {}
var _diff_chips := {}
var _diff_desc: Label
var _stage_hint: Label
var _shards_label: Label
var _character_btn: Button
var _selected_stage := "forest"
var _selected_diff := "normal"
var _args: PackedStringArray
var _starting := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.running = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_selected_stage = Game.selected_stage if GameData.STAGES.has(Game.selected_stage) else "forest"
	_selected_diff = Game.selected_difficulty if GameData.DIFFICULTIES.has(Game.selected_difficulty) else "normal"
	Game.select_stage(_selected_stage, _selected_diff)
	_build()
	UIFit.wrap_menu(self)
	if "--capture-select" in _args:
		_capture()
	if "--smoke-start" in _args:
		_start.call_deferred()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/ui/title_bg.png")
	bg.position = Vector2(-26, -14)
	bg.size = Vector2(1332, 748)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.04, 0.68)
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var over := UIKit.label("CAMPAIGN MAP  ·  DALBEAR.COM", 13, UIKit.MINT)
	over.position = Vector2(56, 30)
	add_child(over)
	var title := UIKit.label("전선 선택", 52, UIKit.GOLD, 7)
	title.position = Vector2(52, 48)
	add_child(title)
	var sub := UIKit.label("세 개의 전선, 네 개의 난이도 · 모든 전선이 개방되어 있습니다.", 18, UIKit.CREAM)
	sub.position = Vector2(56, 112)
	add_child(sub)
	var back_top := UIKit.button("← 타이틀", Vector2(140, 42))
	back_top.position = Vector2(1084, 34)
	back_top.add_theme_font_size_override("font_size", 18)
	back_top.pressed.connect(_go_title)
	add_child(back_top)

	_shards_label = UIKit.label("", 15, UIKit.GOLD)
	_shards_label.position = Vector2(820, 40)
	_shards_label.size = Vector2(248, 26)
	_shards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_shards_label)

	_character_btn = UIKit.button("", Vector2(144, 36))
	_character_btn.position = Vector2(666, 34)
	_character_btn.add_theme_font_size_override("font_size", 13)
	_character_btn.pressed.connect(_open_characters)
	add_child(_character_btn)

	for i in GameData.STAGE_ORDER.size():
		var id: String = GameData.STAGE_ORDER[i]
		var card := _make_stage_card(id, i)
		add_child(card["root"])
		_cards[id] = card

	# difficulty chips
	for i in GameData.DIFFICULTY_ORDER.size():
		var id: String = GameData.DIFFICULTY_ORDER[i]
		var chip := _make_diff_chip(id, i)
		add_child(chip["root"])
		_diff_chips[id] = chip

	_diff_desc = UIKit.label("", 15, UIKit.MUTED)
	_diff_desc.position = Vector2(0, 601)
	_diff_desc.size = Vector2(1280, 24)
	_diff_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_diff_desc)

	var start := UIKit.button("출격", Vector2(220, 58))
	start.position = Vector2(500, 636)
	start.add_theme_font_size_override("font_size", 26)
	start.pressed.connect(_start)
	add_child(start)
	var equipment := UIKit.button("장비", Vector2(160, 58))
	equipment.add_theme_font_size_override("font_size", 22)
	equipment.position = Vector2(738, 636)
	equipment.pressed.connect(_open_equipment)
	add_child(equipment)
	var back := UIKit.button("타이틀", Vector2(150, 58))
	back.position = Vector2(916, 636)
	back.pressed.connect(_go_title)
	add_child(back)

	_stage_hint = UIKit.label("", 13, UIKit.MUTED)
	_stage_hint.visible = false
	_stage_hint.position = Vector2(0, 704)
	_stage_hint.size = Vector2(1280, 20)
	_stage_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_stage_hint)

	var domain := UIKit.label("dalbear.com", 13, UIKit.GOLD)
	domain.position = Vector2(56, 690)
	add_child(domain)
	var ver := UIKit.label("ENTER 출격  ·  I 장비  ·  C 친구  ·  ESC 타이틀  ·  1/2/3 전선", 10, UIKit.MUTED)
	ver.position = Vector2(600, 698)
	ver.size = Vector2(624, 18)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(ver)

	_refresh()


func _make_stage_card(id: String, index: int) -> Dictionary:
	var info: Dictionary = GameData.STAGES[id]
	var accent: Color = info["accent"]
	var root := UIKit.panel(Color(0.045, 0.07, 0.105, 0.94), UIKit.BORDER, 2)
	UIKit.place(root, 52 + index * 404, 158, 372, 366)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.clip_contents = true

	var stripe := ColorRect.new()
	stripe.color = accent
	stripe.position = Vector2(2, 2)
	stripe.size = Vector2(368, 4)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stripe)

	var img := TextureRect.new()
	img.texture = load(String(info["thumb"]))
	# expand_mode must be set before size, otherwise the texture's minimum
	# size (480x270) clamps the rect and spills out of the card.
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.custom_minimum_size = Vector2.ZERO
	img.position = Vector2(16, 16)
	img.size = Vector2(340, 175)
	img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(img)

	var num := UIKit.label("%02d" % int(info["num"]), 12, UIKit.INK)
	num.position = Vector2(0, 1)
	num.size = Vector2(44, 22)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var num_bg := UIKit.panel(accent, accent, 1)
	UIKit.place(num_bg, 24, 24, 44, 24)
	num_bg.add_child(num)
	root.add_child(num_bg)

	var name_label := UIKit.label("%s · %s" % [String(info["name"]), String(info["short"])], 22, UIKit.CREAM, 3)
	name_label.position = Vector2(16, 199)
	name_label.size = Vector2(340, 30)
	root.add_child(name_label)

	var desc := UIKit.label(String(info["desc"]), 14, Color(0.78, 0.82, 0.86))
	desc.position = Vector2(16, 228)
	desc.size = Vector2(340, 24)
	desc.autowrap_mode = TextServer.AUTOWRAP_OFF
	root.add_child(desc)

	var icon_label := UIKit.label("출현", 12, UIKit.MUTED)
	icon_label.position = Vector2(16, 275)
	root.add_child(icon_label)
	for i in 3:
		var enemy_id: String = info["enemy_icons"][i]
		var enemy_info: Dictionary = GameData.ENEMIES[enemy_id]
		var icon := UIKit.icon(String(enemy_info["texture"]), 30)
		icon.position = Vector2(58 + i * 38, 267)
		root.add_child(icon)

	var boss := UIKit.label("%s · BOSS  %s" % [GameData.format_time(float(info["duration"])), String(GameData.ENEMIES[info["boss"]]["name"])], 13, accent)
	boss.position = Vector2(16, 306)
	boss.size = Vector2(340, 20)
	root.add_child(boss)

	var rec := UIKit.label("", 13, UIKit.MINT)
	rec.position = Vector2(16, 332)
	rec.size = Vector2(340, 18)
	root.add_child(rec)

	root.gui_input.connect(_on_stage_input.bind(id))
	root.mouse_entered.connect(_on_stage_hover.bind(root, accent, true))
	root.mouse_exited.connect(_on_stage_hover.bind(root, accent, false))
	return {"root": root, "stripe": stripe, "record": rec, "accent": accent}


func _make_diff_chip(id: String, index: int) -> Dictionary:
	var info: Dictionary = GameData.DIFFICULTIES[id]
	var root := UIKit.panel(Color(0.06, 0.09, 0.13, 0.95), UIKit.BORDER, 2)
	UIKit.place(root, 86 + index * 282, 534, 266, 52)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var name_label := UIKit.label(String(info["name"]), 19, UIKit.CREAM, 2)
	name_label.position = Vector2(14, 7)
	root.add_child(name_label)
	var tag := UIKit.label(String(info["tag"]), 11, info["color"])
	tag.position = Vector2(150, 13)
	tag.size = Vector2(100, 18)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(tag)
	var mod := UIKit.label(_diff_mods(id), 11, UIKit.MUTED)
	mod.position = Vector2(14, 30)
	root.add_child(mod)
	root.gui_input.connect(_on_diff_input.bind(id))
	root.mouse_entered.connect(func():
		if _selected_diff != id:
			root.add_theme_stylebox_override("panel", UIKit.style(Color(0.09, 0.13, 0.18, 0.98), info["color"].darkened(0.35), 2, 0))
	)
	root.mouse_exited.connect(func():
		if _selected_diff != id:
			root.add_theme_stylebox_override("panel", UIKit.style(Color(0.06, 0.09, 0.13, 0.95), UIKit.BORDER, 2, 0))
	)
	return {"root": root, "accent": info["color"]}


func _diff_mods(id: String) -> String:
	var d := GameData.difficulty(id)
	return "적 HP ×%.2f · 피해 ×%.2f · 출현 ×%.2f" % [float(d["hp"]), float(d["damage"]), float(d["spawn"])]


func _on_stage_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_stage(id)


func _on_stage_hover(card: Panel, accent: Color, hovered: bool) -> void:
	if not is_instance_valid(card):
		return
	var is_selected := false
	for k in _cards:
		if _cards[k]["root"] == card and k == _selected_stage:
			is_selected = true
	var border := accent if (hovered or is_selected) else UIKit.BORDER
	var bg := Color(0.075, 0.11, 0.155, 0.97) if (hovered or is_selected) else Color(0.045, 0.07, 0.105, 0.94)
	card.add_theme_stylebox_override("panel", UIKit.style(bg, border, 2 + (1 if is_selected else 0), 0))


func _on_diff_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_diff(id)


func _select_stage(id: String) -> void:
	_selected_stage = id
	Game.select_stage(_selected_stage, _selected_diff)
	_refresh()
	Audio.play_click()


func _select_diff(id: String) -> void:
	_selected_diff = id
	Game.select_stage(_selected_stage, _selected_diff)
	_refresh()
	Audio.play_click()


func _refresh() -> void:
	for id in _cards:
		var card: Dictionary = _cards[id]
		var accent: Color = card["accent"]
		var selected: bool = id == _selected_stage
		card["root"].add_theme_stylebox_override("panel", UIKit.style(
			Color(0.075, 0.11, 0.155, 0.98) if selected else Color(0.045, 0.07, 0.105, 0.94),
			accent if selected else UIKit.BORDER,
			3 if selected else 2, 0))
		card["record"].text = "기록  " + Game.stage_record_text(id, _selected_diff)
		card["record"].add_theme_color_override("font_color", accent if selected else UIKit.MINT)
	for id in _diff_chips:
		var chip: Dictionary = _diff_chips[id]
		var accent: Color = chip["accent"]
		var selected: bool = id == _selected_diff
		chip["root"].add_theme_stylebox_override("panel", UIKit.style(
			Color(0.10, 0.15, 0.20, 0.98) if selected else Color(0.06, 0.09, 0.13, 0.95),
			accent if selected else UIKit.BORDER, 3 if selected else 2, 0))
	var diff := GameData.difficulty(_selected_diff)
	_diff_desc.text = "%s — %s" % [String(diff["name"]), String(diff["desc"])]
	_diff_desc.add_theme_color_override("font_color", diff["color"])
	if _shards_label != null:
		_shards_label.text = "◈ 달빛 조각  %d" % Game.shards
	if _character_btn != null:
		_character_btn.text = "친구 · %s" % CharacterData.display_name(Game.selected_character)


func _start() -> void:
	if _starting:
		return
	_starting = true
	Audio.play_click()
	Game.new_run(_selected_stage, _selected_diff)


func _open_equipment() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_equipment("stage_select")


func _open_characters() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_characters("stage_select")


func _go_title() -> void:
	Audio.play_click()
	Game.go_title()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_start()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			_go_title()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_I:
			_open_equipment()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_open_characters()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_1:
			_select_stage("forest")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2:
			_select_stage("hive")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_3:
			_select_stage("ship")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT or event.keycode == KEY_A:
			var idx := maxi(0, GameData.DIFFICULTY_ORDER.find(_selected_diff) - 1)
			_select_diff(GameData.DIFFICULTY_ORDER[idx])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			var idx := mini(GameData.DIFFICULTY_ORDER.size() - 1, GameData.DIFFICULTY_ORDER.find(_selected_diff) + 1)
			_select_diff(GameData.DIFFICULTY_ORDER[idx])
			get_viewport().set_input_as_handled()


func _capture() -> void:
	await get_tree().create_timer(1.2, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/stage_select.png")
	print("CAPTURED: ", dir + "/stage_select.png")
	get_tree().quit()
