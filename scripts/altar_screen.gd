extends Control

## Moon altar: permanent upgrades bought with shards.

var _args: PackedStringArray
var _portrait := false
var _reloading := false
var _cards := {}
var _shards_label: Label
var _message: Label


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
	if "--capture-altar" in _args:
		_capture()
	if "--test-altar" in _args:
		_test_altar.call_deferred()


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

	var over := UIKit.label("MOON ALTAR  ·  DALBEAR.COM", 13 if not _portrait else 11, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("달빛 제단", 40 if _portrait else 44, UIKit.GOLD, 7)
	title.position = Vector2(24, 38) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("달빛 조각으로 영구 성장을 구매합니다. 모든 모험에 적용됩니다.",
		13 if _portrait else 15, UIKit.CREAM)
	sub.position = Vector2(26, 94) if _portrait else Vector2(56, 96)
	add_child(sub)

	_shards_label = UIKit.label("", 14, UIKit.GOLD)
	_shards_label.position = Vector2(26, 122) if _portrait else Vector2(56, 122)
	add_child(_shards_label)

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

	var list := AltarData.all()
	for i in list.size():
		if _portrait:
			_make_card(list[i], Vector2(24, 164 + i * 111), 672.0, 102.0)
		else:
			var column := i % 2
			var row := i / 2
			_make_card(list[i], Vector2(56 + column * 584, 156 + row * 126), 580.0, 116.0)

	var hint := UIKit.label("제단 강화는 새 모험·이어하기 모두에 적용됩니다", 11, UIKit.MUTED)
	hint.position = Vector2(0, 1190) if _portrait else Vector2(0, 698)
	hint.size = Vector2(720, 18) if _portrait else Vector2(1280, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)


func _make_card(upgrade: Dictionary, pos: Vector2, w: float, h: float) -> void:
	var card := UIKit.panel(Color(0.06, 0.095, 0.14, 0.97), UIKit.BORDER, 2)
	card.position = pos
	card.size = Vector2(w, h)
	add_child(card)

	var icon := TextureRect.new()
	icon.texture = load(String(upgrade["icon"]))
	icon.position = Vector2(14, (h - 48.0) * 0.5)
	icon.size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	card.add_child(icon)

	var name_label := UIKit.label(String(upgrade["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(74, 8)
	card.add_child(name_label)
	var level_label := UIKit.label("", 13, UIKit.GOLD)
	level_label.position = Vector2(w - 190.0, 10)
	level_label.size = Vector2(172, 18)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	card.add_child(level_label)
	var desc := UIKit.label(String(upgrade["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(74, 34)
	desc.size = Vector2(w - 270.0, 20)
	desc.clip_text = true
	card.add_child(desc)
	var effect := UIKit.label("", 12, UIKit.MINT)
	effect.position = Vector2(74, 56)
	effect.size = Vector2(w - 270.0, 20)
	card.add_child(effect)

	var buy := UIKit.button("강화", Vector2(112, 40))
	buy.position = Vector2(w - 126.0, h - 50.0)
	buy.add_theme_font_size_override("font_size", 16)
	buy.pressed.connect(_buy.bind(String(upgrade["id"])))
	card.add_child(buy)

	_cards[String(upgrade["id"])] = {
		"level": level_label, "effect": effect, "buy": buy, "upgrade": upgrade,
	}


func _buy(id: String) -> void:
	var result := Game.buy_altar_upgrade(id)
	if _message != null:
		_message.text = String(result.get("message", ""))
		_message.add_theme_color_override("font_color", UIKit.MINT if result.get("ok", false) else UIKit.CORAL)
	Audio.play("levelup" if result.get("ok", false) else "click", 1.1, -8.0)
	_refresh()


func _refresh() -> void:
	if _shards_label != null:
		_shards_label.text = "◈ 달빛 조각  %d" % Game.shards
	for id in _cards.keys():
		var entry: Dictionary = _cards[id]
		var upgrade: Dictionary = entry["upgrade"]
		var level := Game.altar_level(String(id))
		var cap := int(upgrade["max"])
		var level_label: Label = entry["level"]
		var effect: Label = entry["effect"]
		var buy: Button = entry["buy"]
		level_label.text = "Lv.%d / %d" % [level, cap]
		effect.text = AltarData.effect_text(upgrade, level)
		if level >= cap:
			buy.text = "MAX"
			buy.disabled = true
		else:
			var cost := AltarData.cost(String(id), level)
			buy.text = "◈ %d" % cost
			buy.disabled = Game.shards < cost
		buy.modulate = Color(1, 1, 1, 1) if not buy.disabled else Color(0.65, 0.65, 0.7, 1)
	if _message == null:
		_message = UIKit.label("", 12, UIKit.MUTED)
		_message.position = Vector2(0, 668) if not _portrait else Vector2(0, 1136)
		_message.size = Vector2(1280, 18) if not _portrait else Vector2(720, 18)
		_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_message)


func _go_back() -> void:
	Audio.play_click()
	Game.close_altar()


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
	var shot := "altar" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _test_altar() -> void:
	await get_tree().create_timer(0.3, true, false, true).timeout
	var errors: Array = []
	var old_altar: Dictionary = Game.altar_levels.duplicate(true)
	var old_shards := Game.shards
	Game.altar_levels.clear()
	Game.shards = 2000
	var before := Game.altar_bonuses()
	var result := Game.buy_altar_upgrade("vitality")
	if not result.get("ok", false) or Game.altar_level("vitality") != 1:
		errors.append("vitality purchase failed")
	if Game.altar_bonuses().get("max_hp", 0.0) <= before.get("max_hp", 0.0):
		errors.append("vitality bonus missing")
	result = Game.buy_altar_upgrade("companion")
	if not result.get("ok", false) or int(Game.altar_bonuses().get("companion", 0)) < 1:
		errors.append("companion unlock failed")
	var cost_before := Game.altar_cost("power")
	result = Game.buy_altar_upgrade("power")
	if not result.get("ok", false) or Game.altar_cost("power") <= cost_before:
		errors.append("altar cost did not scale")
	Game.altar_levels = old_altar
	Game.shards = old_shards
	Game.save_settings()
	if errors.is_empty():
		print("ALTAR TEST PASS vitality=%s companion=%s" % [
			AltarData.effect_text(AltarData.get_upgrade("vitality"), 1),
			AltarData.effect_text(AltarData.get_upgrade("companion"), 1),
		])
		print("TEST PASS")
	else:
		print("ALTAR TEST FAIL")
		for e in errors:
			print("  ", e)
		print("TEST FAIL")
	get_tree().quit()
