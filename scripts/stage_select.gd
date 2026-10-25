extends Control

## Campaign hub: choose one of fifteen fronts and a difficulty.
## Landscape: 5 cards per page. Portrait: one large card per page.
## Swipe / drag left-right, mouse wheel, Q/E, edge arrows or the 1-0 keys.

const CARD_W := 230.0
const CARD_H := 366.0
const CARD_GAP := 10.0
const PAGE_W := 1228.0
const PAGE_W_PORTRAIT := 680.0
const PAGE_SIZE := 5
const SWIPE_DIST := 64.0
const SWIPE_SPEED := 520.0
const PORTRAIT_SCALE := 1.55

var _cards := {}
var _diff_chips := {}
var _carousel: Control
var _strip: Control
var _prev_btn: Button
var _next_btn: Button
var _endless_btn: Button
var _daily_btn: Button
var _start_btn: Button
var _input_hint: Label
var _daily_modal: Control
var _daily_modal_desc: Label
var _daily_modal_best: Label
var _weekly_modal: Control
var _weekly_desc: Label
var _page_label: Label
var _page := 0
var _page_count := 1
var _page_tween: Tween
var _hover_stage := ""
var _dragging := false
var _drag_start := Vector2.ZERO
var _drag_last := Vector2.ZERO
var _drag_start_ms := 0
var _drag_moved := 0.0
var _diff_desc: Label
var _stage_hint: Label
var _stage_modal: Control
var _stage_modal_chapter := ""
var _stage_modal_title: Label
var _stage_modal_info: Label
var _stage_modal_buttons: Array[Button] = []
var _shards_label: Label
var _character_btn: Button
var _selected_stage := "forest"
var _selected_diff := "normal"
var _args: PackedStringArray
var _starting := false
var _portrait := false
var _stride := PAGE_W
var _carousel_h := 370.0
var _card_scale := 1.0
var _card_left := 19.0
var _card_top := 0.0
var _reloading := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.running = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_portrait = _is_portrait()
	_apply_layout_metrics()
	_selected_stage = Game.selected_stage if GameData.is_valid_stage(Game.selected_stage) else GameData.campaign_stage_id("forest", 1)
	var marketing := "--capture-select" in _args or "--capture-select-late" in _args
	if marketing:
		# Marketing captures show the map unlocked without touching the save.
		for id in GameData.campaign_order():
			for diff in GameData.DIFFICULTY_ORDER:
				Game.stage_records["%s:%s" % [id, diff]] = {
					"clears": 1, "boss": true, "best_kills": 180, "best_level": 18,
					"best_time": 210.0,
				}
	if "--capture-select-late" in _args:
		_selected_stage = "genesis_10"
	elif "--capture-select" in _args:
		_selected_stage = "dunes_01"
	elif "--test-swipe" in _args:
		_selected_stage = "forest_01"
	elif not Game.is_stage_unlocked(_selected_stage):
		_selected_stage = Game.first_unlocked_stage()
	_selected_diff = Game.selected_difficulty if GameData.DIFFICULTIES.has(Game.selected_difficulty) else "normal"
	Game.select_stage(_selected_stage, _selected_diff)
	_page_count = maxi(1, int(ceil(float(GameData.STAGE_ORDER.size()) / float(PAGE_SIZE)))) if not _portrait \
		else GameData.STAGE_ORDER.size()
	_build()
	_ensure_page(_selected_stage, false)
	UIFit.wrap_menu(self, "res://assets/art/ui/menu_backdrop.png",
		UIFit.PORTRAIT if _portrait else UIFit.DESIGN)
	get_viewport().size_changed.connect(_on_viewport_resized)
	if "--capture-select-late" in _args:
		_capture("stage_select_late")
	elif "--capture-select" in _args:
		_capture()
	elif "--capture-chapters" in _args:
		_capture_chapters.call_deferred()
	elif "--test-chapters" in _args:
		_test_chapters.call_deferred()
	elif "--test-swipe" in _args:
		_test_swipe.call_deferred()
	elif "--test-platform-input" in _args:
		_test_platform_input.call_deferred()
	elif "--capture-daily-modal" in _args:
		_capture_daily_modal.call_deferred()
	elif "--capture-weekly" in _args:
		_capture_weekly.call_deferred()
	if "--smoke-start" in _args:
		_start.call_deferred()


func _is_portrait() -> bool:
	var size := get_viewport_rect().size
	return size.y > size.x


func _apply_layout_metrics() -> void:
	if _portrait:
		_stride = PAGE_W_PORTRAIT
		_carousel_h = 620.0
		_card_scale = PORTRAIT_SCALE
		_card_left = (PAGE_W_PORTRAIT - CARD_W * _card_scale) * 0.5
		_card_top = 20.0
	else:
		_stride = PAGE_W
		_carousel_h = 370.0
		_card_scale = 1.0
		_card_left = 19.0
		_card_top = 0.0


func _on_viewport_resized() -> void:
	if _reloading or _starting:
		return
	var portrait := _is_portrait()
	if portrait == _portrait:
		return
	_reloading = true
	Game.select_stage(_selected_stage, _selected_diff)
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
	shade.color = Color(0.01, 0.02, 0.04, 0.68)
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	if _portrait:
		_build_header_portrait()
		_build_carousel()
		_build_chips_portrait()
		_build_footer_portrait()
	else:
		_build_header_landscape()
		_build_carousel()
		_build_chips_landscape()
		_build_footer_landscape()

	_build_daily_modal()
	_build_weekly_modal()
	_build_stage_modal()
	_refresh()
	_refresh_input_hint()


func _build_header_landscape() -> void:
	var over := UIKit.label("CAMPAIGN & ENDLESS  ·  DALBEAR.COM", 13, UIKit.MINT)
	over.position = Vector2(56, 30)
	add_child(over)
	var title := UIKit.label("전선 선택", 52, UIKit.GOLD, 7)
	title.position = Vector2(52, 48)
	add_child(title)
	var sub := UIKit.label("스무 개의 챕터, 챕터당 열 개의 전장 · 마지막 전장은 각성 챕터 보스입니다.", 18, UIKit.CREAM)
	sub.position = Vector2(56, 112)
	add_child(sub)
	_page_label = UIKit.label("", 13, UIKit.MUTED)
	_page_label.position = Vector2(966, 116)
	_page_label.size = Vector2(288, 20)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_page_label)
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
	# One aligned action row: character, achievements, altar and weekly.
	_character_btn = UIKit.button("", Vector2(200, 34))
	_character_btn.position = Vector2(666, 76)
	_character_btn.add_theme_font_size_override("font_size", 13)
	_character_btn.pressed.connect(_open_characters)
	add_child(_character_btn)
	var ach_btn := UIKit.button("업적", Vector2(120, 34))
	ach_btn.position = Vector2(876, 76)
	ach_btn.add_theme_font_size_override("font_size", 13)
	ach_btn.pressed.connect(_open_achievements)
	add_child(ach_btn)
	var altar_btn := UIKit.button("달빛 제단", Vector2(126, 34))
	altar_btn.position = Vector2(1006, 76)
	altar_btn.add_theme_font_size_override("font_size", 13)
	altar_btn.pressed.connect(_open_altar)
	add_child(altar_btn)
	var weekly_btn := UIKit.button("주간 기록", Vector2(120, 34))
	weekly_btn.position = Vector2(1142, 76)
	weekly_btn.add_theme_font_size_override("font_size", 13)
	weekly_btn.pressed.connect(_open_weekly)
	add_child(weekly_btn)


