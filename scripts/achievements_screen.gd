extends Control

## Local achievement board. Progress comes from Game.stats and stage records.

var _args: PackedStringArray
var _portrait := false
var _reloading := false
var _page := 0
var _per_page := 8
var _page_label: Label
var _prev_btn: Button
var _next_btn: Button
var _card_nodes: Array[Node] = []
var _card_parent: Node


func _is_portrait() -> bool:
	var size := get_viewport_rect().size
	return size.y > size.x


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	Engine.time_scale = 1.0
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_portrait = _is_portrait()
	_build()
	UIFit.wrap_menu(self, "res://assets/art/ui/menu_backdrop.png",
		UIFit.PORTRAIT if _portrait else UIFit.DESIGN)
	get_viewport().size_changed.connect(_on_viewport_resized)
	if "--capture-achievements" in _args:
		_capture()
	if "--test-achievements" in _args:
		_test_achievements.call_deferred()


func _on_viewport_resized() -> void:
	if _reloading:
		return
	if _is_portrait() == _portrait:
		return
	_reloading = true
	get_tree().reload_current_scene.call_deferred()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/ui/title_bg.png")
	if _portrait:
		bg.position = Vector2(-180, -14)
		bg.size = Vector2(1080, 1308)
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	else:
		bg.position = Vector2(-26, -14)
		bg.size = Vector2(1332, 748)
		bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.04, 0.8)
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var over := UIKit.label("DALBEAR RECORDS  ·  ACHIEVEMENTS", 13, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("업적", 40 if _portrait else 44, UIKit.GOLD, 7)
	title.position = Vector2(24, 38) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("전선에서 쌓은 기록. 달성한 업적은 자동으로 저장됩니다.", 14 if _portrait else 15, UIKit.CREAM)
	sub.position = Vector2(26, 94) if _portrait else Vector2(56, 96)
	add_child(sub)

	var done := 0
	for a in AchievementData.all():
		if AchievementData.is_complete(a):
			done += 1
	var summary := UIKit.label("달성  %d / %d" % [done, AchievementData.all().size()], 14, UIKit.GOLD)
	summary.position = Vector2(26, 120) if _portrait else Vector2(56, 120)
	add_child(summary)

	var back := UIKit.button("← 돌아가기", Vector2(164, 42))
	back.position = Vector2(540, 22) if _portrait else Vector2(1074, 30)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_go_back)
	add_child(back)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.28)
	line.position = Vector2(26, 148) if _portrait else Vector2(36, 146)
	line.size = Vector2(668, 1) if _portrait else Vector2(1208, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

	_page_label = UIKit.label("", 14, UIKit.GOLD)
	_page_label.position = Vector2(280, 870) if _portrait else Vector2(540, 558)
	_page_label.size = Vector2(160, 28) if _portrait else Vector2(200, 28)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_page_label)
	_prev_btn = UIKit.button("←", Vector2(72, 40))
	_prev_btn.position = Vector2(200, 862) if _portrait else Vector2(452, 550)
	_prev_btn.add_theme_font_size_override("font_size", 20)
	_prev_btn.pressed.connect(func() -> void: _go_page(-1))
	add_child(_prev_btn)
	_next_btn = UIKit.button("→", Vector2(72, 40))
	_next_btn.position = Vector2(448, 862) if _portrait else Vector2(756, 550)
	_next_btn.add_theme_font_size_override("font_size", 20)
	_next_btn.pressed.connect(func() -> void: _go_page(1))
	add_child(_next_btn)
	_build_page()

	var hint := UIKit.label("달성한 업적은 자동으로 저장됩니다 · 새 업적은 전선에서 갱신됩니다", 11, UIKit.MUTED)
	hint.position = Vector2(0, 1190) if _portrait else Vector2(0, 698)
	hint.size = Vector2(720, 18) if _portrait else Vector2(1280, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)


func _build_page() -> void:
	for node in _card_nodes:
		node.queue_free()
	_card_nodes.clear()
	# UIFit moves the initial UI into ResponsiveContent. Cards created after a
	# page change must join that same container or they render outside the
	# scaled menu area.
	_card_parent = get_node_or_null("ResponsiveContent")
	if _card_parent == null:
		_card_parent = self
	var list := AchievementData.all()
	var start := _page * _per_page
	var stop := mini(list.size(), start + _per_page)
	for local_i in range(start, stop):
		var column := 0 if _portrait else (local_i - start) % 2
		var row := (local_i - start) if _portrait else (local_i - start) / 2
		var x := 24.0 if _portrait else 56.0 + float(column) * 584.0
		var y := 166.0 + float(row) * 82.0 if _portrait else 158.0 + float(row) * 88.0
		var card := _make_card(list[local_i], Vector2(x, y),
			672.0 if _portrait else 580.0, 78.0 if _portrait else 82.0)
		_card_nodes.append(card)
	var pages := maxi(1, int(ceil(float(list.size()) / float(_per_page))))
	_page_label.text = "페이지  %d / %d" % [_page + 1, pages]
	_prev_btn.disabled = _page <= 0
	_next_btn.disabled = _page >= pages - 1


