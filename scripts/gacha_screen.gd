extends Control

## Moonlit equipment summon screen. Test-currency build: real Play Billing will
## be connected after the store product IDs are ready.

var _portrait := false
var _reloading := false
var _diamonds_label: Label
var _pity_label: Label
var _history_label: Label
var _message: Label
var _results: GridContainer
var _one_btn: Button
var _ten_btn: Button
var _test_btn: Button
var _skip_btn: Button
var _rates_modal: Control
var _result_nodes: Array[Node] = []
var _reveal_token := 0
var _flash: ColorRect
var _banner: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_portrait = _is_portrait()
	_build()
	UIFit.wrap_menu(self, "res://assets/art/ui/menu_backdrop.png",
		UIFit.PORTRAIT if _portrait else UIFit.DESIGN)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_refresh()
	var login_bonus := Game.claim_login_reward()
	if login_bonus > 0 and _message != null:
		_message.text = "출석 보상  ◆ %d  ·  %d일차" % [login_bonus, Game.gacha_login_streak]
		_message.add_theme_color_override("font_color", UIKit.GOLD_L)
	_refresh()
	var args := OS.get_cmdline_user_args()
	if "--capture-gacha" in args:
		_capture()


func _is_portrait() -> bool:
	var size := get_viewport_rect().size
	return size.y > size.x


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
	shade.color = Color(0.01, 0.02, 0.04, 0.78)
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var over := UIKit.label("MOONLIT SUMMON  ·  DALBEAR.COM", 13, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("달빛 소환", 42 if _portrait else 46, UIKit.GOLD, 7)
	title.position = Vector2(24, 38) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("달빛 장비를 소환합니다. 전설 장비는 이곳에서만 얻을 수 있습니다.", 13 if _portrait else 15, UIKit.CREAM)
	sub.position = Vector2(26, 94) if _portrait else Vector2(56, 98)
	sub.size = Vector2(660, 24) if _portrait else Vector2(850, 24)
	add_child(sub)

	var back := UIKit.button("← 돌아가기", Vector2(164, 42))
	back.position = Vector2(540, 22) if _portrait else Vector2(1074, 30)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_go_back)
	add_child(back)

	var wallet := UIKit.panel(Color(0.05, 0.08, 0.12, 0.96), UIKit.GOLD.darkened(0.35), 2)
	if _portrait:
		UIKit.place(wallet, 24, 126, 300, 38)
	else:
		UIKit.place(wallet, 834, 36, 220, 42)
	add_child(wallet)
	var gem := UIKit.label("◆", 19, UIKit.GOLD)
	gem.position = Vector2(12, 5 if _portrait else 6)
	gem.size = Vector2(24, 26)
	wallet.add_child(gem)
	_diamonds_label = UIKit.label("", 16, UIKit.GOLD)
	_diamonds_label.position = Vector2(38, 5 if _portrait else 7)
	_diamonds_label.size = Vector2(170, 26)
	_diamonds_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wallet.add_child(_diamonds_label)

	var main_panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.95), UIKit.BORDER, 2)
	if _portrait:
		UIKit.place(main_panel, 24, 178, 672, 800)
	else:
		UIKit.place(main_panel, 190, 142, 900, 466)
	add_child(main_panel)

	var rate_hint := UIKit.label("전설 0.25%  ·  천장 120회  ·  10회 에픽 이상 보장", 12, UIKit.MUTED)
	rate_hint.position = Vector2(24, 14)
	main_panel.add_child(rate_hint)
	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.25)
	line.position = Vector2(24, 40)
	line.size = Vector2(852 if not _portrait else 624, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_panel.add_child(line)

	_pity_label = UIKit.label("", 13, UIKit.GOLD)
	_pity_label.position = Vector2(24, 50)
	_pity_label.size = Vector2(500, 22)
	main_panel.add_child(_pity_label)

	_results = GridContainer.new()
	_results.columns = 2 if _portrait else 5
	_results.add_theme_constant_override("h_separation", 12)
	_results.add_theme_constant_override("v_separation", 12)
	if _portrait:
		_results.position = Vector2(24, 88)
		_results.size = Vector2(624, 600)
	else:
		_results.position = Vector2(24, 86)
		_results.size = Vector2(852, 280)
	main_panel.add_child(_results)

	_history_label = UIKit.label("", 11, UIKit.MUTED)
	_history_label.position = Vector2(24, 354 if not _portrait else 594)
	_history_label.size = Vector2(852 if not _portrait else 624, 22)
	_history_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	main_panel.add_child(_history_label)

	_message = UIKit.label("소환 버튼을 눌러 장비를 획득하세요.", 13, UIKit.MUTED)
	_message.position = Vector2(24, 408 if not _portrait else 730)
	_message.size = Vector2(852 if not _portrait else 624, 28)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_panel.add_child(_message)

	var one_cost := "◆ %d" % Game.GACHA_1_COST
	var ten_cost := "◆ %d" % Game.GACHA_10_COST
	_one_btn = UIKit.button("1회 소환  " + one_cost, Vector2(250, 52))
	_one_btn.position = Vector2(250, 630) if not _portrait else Vector2(44, 1000)
	_one_btn.add_theme_font_size_override("font_size", 17)
	_one_btn.pressed.connect(func() -> void: _pull(1))
	add_child(_one_btn)
	_ten_btn = UIKit.button("10회 소환  " + ten_cost, Vector2(270, 52))
	_ten_btn.position = Vector2(520, 630) if not _portrait else Vector2(332, 1000)
	_ten_btn.add_theme_font_size_override("font_size", 17)
	_ten_btn.pressed.connect(func() -> void: _pull(10))
	add_child(_ten_btn)

	var rates := UIKit.button("확률 보기", Vector2(150, 42))
	rates.position = Vector2(812, 630) if not _portrait else Vector2(44, 1064)
	rates.add_theme_font_size_override("font_size", 15)
	rates.pressed.connect(_open_rates)
	add_child(rates)

	_test_btn = UIKit.button("테스트 다이아 +1,000", Vector2(230, 30))
	_test_btn.position = Vector2(812, 84) if not _portrait else Vector2(340, 126)
	_test_btn.add_theme_font_size_override("font_size", 12)
	_test_btn.pressed.connect(_test_charge)
	add_child(_test_btn)

	_skip_btn = UIKit.button("결과 전체 공개", Vector2(220, 34))
	_skip_btn.position = Vector2(530, 680) if not _portrait else Vector2(240, 1120)
	_skip_btn.add_theme_font_size_override("font_size", 14)
	_skip_btn.visible = false
	_skip_btn.pressed.connect(_skip_reveal)
	add_child(_skip_btn)

	_flash = ColorRect.new()
	_flash.color = Color(1.0, 0.82, 0.35, 0.0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.visible = false
	add_child(_flash)
	_banner = UIKit.label("", 34 if _portrait else 42, UIKit.GOLD_L, 8)
	_banner.position = Vector2(0, 300) if _portrait else Vector2(0, 300)
	_banner.size = Vector2(720 if _portrait else 1280, 60)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.visible = false
	add_child(_banner)

	_build_rates_modal()


func _build_rates_modal() -> void:
	_rates_modal = Control.new()
	_rates_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rates_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_rates_modal.visible = false
	add_child(_rates_modal)
	var dim := ColorRect.new()
	dim.color = Color(0.005, 0.01, 0.02, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rates_modal.add_child(dim)
	var panel := UIKit.panel(Color(0.05, 0.08, 0.12, 0.99), UIKit.GOLD, 3)
	if _portrait:
		UIKit.place(panel, 34, 330, 652, 520)
	else:
		UIKit.place(panel, 340, 150, 600, 420)
	_rates_modal.add_child(panel)
	var title := UIKit.label("소환 확률", 28, UIKit.GOLD, 4)
	title.position = Vector2(28, 20)
	panel.add_child(title)
	var body := UIKit.label(
		"전설  ·  0.25%   (120회 천장)\n\n에픽  ·  4.75%\n\n희귀  ·  25.00%\n\n일반  ·  70.00%\n\n10회 소환은 에픽 이상 1개를 보장합니다.\n전설 장비는 소환에서만 획득할 수 있습니다.",
		17, UIKit.CREAM)
	body.position = Vector2(30, 78)
	body.size = Vector2(540, 260)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(body)
	var close := UIKit.button("닫기", Vector2(180, 48))
	close.position = Vector2(210, 342)
	close.add_theme_font_size_override("font_size", 18)
	close.pressed.connect(func() -> void: _rates_modal.visible = false)
	panel.add_child(close)


func _refresh() -> void:
	if _diamonds_label != null:
		_diamonds_label.text = "%d" % Game.diamonds
	if _pity_label != null:
		_pity_label.text = "다음 전설까지  %d회  ·  누적 소환  %d" % [
			maxi(0, EquipmentData.GACHA_PITY_LIMIT - Game.gacha_pity), Game.gacha_count,
		]
	if _one_btn != null:
		if Game.daily_free_gacha_available():
			_one_btn.text = "오늘의 무료 소환"
			_one_btn.disabled = false
		else:
			_one_btn.text = "1회 소환  ◆ %d" % Game.GACHA_1_COST
			_one_btn.disabled = Game.diamonds < Game.GACHA_1_COST
	if _ten_btn != null:
		_ten_btn.disabled = Game.diamonds < Game.GACHA_10_COST
	if _history_label != null:
		var recent: Array = []
		for i in range(maxi(0, Game.gacha_history.size() - 3), Game.gacha_history.size()):
			var entry: Dictionary = Game.gacha_history[i]
			recent.append("%s · %s" % [
				EquipmentData.rarity_name(String(entry.get("rarity", "common"))),
				String(entry.get("name", "")),
			])
		_history_label.text = "최근 소환  ·  " + ("  /  ".join(recent) if not recent.is_empty() else "기록 없음")


func _pull(count: int) -> void:
	var free := count == 1 and Game.daily_free_gacha_available()
	var result := Game.gacha_pull(count, free)
	if not result.get("ok", false):
		_message.text = String(result.get("message", "소환할 수 없습니다."))
		_message.add_theme_color_override("font_color", UIKit.CORAL)
		Audio.play_click()
		return
	Audio.play_click()
	var items: Array = result.get("items", [])
	_clear_results()
	_reveal_token += 1
	var high := false
	for index in items.size():
		var item: Dictionary = items[index]
		var card := _make_result_card(item)
		_results.add_child(card)
		_result_nodes.append(card)
		card.visible = false
		card.scale = Vector2(0.82, 0.82)
		card.pivot_offset = card.size * 0.5
		if String(item.get("rarity", "")) == "legendary":
			high = true
	_skip_btn.visible = true
	if high:
		_legendary_fx()
	_message.text = ("무료 소환 완료 · " if free else "") + ("전설 장비가 강림했습니다!" if high else "장비를 획득했습니다.")
	_message.add_theme_color_override("font_color", UIKit.GOLD_L if high else UIKit.MINT)
	_reveal_sequence(_reveal_token)


func _reveal_sequence(token: int) -> void:
	for card in _result_nodes:
		if token != _reveal_token:
			return
		card.visible = true
		var tw := create_tween()
		tw.tween_property(card, "scale", Vector2.ONE, 0.18)
		await get_tree().create_timer(0.105, true, false, false).timeout
	if token == _reveal_token:
		_skip_btn.visible = false


func _skip_reveal() -> void:
	_reveal_token += 1
	for card in _result_nodes:
		card.visible = true
		card.scale = Vector2.ONE
	_skip_btn.visible = false
	Audio.play_click()


func _legendary_fx() -> void:
	_flash.visible = true
	_flash.color = Color(1.0, 0.82, 0.35, 0.0)
	_banner.text = "전설 강림"
	_banner.visible = true
	Audio.play("levelup", 0.8, -1.0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_flash, "color:a", 0.32, 0.12)
	tw.tween_property(_flash, "color:a", 0.0, 0.5).set_delay(0.16)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.45).set_delay(0.3)
	tw.chain().tween_callback(func() -> void:
		_flash.visible = false
		_banner.visible = false
		_banner.modulate.a = 1.0
	)


func _make_result_card(item: Dictionary) -> Panel:
	var rarity := String(item.get("rarity", "common"))
	var accent := EquipmentData.rarity_color(rarity)
	var card := UIKit.panel(
		Color(0.07, 0.105, 0.15, 0.98) if rarity != "legendary" else Color(0.14, 0.10, 0.035, 0.99),
		accent, 2)
	card.custom_minimum_size = Vector2(260, 88) if _portrait else Vector2(158, 122)
	card.size = card.custom_minimum_size
	var icon := UIKit.icon(EquipmentData.item_icon(item), 42 if not _portrait else 48)
	icon.position = Vector2(12, 12) if not _portrait else Vector2(14, 14)
	card.add_child(icon)
	var name_label := UIKit.label(EquipmentData.item_name(item), 14 if not _portrait else 17, accent, 2)
	name_label.position = Vector2(60, 12) if not _portrait else Vector2(72, 15)
	name_label.size = Vector2(88, 38) if not _portrait else Vector2(176, 34)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(name_label)
	var rarity_label := UIKit.label(EquipmentData.rarity_name(rarity).to_upper(), 10 if not _portrait else 12, accent)
	rarity_label.position = Vector2(60, 58) if not _portrait else Vector2(72, 58)
	card.add_child(rarity_label)
	var type_label := UIKit.label(EquipmentData.item_short(item), 11, UIKit.MUTED)
	type_label.position = Vector2(60, 76) if not _portrait else Vector2(72, 80)
	if bool(item.get("duplicate", false)):
		type_label.text = "중복 · 조각 +%d" % int(item.get("shard_gain", 0))
		type_label.add_theme_color_override("font_color", UIKit.CORAL)
	card.add_child(type_label)
	if rarity == "legendary":
		var glow := UIKit.label("★", 16, UIKit.GOLD)
		glow.position = Vector2(132, 4) if not _portrait else Vector2(224, 4)
		glow.size = Vector2(20, 22)
		glow.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(glow)
	return card


func _clear_results() -> void:
	for node in _result_nodes:
		node.queue_free()
	_result_nodes.clear()


func _open_rates() -> void:
	_rates_modal.visible = true
	Audio.play_click()


func _test_charge() -> void:
	Game.add_diamonds(1000, true)
	_message.text = "테스트 다이아 1,000개를 충전했습니다."
	_message.add_theme_color_override("font_color", UIKit.MINT)
	_refresh()
	Audio.play_click()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var name := "gacha_portrait.png" if _portrait else "gacha.png"
	img.save_png(dir + "/" + name)
	print("CAPTURED: ", dir + "/" + name)
	get_tree().quit()


func _go_back() -> void:
	Audio.play_click()
	Game.close_gacha()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _rates_modal != null and _rates_modal.visible:
				_rates_modal.visible = false
			else:
				_go_back()
			get_viewport().set_input_as_handled()