func _build_header_portrait() -> void:
	var over := UIKit.label("CAMPAIGN & ENDLESS  ·  DALBEAR.COM", 11, UIKit.MINT)
	over.position = Vector2(24, 20)
	add_child(over)
	var title := UIKit.label("전선 선택", 42, UIKit.GOLD, 6)
	title.position = Vector2(22, 38)
	add_child(title)
	var sub := UIKit.label("스무 개의 챕터 · 챕터당 열 개의 전장 · 마지막은 챕터 보스.", 12, UIKit.CREAM)
	sub.position = Vector2(24, 98)
	sub.size = Vector2(530, 20)
	add_child(sub)
	_page_label = UIKit.label("", 12, UIKit.MUTED)
	_page_label.position = Vector2(24, 130)
	_page_label.size = Vector2(420, 18)
	add_child(_page_label)
	_shards_label = UIKit.label("", 12, UIKit.GOLD)
	_shards_label.position = Vector2(470, 22)
	_shards_label.size = Vector2(226, 20)
	_shards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_shards_label)
	# Portrait keeps one aligned action row below the page label.
	_character_btn = UIKit.button("", Vector2(160, 34))
	_character_btn.position = Vector2(24, 154)
	_character_btn.add_theme_font_size_override("font_size", 14)
	_character_btn.pressed.connect(_open_characters)
	add_child(_character_btn)
	var ach_btn := UIKit.button("업적", Vector2(110, 34))
	ach_btn.position = Vector2(194, 154)
	ach_btn.add_theme_font_size_override("font_size", 14)
	ach_btn.pressed.connect(_open_achievements)
	add_child(ach_btn)
	var altar_btn := UIKit.button("달빛 제단", Vector2(120, 34))
	altar_btn.position = Vector2(314, 154)
	altar_btn.add_theme_font_size_override("font_size", 14)
	altar_btn.pressed.connect(_open_altar)
	add_child(altar_btn)
	var weekly_btn := UIKit.button("주간 기록", Vector2(110, 34))
	weekly_btn.position = Vector2(444, 154)
	weekly_btn.add_theme_font_size_override("font_size", 14)
	weekly_btn.pressed.connect(_open_weekly)
	add_child(weekly_btn)
	var back_top := UIKit.button("← 타이틀", Vector2(130, 34))
	back_top.position = Vector2(564, 154)
	back_top.add_theme_font_size_override("font_size", 14)
	back_top.pressed.connect(_go_title)
	add_child(back_top)


func _build_chips_landscape() -> void:
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


func _build_chips_portrait() -> void:
	for i in GameData.DIFFICULTY_ORDER.size():
		var id: String = GameData.DIFFICULTY_ORDER[i]
		var chip := _make_diff_chip(id, i)
		add_child(chip["root"])
		_diff_chips[id] = chip
	_diff_desc = UIKit.label("", 12, UIKit.MUTED)
	_diff_desc.position = Vector2(0, 1030)
	_diff_desc.size = Vector2(720, 20)
	_diff_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_diff_desc)


func _build_footer_landscape() -> void:
	var start := UIKit.button("출격", Vector2(170, 58))
	_start_btn = start
	start.position = Vector2(430, 636)
	start.add_theme_font_size_override("font_size", 24)
	start.pressed.connect(_start)
	add_child(start)
	var equipment := UIKit.button("장비", Vector2(130, 58))
	equipment.add_theme_font_size_override("font_size", 18)
	equipment.position = Vector2(615, 636)
	equipment.pressed.connect(_open_equipment)
	add_child(equipment)
	_endless_btn = UIKit.button("무한 모드", Vector2(170, 58))
	_endless_btn.position = Vector2(760, 636)
	_endless_btn.add_theme_font_size_override("font_size", 18)
	_endless_btn.pressed.connect(_start_endless)
	add_child(_endless_btn)
	_daily_btn = UIKit.button("오늘의 도전", Vector2(170, 58))
	_daily_btn.position = Vector2(945, 636)
	_daily_btn.add_theme_font_size_override("font_size", 16)
	_daily_btn.pressed.connect(_start_daily)
	add_child(_daily_btn)
	var back := UIKit.button("타이틀", Vector2(130, 58))
	back.position = Vector2(1130, 636)
	back.add_theme_font_size_override("font_size", 16)
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
	var ver := UIKit.label("ENTER 출격  ·  I 장비  ·  C 친구  ·  Q/E 전선  ·  스와이프", 10, UIKit.MUTED)
	_input_hint = ver
	ver.position = Vector2(600, 698)
	ver.size = Vector2(624, 18)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(ver)


func _build_footer_portrait() -> void:
	var start := UIKit.button("출격", Vector2(130, 62))
	_start_btn = start
	start.position = Vector2(15, 1060)
	start.add_theme_font_size_override("font_size", 20)
	start.pressed.connect(_start)
	add_child(start)
	var equipment := UIKit.button("장비", Vector2(130, 62))
	equipment.position = Vector2(155, 1060)
	equipment.add_theme_font_size_override("font_size", 16)
	equipment.pressed.connect(_open_equipment)
	add_child(equipment)
	_endless_btn = UIKit.button("무한", Vector2(130, 62))
	_endless_btn.position = Vector2(295, 1060)
	_endless_btn.add_theme_font_size_override("font_size", 16)
	_endless_btn.pressed.connect(_start_endless)
	add_child(_endless_btn)
	_daily_btn = UIKit.button("일일", Vector2(130, 62))
	_daily_btn.position = Vector2(435, 1060)
	_daily_btn.add_theme_font_size_override("font_size", 16)
	_daily_btn.pressed.connect(_start_daily)
	add_child(_daily_btn)
	var back := UIKit.button("타이틀", Vector2(130, 62))
	back.position = Vector2(575, 1060)
	back.add_theme_font_size_override("font_size", 16)
	back.pressed.connect(_go_title)
	add_child(back)
	_stage_hint = UIKit.label("", 12, UIKit.MUTED)
	_stage_hint.visible = false
	_stage_hint.position = Vector2(0, 1144)
	_stage_hint.size = Vector2(720, 20)
	_stage_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_stage_hint)
	var domain := UIKit.label("dalbear.com", 11, UIKit.GOLD)
	domain.position = Vector2(24, 1236)
	add_child(domain)
	var ver := UIKit.label("ENTER 출격  ·  I 장비  ·  Q/E 전선  ·  스와이프", 9, UIKit.MUTED)
	_input_hint = ver
	ver.position = Vector2(180, 1238)
	ver.size = Vector2(516, 16)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(ver)


