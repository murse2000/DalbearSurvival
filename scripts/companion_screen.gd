extends Control

## Moon companion codex: unlock/select companions from the altar.

var _args: PackedStringArray
var _portrait := false
var _reloading := false
var _cards := {}
var _message: Label
var _level_label: Label


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
	_refresh()
	if "--capture-companions" in _args:
		_capture()
	if "--test-companions-ui" in _args:
		_test_ui.call_deferred()


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

	var over := UIKit.label("MOON COMPANIONS  ·  DALBEAR.COM", 13 if not _portrait else 11, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("달빛 동료", 40 if _portrait else 44, UIKit.GOLD, 7)
	title.position = Vector2(24, 38) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("제단에서 해금한 동료 중 한 명이 모든 모험에 동행합니다.",
		12 if _portrait else 15, UIKit.CREAM)
	sub.position = Vector2(26, 94) if _portrait else Vector2(56, 96)
	add_child(sub)
	_level_label = UIKit.label("", 14, UIKit.GOLD)
	_level_label.position = Vector2(26, 122) if _portrait else Vector2(56, 122)
	add_child(_level_label)

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

	var list := CompanionData.all()
	for i in list.size():
		if _portrait:
			_make_card(list[i], Vector2(24, 164 + i * 138), 672.0, 128.0)
		else:
			var col := i % 2
			var row := i / 2
			_make_card(list[i], Vector2(56 + col * 584, 158 + row * 128), 580.0, 118.0)

	_message = UIKit.label("", 12, UIKit.MUTED)
	_message.position = Vector2(0, 1190) if _portrait else Vector2(0, 698)
	_message.size = Vector2(720, 18) if _portrait else Vector2(1280, 18)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_message)


func _make_card(data: Dictionary, pos: Vector2, w: float, h: float) -> void:
	var card := UIKit.panel(Color(0.06, 0.095, 0.14, 0.97), UIKit.BORDER, 2)
	card.position = pos
	card.size = Vector2(w, h)
	add_child(card)
	var icon := TextureRect.new()
	icon.texture = load(String(data["icon"]))
	icon.position = Vector2(14, (h - 50.0) * 0.5)
	icon.size = Vector2(50, 50)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	card.add_child(icon)
	var name_label := UIKit.label(String(data["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(76, 10)
	card.add_child(name_label)
	var title_label := UIKit.label(String(data["title"]), 10, UIKit.MUTED)
	title_label.position = Vector2(76, 34)
	card.add_child(title_label)
	var desc := UIKit.label(String(data["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(76, 56)
	desc.size = Vector2(w - 300.0, 30)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(desc)
	var element := UIKit.label(_element_name(String(data["element"])), 11,
		GameData.status_color(String(data["element"])))
	element.position = Vector2(76, h - 26.0)
	card.add_child(element)
	var button := UIKit.button("", Vector2(136, 38))
	button.position = Vector2(w - 150.0, (h - 38.0) * 0.5)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(_select.bind(String(data["id"])))
	card.add_child(button)
	_cards[String(data["id"])] = {"button": button, "icon": icon, "card": card, "data": data}


func _element_name(element: String) -> String:
	match element:
		"fire":
			return "불"
		"frost":
			return "서리"
		"shock":
			return "감전"
		"void":
			return "공허"
	return "달빛"


func _select(id: String) -> void:
	var result := Game.select_companion(id)
	if _message != null:
		_message.text = String(result.get("message", ""))
		_message.add_theme_color_override("font_color", UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	Audio.play("click" if not bool(result.get("ok", false)) else "levelup", 1.1, -8.0)
	_refresh()


func _refresh() -> void:
	if _level_label != null:
		var current_name := String(Game.companion_data()["name"]) \
			if Game.companion_unlocked(Game.selected_companion) else "없음"
		_level_label.text = "제단 동료 Lv.%d / 5 · 현재 %s" % [
			Game.altar_level("companion"), current_name,
		]
	for id in _cards.keys():
		var entry: Dictionary = _cards[id]
		var data: Dictionary = entry["data"]
		var unlocked := Game.companion_unlocked(String(id))
		var selected := Game.selected_companion == String(id) and unlocked
		var button: Button = entry["button"]
		var card: Panel = entry["card"]
		var icon: TextureRect = entry["icon"]
		card.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.6, 0.6, 0.66, 1)
		icon.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.55, 0.55, 0.6, 1)
		if not unlocked:
			button.text = "제단 Lv.%d" % int(data["unlock"])
			button.disabled = true
		elif selected:
			button.text = "동행 중"
			button.disabled = true
		else:
			button.text = "선택"
			button.disabled = false
		button.modulate = Color(1, 1, 1, 1) if not button.disabled else Color(0.7, 0.7, 0.74, 1)


func _go_back() -> void:
	Audio.play_click()
	Game.close_companions()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_go_back()
			get_viewport().set_input_as_handled()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "companions" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _test_ui() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	var errors: Array = []
	if CompanionData.all().size() != 5:
		errors.append("companion roster size")
	if _cards.size() != 5:
		errors.append("codex cards missing")
	if Game.companion_unlocked("star") != (Game.altar_level("companion") >= 1):
		errors.append("star unlock state mismatch")
	if errors.is_empty():
		print("COMPANION UI TEST PASS cards=%d" % _cards.size())
		print("TEST PASS")
	else:
		print("COMPANION UI TEST FAIL")
		for e in errors:
			print("  ", e)
		print("TEST FAIL")
	get_tree().quit()