func _go_page(delta: int) -> void:
	var pages := maxi(1, int(ceil(float(AchievementData.all().size()) / float(_per_page))))
	var next := clampi(_page + delta, 0, pages - 1)
	if next == _page:
		return
	_page = next
	Audio.play_click()
	_build_page()


func _make_card(a: Dictionary, pos: Vector2, w: float, h: float) -> Panel:
	var done := AchievementData.is_complete(a)
	var accent := UIKit.GOLD if done else UIKit.BORDER
	var card := Panel.new()
	card.position = pos
	card.size = Vector2(w, h)
	card.add_theme_stylebox_override("panel", UIKit.style(
		Color(0.075, 0.11, 0.155, 0.96) if done else Color(0.045, 0.07, 0.105, 0.94),
		accent, 2 if done else 1, 10))
	_card_parent.add_child(card)
	UIKit.add_panel_ornament(card,
		Color(1.0, 0.88, 0.55, 0.72) if done else Color(1.0, 0.82, 0.44, 0.34))

	var icon := TextureRect.new()
	icon.texture = load(String(a["icon"]))
	icon.position = Vector2(14, (h - 44.0) * 0.5)
	icon.size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.modulate = Color(1, 1, 1, 1) if done else Color(0.55, 0.55, 0.62, 0.9)
	card.add_child(icon)

	var name_label := UIKit.label(String(a["name"]), 18, UIKit.GOLD if done else UIKit.CREAM)
	name_label.position = Vector2(70, 9)
	card.add_child(name_label)
	var desc := UIKit.label(String(a["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(70, 34)
	desc.size = Vector2(w - 220.0, 18)
	desc.clip_text = true
	card.add_child(desc)

	var prog := UIKit.label(AchievementData.progress_text(a), 13, UIKit.GOLD if done else UIKit.MUTED)
	prog.position = Vector2(w - 178.0, 28)
	prog.size = Vector2(158, 20)
	prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	card.add_child(prog)

	if done:
		var check := UIKit.label("✓", 18, UIKit.MINT)
		check.position = Vector2(w - 32.0, 7)
		card.add_child(check)
	return card


func _go_back() -> void:
	Audio.play_click()
	Game.close_achievements()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT or event.keycode == KEY_PAGEUP or event.keycode == KEY_Q:
			_go_page(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_PAGEDOWN or event.keycode == KEY_E:
			_go_page(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_go_back()
			get_viewport().set_input_as_handled()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "achievements" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _test_achievements() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	var errors: Array = []
	var old_stats: Dictionary = Game.stats.duplicate(true)
	var old_ach: Dictionary = Game.achievements.duplicate(true)
	var old_stages: Dictionary = Game.stage_records.duplicate(true)
	Game.stats["total_kills"] = 100000
	Game.stats["boss_kills"] = 500
	Game.stats["max_level"] = 80
	Game.stats["max_evolutions"] = 8
	Game.stats["max_relics"] = 10
	Game.stats["max_enhance"] = 15
	Game.stats["legendary_equipped"] = true
	Game.stats["endless_best"] = 3600.0
	Game.stats["daily_clears"] = 30
	Game.stats["runs"] = 200
	Game.stats["wins"] = 100
	Game.stats["hard_wins"] = 50
	Game.stats["nightmare_wins"] = 10
	Game.stats["flawless_wins"] = 10
	Game.stage_records["forest:normal"] = {"clears": 1}
	Game.stage_records["genesis:normal"] = {"clears": 1}
	Game.achievements.clear()
	Game._check_achievements(false)
	for a in AchievementData.all():
		if not AchievementData.is_complete(a):
			errors.append("not complete: %s (%s)" % [a["id"], AchievementData.progress_text(a)])
		if not Game.achievements.has(String(a["id"])):
			errors.append("not unlocked: %s" % a["id"])
	if AchievementData.progress_text(AchievementData.get_achievement("kills_1000")) != "달성":
		errors.append("progress text wrong")
	_go_page(1)
	await get_tree().process_frame
	var content := get_node_or_null("ResponsiveContent")
	if content == null:
		errors.append("responsive content missing")
	else:
		for node in _card_nodes:
			if node.get_parent() != content:
				errors.append("page card escaped responsive content")
				break
	Game.stats = old_stats
	Game.achievements = old_ach
	Game.stage_records = old_stages
	Game.save_settings()
	if errors.is_empty():
		print("ACHIEVEMENTS TEST PASS: %d/%d" % [AchievementData.all().size(), AchievementData.all().size()])
		print("TEST PASS")
	else:
		print("ACHIEVEMENTS TEST FAIL")
		for e in errors:
			print("  ", e)
		print("TEST FAIL")
	get_tree().quit()