func _build_daily_modal() -> void:
	_daily_modal = Control.new()
	_daily_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_daily_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_daily_modal.visible = false
	add_child(_daily_modal)
	var dim := UIKit.dimmer(0.72)
	_daily_modal.add_child(dim)

	var pw := 648.0 if _portrait else 600.0
	var ph := 420.0 if _portrait else 340.0
	var px := 36.0 if _portrait else 340.0
	var py := 400.0 if _portrait else 180.0
	var panel := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99), UIKit.GOLD, 2)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.position = Vector2(px, py)
	panel.size = Vector2(pw, ph)
	_daily_modal.add_child(panel)

	var over := UIKit.label("DAILY CHALLENGE", 12, UIKit.MINT)
	over.position = Vector2(28, 22)
	panel.add_child(over)
	var title := UIKit.label("오늘의 도전", 30, UIKit.GOLD, 6)
	title.position = Vector2(26, 42)
	panel.add_child(title)
	var date_label := UIKit.label(Game.daily_key(), 13, UIKit.MUTED)
	date_label.position = Vector2(28, 86)
	panel.add_child(date_label)

	_daily_modal_desc = UIKit.label("", 16, UIKit.CREAM)
	_daily_modal_desc.position = Vector2(28, 116)
	_daily_modal_desc.size = Vector2(pw - 56.0, 110)
	_daily_modal_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_daily_modal_desc)

	_daily_modal_best = UIKit.label("", 13, UIKit.MINT)
	_daily_modal_best.position = Vector2(28, 236 if _portrait else 182)
	_daily_modal_best.size = Vector2(pw - 56.0, 40)
	panel.add_child(_daily_modal_best)

	var confirm := UIKit.button("도전 시작", Vector2(240 if _portrait else 200, 56))
	confirm.position = Vector2(28, 320 if _portrait else 258)
	confirm.add_theme_font_size_override("font_size", 20)
	confirm.pressed.connect(_confirm_daily)
	panel.add_child(confirm)
	var cancel := UIKit.button("취소", Vector2(160 if _portrait else 140, 56))
	cancel.position = Vector2(290 if _portrait else 250, 320 if _portrait else 258)
	cancel.add_theme_font_size_override("font_size", 18)
	cancel.pressed.connect(_close_daily_modal)
	panel.add_child(cancel)


func _build_weekly_modal() -> void:
	_weekly_modal = Control.new()
	_weekly_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_weekly_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_weekly_modal.visible = false
	add_child(_weekly_modal)
	var dim := UIKit.dimmer(0.72)
	_weekly_modal.add_child(dim)
	var pw := 660.0 if _portrait else 620.0
	var ph := 360.0 if _portrait else 380.0
	var panel := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99), UIKit.GOLD, 2)
	panel.position = Vector2(30, 470) if _portrait else Vector2(330, 170)
	panel.size = Vector2(pw, ph)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_weekly_modal.add_child(panel)
	var over := UIKit.label("WEEKLY RECORDS", 12, UIKit.MINT)
	over.position = Vector2(28, 22)
	panel.add_child(over)
	var title := UIKit.label("이번 주 기록", 30, UIKit.GOLD, 6)
	title.position = Vector2(26, 42)
	panel.add_child(title)
	var sub := UIKit.label("매주 월요일 초기화 · 이번 주", 12, UIKit.MUTED)
	sub.position = Vector2(28, 84)
	panel.add_child(sub)
	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.28)
	line.position = Vector2(28, 108)
	line.size = Vector2(pw - 56, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(line)
	_weekly_desc = UIKit.label("", 16, UIKit.CREAM)
	_weekly_desc.position = Vector2(30, 128)
	_weekly_desc.size = Vector2(pw - 60, 170 if not _portrait else 140)
	_weekly_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_weekly_desc)
	var close := UIKit.button("닫기", Vector2(180, 48))
	close.position = Vector2((pw - 180) * 0.5, ph - 72)
	close.add_theme_font_size_override("font_size", 18)
	close.pressed.connect(func(): _weekly_modal.visible = false)
	panel.add_child(close)


func _open_weekly() -> void:
	Game.ensure_week()
	var lines: Array = Game.weekly_lines()
	var text := "\n".join(lines)
	if int(Game.weekly_records.get("runs", 0)) <= 0:
		text = "아직 이번 주 기록이 없습니다.\n전선·무한·일일 도전을 시작해 보세요."
	_weekly_desc.text = text
	_weekly_modal.visible = true
	Audio.play_click()


func _build_stage_modal() -> void:
	_stage_modal = Control.new()
	_stage_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage_modal.visible = false
	add_child(_stage_modal)
	_stage_modal.add_child(UIKit.dimmer(0.78))
	var pw := 660.0 if _portrait else 760.0
	var ph := 650.0 if _portrait else 470.0
	var panel := UIKit.panel(Color(0.045, 0.072, 0.11, 0.99), UIKit.GOLD, 3)
	panel.position = Vector2(30, 315) if _portrait else Vector2(260, 120)
	panel.size = Vector2(pw, ph)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage_modal.add_child(panel)
	var over := UIKit.label("CHAPTER STAGES", 12, UIKit.MINT)
	over.position = Vector2(28, 18)
	panel.add_child(over)
	_stage_modal_title = UIKit.label("", 28, UIKit.GOLD, 5)
	_stage_modal_title.position = Vector2(26, 38)
	_stage_modal_title.size = Vector2(pw - 52, 40)
	panel.add_child(_stage_modal_title)
	_stage_modal_info = UIKit.label("", 12, UIKit.CREAM)
	_stage_modal_info.position = Vector2(28, 88)
	_stage_modal_info.size = Vector2(pw - 56, 52)
	_stage_modal_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_stage_modal_info)
	for i in range(10):
		var button := UIKit.button("", Vector2(140, 58) if not _portrait else Vector2(296, 58))
		button.add_theme_font_size_override("font_size", 14 if not _portrait else 16)
		button.position = (Vector2(28 + (i % 5) * 148, 160 + floori(float(i) / 5.0) * 70) if not _portrait
			else Vector2(28 + (i % 2) * 306, 160 + floori(float(i) / 2.0) * 70))
		button.pressed.connect(_choose_stage.bind(i + 1))
		panel.add_child(button)
		_stage_modal_buttons.append(button)
	var close := UIKit.button("닫기", Vector2(180, 48))
	close.position = Vector2((pw - 180) * 0.5, ph - 64)
	close.add_theme_font_size_override("font_size", 18)
	close.pressed.connect(func() -> void: _stage_modal.visible = false)
	panel.add_child(close)


func _open_stage_picker(chapter: String) -> void:
	if not Game.is_stage_unlocked(GameData.campaign_stage_id(chapter, 1)):
		if _stage_hint != null:
			_stage_hint.visible = true
			_stage_hint.text = "이전 챕터의 보스를 처치해야 이 챕터가 열립니다."
		return
	_stage_modal_chapter = chapter
	var info: Dictionary = GameData.STAGES[chapter]
	var boss: Dictionary = GameData.chapter_boss_data(chapter)
	var reward_line := GameData.reward_text(boss.get("reward", {}))
	var claimed := " · 획득 완료" if Game.chapter_boss_claimed(chapter) else ""
	_stage_modal_title.text = "제%d장 · %s" % [int(info.get("num", 1)), String(info.get("short", ""))]
	_stage_modal_info.text = "챕터 보스  %s  ·  %s\n첫 격파 보상  %s%s" % [
		String(boss.get("name", "")), String((boss.get("skill", {}) as Dictionary).get("name", "")),
		reward_line, claimed,
	]
	for i in range(10):
		var number := i + 1
		var id := GameData.campaign_stage_id(chapter, number)
		var button: Button = _stage_modal_buttons[i]
		var unlocked := Game.is_stage_unlocked(id)
		var cleared := Game.has_cleared(id)
		button.disabled = not unlocked
		button.text = "%d-%d%s" % [int(info.get("num", 1)), number, "  BOSS" if number == 10 else ("  ✓" if cleared else "")]
		var unique_enemy := GameData.chapter_enemy(id)
		button.tooltip_text = "전장 변이 적 · %s" % String(unique_enemy.get("name", ""))
		button.add_theme_color_override("font_color",
			UIKit.GOLD_L if number == 10 and unlocked else (UIKit.MINT if cleared else UIKit.CREAM))
		button.add_theme_color_override("font_disabled_color", UIKit.MUTED.darkened(0.25))
		if chapter == GameData.chapter_of(_selected_stage) and number == GameData.stage_number(_selected_stage):
			button.add_theme_stylebox_override("normal",
				UIKit.style(Color(0.10, 0.15, 0.21, 0.99), UIKit.GOLD, 2, 0))
		else:
			button.add_theme_stylebox_override("normal",
				UIKit.style(Color(0.055, 0.085, 0.12, 0.98), UIKit.BORDER, 1, 0))
	_stage_modal.visible = true
	Audio.play_click()


func _choose_stage(number: int) -> void:
	if _stage_modal_chapter == "":
		return
	var id := GameData.campaign_stage_id(_stage_modal_chapter, number)
	if not Game.is_stage_unlocked(id):
		return
	_selected_stage = id
	Game.select_stage(id, _selected_diff)
	_stage_modal.visible = false
	_refresh()
	_ensure_page(id)
	Audio.play_click()



func _build_carousel() -> void:
	_carousel = Control.new()
	_carousel.name = "FrontCarousel"
	if _portrait:
		UIKit.place(_carousel, 20, 200, _stride, _carousel_h)
	else:
		UIKit.place(_carousel, 26, 154, _stride, _carousel_h)
	_carousel.clip_contents = true
	_carousel.mouse_filter = Control.MOUSE_FILTER_STOP
	_carousel.mouse_default_cursor_shape = Control.CURSOR_DRAG
	_carousel.gui_input.connect(_on_carousel_input)
	_carousel.mouse_exited.connect(_clear_hover)
	add_child(_carousel)

	_strip = Control.new()
	_strip.name = "Pages"
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.position = Vector2.ZERO
	_strip.size = Vector2(_stride * float(_page_count), _carousel_h)
	_carousel.add_child(_strip)

	for p in _page_count:
		var page := Control.new()
		page.name = "Page%d" % (p + 1)
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.position = Vector2(_stride * float(p), 0)
		page.size = Vector2(_stride, _carousel_h)
		_strip.add_child(page)
		var per_page := 1 if _portrait else PAGE_SIZE
		for i in per_page:
			var idx := p * per_page + i
			if idx >= GameData.STAGE_ORDER.size():
				break
			var id: String = GameData.STAGE_ORDER[idx]
			var card := _make_stage_card(id, idx)
			var card_x := _card_left if _portrait else 19.0 + float(i) * (CARD_W + CARD_GAP)
			UIKit.place(card["root"], card_x, _card_top, CARD_W, CARD_H)
			if _portrait:
				card["root"].scale = Vector2(PORTRAIT_SCALE, PORTRAIT_SCALE)
			page.add_child(card["root"])
			_cards[id] = card

	_prev_btn = _make_page_arrow("<", Vector2(1, 220) if _portrait else Vector2(1, 296))
	_prev_btn.pressed.connect(func() -> void: _go_page(_page - 1, true, true))
	add_child(_prev_btn)
	_next_btn = _make_page_arrow(">", Vector2(693, 220) if _portrait else Vector2(1254, 296))
	_next_btn.pressed.connect(func() -> void: _go_page(_page + 1, true, true))
	add_child(_next_btn)


func _make_page_arrow(glyph: String, pos: Vector2) -> Button:
	var button := Button.new()
	button.text = glyph
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(26, 110)
	button.position = pos
	button.size = Vector2(26, 110)
	button.add_theme_font_size_override("font_size", 38)
	button.add_theme_color_override("font_color", Color(0.9, 0.92, 0.96, 0.72))
	button.add_theme_color_override("font_hover_color", UIKit.GOLD)
	button.add_theme_color_override("font_pressed_color", UIKit.GOLD)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


func _make_stage_card(id: String, _index: int) -> Dictionary:
	var info: Dictionary = GameData.STAGES[id]
	var accent: Color = info["accent"]
	var root := UIKit.panel(Color(0.045, 0.07, 0.105, 0.94), UIKit.BORDER, 2)
	root.custom_minimum_size = Vector2(CARD_W, CARD_H)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.clip_contents = true

	var stripe := ColorRect.new()
	stripe.color = accent
	stripe.position = Vector2(2, 2)
	stripe.size = Vector2(232, 4)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stripe)

	var img := TextureRect.new()
	img.texture = load(String(info["thumb"]))
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.custom_minimum_size = Vector2.ZERO
	img.position = Vector2(16, 16)
	img.size = Vector2(204, 118)
	img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root.add_child(img)

	# Front-number plate: dark metal inset, accent jewel and gold pixel border.
	var num_bg := UIKit.panel(Color(0.035, 0.055, 0.08, 0.96), accent, 2)
	UIKit.place(num_bg, 22, 22, 52, 26)
	var gem := UIKit.label("◆", 8, accent)
	gem.position = Vector2(5, 7)
	gem.size = Vector2(10, 12)
	num_bg.add_child(gem)
	var num := UIKit.label("%02d" % int(info["num"]), 12, UIKit.CREAM, 2)
	num.position = Vector2(15, 2)
	num.size = Vector2(31, 22)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_bg.add_child(num)
	var underline := ColorRect.new()
	underline.color = Color(accent.r, accent.g, accent.b, 0.75)
	underline.position = Vector2(5, 21)
	underline.size = Vector2(42, 2)
	underline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num_bg.add_child(underline)
	root.add_child(num_bg)

	var name_label := UIKit.label(String(info["short"]), 18, UIKit.CREAM, 3)
	name_label.position = Vector2(16, 142)
	name_label.size = Vector2(204, 26)
	root.add_child(name_label)

	var desc := UIKit.label(String(info["subtitle"]), 12, Color(0.78, 0.82, 0.86))
	desc.position = Vector2(16, 168)
	desc.size = Vector2(204, 22)
	desc.autowrap_mode = TextServer.AUTOWRAP_OFF
	root.add_child(desc)

	var icon_label := UIKit.label("출현", 11, UIKit.MUTED)
	icon_label.position = Vector2(16, 199)
	root.add_child(icon_label)
	var icons: Array = info["enemy_icons"]
	for i in mini(3, icons.size()):
		var enemy_id: String = icons[i]
		var enemy_info: Dictionary = GameData.ENEMIES[enemy_id]
		var icon := UIKit.icon(String(enemy_info["texture"]), 25)
		icon.position = Vector2(56 + i * 34, 194)
		root.add_child(icon)

	var boss := UIKit.label("10 STAGES · CH. BOSS", 11, accent)
	boss.position = Vector2(16, 230)
	boss.size = Vector2(204, 18)
	root.add_child(boss)
	var chapter_boss: Dictionary = GameData.chapter_boss_data(id)
	var boss_name := UIKit.label(String(chapter_boss.get("name", GameData.ENEMIES[info["boss"]]["name"])), 11, accent)
	boss_name.position = Vector2(16, 248)
	boss_name.size = Vector2(204, 18)
	root.add_child(boss_name)

	var rec := UIKit.label("", 11, UIKit.MINT)
	rec.position = Vector2(16, 276)
	rec.size = Vector2(204, 18)
	root.add_child(rec)

	var lock := UIKit.label("LOCK · 이전 전선 클리어", 12, Color(1.0, 0.72, 0.35), 3)
	lock.position = Vector2(16, 54)
	lock.size = Vector2(204, 24)
	lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock.visible = false
	root.add_child(lock)

	_ignore_mouse(root)
	return {"root": root, "stripe": stripe, "record": rec, "accent": accent, "lock": lock}


func _ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)


func _make_diff_chip(id: String, index: int) -> Dictionary:
	var info: Dictionary = GameData.DIFFICULTIES[id]
	var root := UIKit.panel(Color(0.06, 0.09, 0.13, 0.95), UIKit.BORDER, 2)
	if _portrait:
		var col := index % 2
		var row := floori(float(index) / 2.0)
		UIKit.place(root, 20 + col * 350, 856 + row * 80, 330, 68)
	else:
		UIKit.place(root, 86 + index * 282, 534, 266, 52)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var name_label := UIKit.label(String(info["name"]), 19 if not _portrait else 18, UIKit.CREAM, 2)
	name_label.position = Vector2(14, 7)
	root.add_child(name_label)
	var tag := UIKit.label(String(info["tag"]), 11, info["color"])
	tag.position = Vector2(150, 13) if not _portrait else Vector2(196, 12)
	tag.size = Vector2(100, 18) if not _portrait else Vector2(120, 18)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(tag)
	var mod := UIKit.label(_diff_mods(id), 11 if not _portrait else 10, UIKit.MUTED)
	mod.position = Vector2(14, 30) if not _portrait else Vector2(14, 40)
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


# ------------------------------------------------------------------ carousel
func _on_carousel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_begin_drag(mb.position)
			else:
				_end_drag(mb.position)
			accept_event()
		elif mb.pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_LEFT]:
			_go_page(_page - 1, true, true)
			accept_event()
		elif mb.pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_RIGHT]:
			_go_page(_page + 1, true, true)
			accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _dragging:
			_move_drag(mm.position)
		else:
			_update_hover(mm.position)


func _begin_drag(pos: Vector2) -> void:
	_dragging = true
	_kill_page_tween()
	_drag_start = pos
	_drag_last = pos
	_drag_start_ms = Time.get_ticks_msec()
	_drag_moved = 0.0
	_carousel.mouse_default_cursor_shape = Control.CURSOR_DRAG
	if _hover_stage != "":
		_hover_stage = ""
		_refresh()


func _move_drag(pos: Vector2) -> void:
	var dx := pos.x - _drag_last.x
	_drag_last = pos
	_drag_moved += absf(dx)
	var min_x := -float(_page_count - 1) * _stride
	var raw := _strip.position.x + dx
	if raw > 0.0:
		raw *= 0.35
	elif raw < min_x:
		raw = min_x + (raw - min_x) * 0.35
	_strip.position.x = raw


func _end_drag(pos: Vector2) -> void:
	if not _dragging:
		return
	_dragging = false
	var dx := pos.x - _drag_start.x
	var elapsed := maxf(0.016, float(Time.get_ticks_msec() - _drag_start_ms) / 1000.0)
	var speed := dx / elapsed
	if _drag_moved < 12.0 and absf(dx) < 12.0:
		var id := _card_at(_drag_start)
		if id != "":
			_open_stage_picker(id)
		_go_page(_page)
	else:
		var target := _page
		if dx <= -SWIPE_DIST or speed <= -SWIPE_SPEED:
			target += 1
		elif dx >= SWIPE_DIST or speed >= SWIPE_SPEED:
			target -= 1
		_go_page(target, true, true)
	_hover_stage = ""
	_refresh()


func _go_page(target: int, animate: bool = true, select_visible: bool = false) -> void:
	_page = clampi(target, 0, _page_count - 1)
	var x := -float(_page) * _stride
	_kill_page_tween()
	if animate and not is_equal_approx(_strip.position.x, x):
		_page_tween = create_tween()
		_page_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_page_tween.tween_property(_strip, "position:x", x, 0.28)
	else:
		_strip.position.x = x
	if select_visible and _portrait:
		var chapter: String = GameData.STAGE_ORDER[_page]
		if Game.is_stage_unlocked(GameData.campaign_stage_id(chapter, 1)):
			if GameData.chapter_of(_selected_stage) != chapter:
				var chosen := GameData.campaign_stage_id(chapter, 1)
				for number in range(1, GameData.CHAPTER_STAGE_COUNT + 1):
					var candidate := GameData.campaign_stage_id(chapter, number)
					if Game.is_stage_unlocked(candidate):
						chosen = candidate
				_selected_stage = chosen
			Game.select_stage(_selected_stage, _selected_diff)
			_refresh()
			Audio.play_click()
	_update_page_ui()


func _kill_page_tween() -> void:
	if _page_tween != null and _page_tween.is_valid():
		_page_tween.kill()


func _ensure_page(id: String, animate: bool = true) -> void:
	var chapter := GameData.chapter_of(id)
	var idx := GameData.STAGE_ORDER.find(chapter)
	if idx < 0:
		return
	var page := idx if _portrait else floori(float(idx) / float(PAGE_SIZE))
	_go_page(page, animate)


func _card_at(pos: Vector2) -> String:
	if pos.y < 0.0 or pos.y > _carousel_h:
		return ""
	var local := pos.x - _strip.position.x
	var page := floori(local / _stride)
	if page < 0 or page >= _page_count:
		return ""
	var px := local - float(page) * _stride
	var idx := 0
	if _portrait:
		var left := _card_left
		if px < left or px > left + CARD_W * _card_scale:
			return ""
		if pos.y < _card_top or pos.y > _card_top + CARD_H * _card_scale:
			return ""
		idx = page
	else:
		var col := floori((px - 19.0) / (CARD_W + CARD_GAP))
		if col < 0 or col >= PAGE_SIZE:
			return ""
		var left := 19.0 + float(col) * (CARD_W + CARD_GAP)
		if px < left or px > left + CARD_W:
			return ""
		if pos.y > CARD_H:
			return ""
		idx = page * PAGE_SIZE + col
	if idx < 0 or idx >= GameData.STAGE_ORDER.size():
		return ""
	return GameData.STAGE_ORDER[idx]


func _update_hover(pos: Vector2) -> void:
	var id := _card_at(pos)
	_carousel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if id != "" else Control.CURSOR_DRAG
	if id == _hover_stage:
		return
	_hover_stage = id
	_refresh()


func _clear_hover() -> void:
	if _hover_stage == "":
		return
	_hover_stage = ""
	_refresh()


func _update_page_ui() -> void:
	if _page_label != null:
		_page_label.text = "20 CHAPTERS · 10 STAGES EACH · %d / %d  ·  SWIPE" % [
			_page + 1, _page_count,
		]
	if _prev_btn != null:
		_prev_btn.disabled = _page <= 0
		_prev_btn.modulate.a = 0.22 if _prev_btn.disabled else 1.0
	if _next_btn != null:
		_next_btn.disabled = _page >= _page_count - 1
		_next_btn.modulate.a = 0.22 if _next_btn.disabled else 1.0


# ------------------------------------------------------------------ selection
func _on_diff_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_diff(id)


func _cycle_stage(direction: int) -> void:
	var order: Array = GameData.STAGE_ORDER
	var idx := order.find(GameData.chapter_of(_selected_stage))
	if idx < 0:
		return
	for step in range(1, order.size() + 1):
		var candidate := String(order[(idx + direction * step + order.size() * 2) % order.size()])
		if Game.is_stage_unlocked(candidate):
			_select_stage(candidate)
			return


func _cycle_difficulty(direction: int) -> void:
	var order: Array = GameData.DIFFICULTY_ORDER
	var idx := order.find(_selected_diff)
	if idx < 0:
		return
	idx = clampi(idx + direction, 0, order.size() - 1)
	_select_diff(String(order[idx]))


func _select_stage(id: String) -> void:
	if not Game.is_stage_unlocked(id):
		if _stage_hint != null:
			_stage_hint.visible = true
			_stage_hint.text = "이전 전선을 클리어해야 다음 전선이 열립니다."
		return
	var chapter := GameData.chapter_of(id)
	var chosen := id
	if GameData.STAGES.has(id):
		chosen = GameData.campaign_stage_id(chapter, 1)
		for number in range(1, GameData.CHAPTER_STAGE_COUNT + 1):
			var candidate := GameData.campaign_stage_id(chapter, number)
			if Game.is_stage_unlocked(candidate):
				chosen = candidate
	_selected_stage = chosen
	Game.select_stage(_selected_stage, _selected_diff)
	_refresh()
	_ensure_page(chosen)
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
		var unlocked := Game.is_stage_unlocked(GameData.campaign_stage_id(id, 1))
		var selected: bool = id == GameData.chapter_of(_selected_stage)
		var hovered: bool = unlocked and id == _hover_stage
		card["root"].modulate = Color(1, 1, 1, 1) if unlocked else Color(0.62, 0.62, 0.68, 1)
		card["lock"].visible = not unlocked
		card["root"].add_theme_stylebox_override("panel", UIKit.style(
			Color(0.075, 0.11, 0.155, 0.98) if (selected or hovered) else Color(0.045, 0.07, 0.105, 0.94),
			accent if (selected or hovered) else UIKit.BORDER,
			3 if selected else (3 if hovered else 2), 0))
		var cleared_count := 0
		for number in range(1, GameData.CHAPTER_STAGE_COUNT + 1):
			if Game.has_cleared(GameData.campaign_stage_id(id, number)):
				cleared_count += 1
		card["record"].text = ("챕터 진행  %d / 10" % cleared_count) if unlocked else "이전 챕터 클리어 필요"
		card["record"].add_theme_color_override("font_color", accent if selected else (UIKit.MINT if unlocked else UIKit.CORAL))
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
	if _start_btn != null:
		var current_stage := GameData.stage(_selected_stage)
		_start_btn.text = "출격 %s" % String(current_stage.get("stage_label", "1-1"))
	if _stage_hint != null:
		_stage_hint.visible = false
	if _character_btn != null:
		_character_btn.text = "친구 · %s" % CharacterData.display_name(Game.selected_character)
	if _endless_btn != null:
		var unlocked := Game.is_endless_unlocked()
		if _portrait:
			_endless_btn.text = "무한" if unlocked else "무한 잠금"
		else:
			_endless_btn.text = "무한 모드" if unlocked else "무한 잠금"
		_endless_btn.tooltip_text = "끝없이 버티는 모드" if unlocked else "20개 챕터를 완료하면 해금됩니다"
		if unlocked:
			var er: Dictionary = Game.endless_best(_selected_stage)
			if float(er.get("best_time", 0.0)) > 0.0:
				_endless_btn.tooltip_text = "무한 모드 · 최고 %s · %d 킬" % [
					GameData.format_time(float(er.get("best_time", 0.0))),
					int(er.get("best_kills", 0)),
				]
		_endless_btn.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.7, 0.7, 0.75, 1)
	if _daily_btn != null:
		if Game.daily_info.is_empty() or String(Game.daily_info.get("date", "")) != Game.daily_key():
			Game.prepare_daily()
		var mod: Dictionary = Game.daily_info.get("modifier", {})
		var daily_stage := GameData.stage(String(Game.daily_info.get("stage", "forest")))
		_daily_btn.tooltip_text = "오늘의 도전 · %s · %s · %s" % [
			String(daily_stage["short"]),
			String(GameData.difficulty(String(Game.daily_info.get("diff", "normal")))["name"]),
			String(mod.get("name", "")),
		]
	_update_page_ui()


func _start() -> void:
	if _starting:
		return
	if not Game.is_stage_unlocked(_selected_stage):
		if _stage_hint != null:
			_stage_hint.visible = true
			_stage_hint.text = "이전 전선을 클리어해야 다음 전선이 열립니다."
		return
	_starting = true
	Audio.play_click()
	Game.new_run(_selected_stage, _selected_diff)


func _start_endless() -> void:
	if _starting:
		return
	if not Game.is_endless_unlocked():
		if _stage_hint != null:
			_stage_hint.visible = true
			_stage_hint.text = "20개 챕터를 완료하면 무한 모드가 열립니다."
		return
	_starting = true
	Audio.play_click()
	Game.new_run(_selected_stage, _selected_diff, "endless")


func _start_daily() -> void:
	if _starting:
		return
	if Game.daily_info.is_empty() or String(Game.daily_info.get("date", "")) != Game.daily_key():
		Game.prepare_daily()
	var info := Game.daily_info
	var stage := GameData.stage(String(info.get("stage", "forest")))
	var diff := GameData.difficulty(String(info.get("diff", "normal")))
	var mod: Dictionary = info.get("modifier", {})
	_daily_modal_desc.text = "%s · %s\n%s — %s" % [
		String(stage["short"]), String(diff["name"]),
		String(mod.get("name", "")), String(mod.get("desc", "")),
	]
	var rec: Dictionary = Game.daily_record()
	if rec.is_empty() or float(rec.get("best_time", 0.0)) <= 0.0:
		_daily_modal_best.text = "오늘 아직 도전 기록이 없습니다"
	elif int(rec.get("clears", 0)) <= 0:
		_daily_modal_best.text = "오늘 최고 %s · %d 킬 · 클리어 전" % [
			GameData.format_time(float(rec.get("best_time", 0.0))),
			int(rec.get("best_kills", 0)),
		]
	else:
		_daily_modal_best.text = "오늘 최고 %s · %d 킬 · 클리어 %d" % [
			GameData.format_time(float(rec.get("best_time", 0.0))),
			int(rec.get("best_kills", 0)), int(rec.get("clears", 0)),
		]
	Audio.play_click()
	_daily_modal.visible = true


func _confirm_daily() -> void:
	if _starting:
		return
	_starting = true
	_daily_modal.visible = false
	Audio.play_click()
	Game.start_daily()


func _close_daily_modal() -> void:
	_daily_modal.visible = false
	Audio.play_click()


func _open_achievements() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_achievements("stage_select")


func _open_altar() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_altar("stage_select")


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
	if _stage_modal != null and _stage_modal.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_stage_modal.visible = false
			get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.pressed:
		_handle_joy_button(event.button_index)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _daily_modal != null and _daily_modal.visible:
			if event.keycode == KEY_ESCAPE:
				_close_daily_modal()
			elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				_confirm_daily()
			get_viewport().set_input_as_handled()
			return
		if _weekly_modal != null and _weekly_modal.visible:
			if event.keycode == KEY_ESCAPE:
				_weekly_modal.visible = false
			get_viewport().set_input_as_handled()
			return
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
		elif event.keycode == KEY_A:
			_open_achievements()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_T:
			_open_altar()
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
		elif event.keycode == KEY_4:
			_select_stage("crater")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_5:
			_select_stage("void")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_6:
			_select_stage("dunes")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_7:
			_select_stage("frost")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_8:
			_select_stage("mire")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_9:
			_select_stage("ruins")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_0:
			_select_stage("citadel")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Q or event.keycode == KEY_PAGEUP:
			_go_page(_page - 1, true, true)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E or event.keycode == KEY_PAGEDOWN:
			_go_page(_page + 1, true, true)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT:
			_cycle_difficulty(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			_cycle_difficulty(1)
			get_viewport().set_input_as_handled()


func _handle_joy_button(button: int) -> void:
	if _daily_modal != null and _daily_modal.visible:
		if button == JOY_BUTTON_A:
			_confirm_daily()
		elif button == JOY_BUTTON_B:
			_close_daily_modal()
		get_viewport().set_input_as_handled()
		return
	if _weekly_modal != null and _weekly_modal.visible:
		if button == JOY_BUTTON_B:
			_weekly_modal.visible = false
		get_viewport().set_input_as_handled()
		return
	match button:
		JOY_BUTTON_A:
			_start()
		JOY_BUTTON_B:
			_go_title()
		JOY_BUTTON_DPAD_LEFT:
			_cycle_stage(-1)
		JOY_BUTTON_DPAD_RIGHT:
			_cycle_stage(1)
		JOY_BUTTON_DPAD_UP:
			_cycle_difficulty(-1)
		JOY_BUTTON_DPAD_DOWN:
			_cycle_difficulty(1)
		_:
			return
	get_viewport().set_input_as_handled()


func _refresh_input_hint() -> void:
	if _input_hint == null:
		return
	if Input.get_connected_joypads().size() > 0:
		_input_hint.text = "스틱/D-PAD 선택  ·  A 출격  ·  B 뒤로  ·  START 일시정지"
	else:
		_input_hint.text = "ENTER 출격  ·  I 장비  ·  Q/E 전선  ·  좌우 난이도"


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_input_hint()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _daily_modal != null and _daily_modal.visible:
			_close_daily_modal()
		elif _weekly_modal != null and _weekly_modal.visible:
			_weekly_modal.visible = false
		elif _stage_modal != null and _stage_modal.visible:
			_stage_modal.visible = false
		else:
			_go_title()


func _test_platform_input() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	var errors: Array = []
	var old_stage := _selected_stage
	var old_diff := _selected_diff
	var old_records := Game.stage_records.duplicate(true)
	Game.stage_records = {}
	Game.stage_records["forest_10:normal"] = {"clears": 1}
	_selected_stage = "forest_10"
	_selected_diff = "normal"
	_handle_joy_button(JOY_BUTTON_DPAD_RIGHT)
	if GameData.chapter_of(_selected_stage) != "hive":
		errors.append("D-PAD right did not select the next chapter")
	_cycle_difficulty(1)
	if _selected_diff != "dark":
		errors.append("D-PAD difficulty cycle failed")
	_cycle_difficulty(-1)
	if _selected_diff != "normal":
		errors.append("D-PAD difficulty restore failed")
	_refresh_input_hint()
	if _input_hint == null or _input_hint.text.is_empty():
		errors.append("input hint missing")
	Game.stage_records = old_records
	_selected_stage = old_stage
	_selected_diff = old_diff
	Game.select_stage(_selected_stage, _selected_diff)
	Game.save_settings()
	_ensure_page(_selected_stage, false)
	_refresh()
	if errors.is_empty():
		print("PLATFORM INPUT TEST PASS stage=%s diff=%s" % [_selected_stage, _selected_diff])
		print("TEST PASS")
	else:
		print("PLATFORM INPUT TEST FAIL")
		for error in errors:
			print("  ", error)
		print("TEST FAIL")
	get_tree().quit(0 if errors.is_empty() else 1)


func _test_swipe() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	var old_records := Game.stage_records.duplicate(true)
	var old_stage := _selected_stage
	var old_diff := _selected_diff
	for id in GameData.campaign_order():
		Game.stage_records["%s:normal" % id] = {
			"clears": 1, "boss": true, "best_kills": 100, "best_level": 10,
			"best_time": 200.0,
		}
	_selected_stage = "hive_01"
	Game.select_stage(_selected_stage, _selected_diff)
	_refresh()
	_ensure_page(_selected_stage, false)
	var start_page := _page
	var page_ok := start_page == (1 if _portrait else 0)
	var from_x := 500.0 if _portrait else 900.0
	var to_x := 120.0 if _portrait else 500.0
	var back_x := 560.0 if _portrait else 900.0
	await _swipe(Vector2(from_x, 300), Vector2(to_x, 300))
	var next_ok := _page == mini(_page_count - 1, start_page + 1)
	await _swipe(Vector2(to_x, 300), Vector2(back_x, 300))
	var back_ok := _page == start_page
	_go_page(0, false)
	await _swipe(Vector2(to_x, 300), Vector2(back_x, 300))
	var clamp_ok := _page == 0
	var tap_pos := Vector2(19 + 115, 180) if not _portrait else Vector2(360, 300)
	await _tap(tap_pos)
	var opened := _stage_modal != null and _stage_modal.visible
	_choose_stage(1)
	var tap_ok := opened and _selected_stage == "forest_01"
	Game.stage_records = old_records
	_selected_stage = old_stage
	_selected_diff = old_diff
	Game.select_stage(_selected_stage, _selected_diff)
	Game.save_settings()
	_refresh()
	print("SWIPE TEST portrait=%s start=%d next=%s back=%s clamp=%s tap=%s selected=%s page=%d" % [
		_portrait, start_page, next_ok, back_ok, clamp_ok, tap_ok, _selected_stage, _page,
	])
	if not page_ok or not next_ok or not back_ok or not clamp_ok or not tap_ok:
		push_error("SWIPE TEST FAILED")
		get_tree().quit(1)
		return
	print("SWIPE TEST OK")
	get_tree().quit()


func _capture_chapters() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	_open_stage_picker("forest")
	await get_tree().create_timer(0.25, true, false, true).timeout
	await _capture("chapters")


func _test_chapters() -> void:
	await get_tree().create_timer(0.35, true, false, true).timeout
	var errors: Array = []
	var old_records := Game.stage_records.duplicate(true)
	var old_stage := _selected_stage
	var old_diff := _selected_diff
	if GameData.campaign_order().size() != 200:
		errors.append("campaign order=%d" % GameData.campaign_order().size())
	if GameData.CHAPTER_BOSSES.size() != 20:
		errors.append("chapter bosses=%d" % GameData.CHAPTER_BOSSES.size())
	if GameData.CHAPTER_ENEMY_CONCEPTS.size() != 20:
		errors.append("chapter concepts=%d" % GameData.CHAPTER_ENEMY_CONCEPTS.size())
	var unique_names := {}
	for stage_key in GameData.campaign_order():
		var unique_id := GameData.chapter_enemy_id(String(stage_key))
		if not GameData.enemy_exists(unique_id):
			errors.append("missing enemy data: %s" % unique_id)
			continue
		var unique_data := GameData.enemy_data(unique_id)
		if not ResourceLoader.exists(String(unique_data.get("texture", ""))):
			errors.append("missing enemy sprite: %s" % unique_id)
		unique_names[String(unique_data.get("name", ""))] = true
		if not GameData.stage_spawn_weights(String(stage_key), 0.0).has(unique_id):
			errors.append("enemy not in spawn weights: %s" % unique_id)
	if unique_names.size() != 200:
		errors.append("unique enemy names=%d" % unique_names.size())
	var boss := GameData.chapter_boss_data("forest")
	if boss.is_empty() or String((boss.get("skill", {}) as Dictionary).get("name", "")) == "":
		errors.append("chapter boss skill missing")
	if GameData.reward_text(boss.get("reward", {})).is_empty():
		errors.append("chapter boss reward missing")
	var old_rewards := Game.chapter_rewards.duplicate(true)
	Game.chapter_rewards["forest"] = true
	if float(Game.chapter_bonuses().get("max_hp", 0.0)) < 15.0:
		errors.append("chapter reward not applied")
	Game.chapter_rewards = old_rewards
	Game.stage_records = {}
	if not Game.is_stage_unlocked("forest_01"):
		errors.append("first stage locked")
	if Game.is_stage_unlocked("forest_02"):
		errors.append("second stage opened too early")
	Game.stage_records["forest_01:normal"] = {"clears": 1}
	if not Game.is_stage_unlocked("forest_02"):
		errors.append("second stage did not unlock")
	Game.stage_records["forest_10:normal"] = {"clears": 1}
	if not Game.is_stage_unlocked("hive_01"):
		errors.append("next chapter did not unlock")
	_open_stage_picker("forest")
	if not _stage_modal.visible or _stage_modal_buttons.size() != 10:
		errors.append("stage picker did not open")
	_choose_stage(1)
	if _selected_stage != "forest_01":
		errors.append("stage picker selection=%s" % _selected_stage)
	Game.stage_records = old_records
	_selected_stage = old_stage
	_selected_diff = old_diff
	Game.select_stage(_selected_stage, _selected_diff)
	Game.save_settings()
	_refresh()
	if errors.is_empty():
		print("CHAPTER TEST PASS stages=200 chapters=20")
		print("TEST PASS")
	else:
		print("CHAPTER TEST FAIL")
		for error in errors:
			print("  ", error)
		print("TEST FAIL")
	get_tree().quit(0 if errors.is_empty() else 1)



func _swipe(from: Vector2, to: Vector2) -> void:
	_send_button(from, true)
	await get_tree().process_frame
	_send_motion((from + to) * 0.5)
	_send_motion(to)
	await get_tree().process_frame
	_send_button(to, false)
	await get_tree().create_timer(0.45, true, false, true).timeout


func _tap(pos: Vector2) -> void:
	_send_button(pos, true)
	await get_tree().process_frame
	_send_button(pos, false)
	await get_tree().process_frame


func _send_button(pos: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = _carousel.get_global_transform_with_canvas() * pos
	e.global_position = e.position
	get_viewport().push_input(e, true)


func _send_motion(pos: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = _carousel.get_global_transform_with_canvas() * pos
	e.global_position = e.position
	get_viewport().push_input(e, true)


func _capture_daily_modal() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	_start_daily()
	await get_tree().create_timer(0.3, true, false, true).timeout
	await _capture("daily_modal")


func _capture_weekly() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	_open_weekly()
	await get_tree().create_timer(0.3, true, false, true).timeout
	await _capture("weekly")


func _capture(shot: String = "stage_select") -> void:
	await get_tree().create_timer(1.2, true, false, true).timeout
	_ensure_page(_selected_stage, false)
	await get_tree().process_frame
	await get_tree().process_frame
	var view := get_viewport_rect().size
	if view.y > view.x:
		shot += "_portrait"
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/%s.png" % shot)
	print("CAPTURED: ", dir + "/%s.png" % shot)
	get_tree().quit()
