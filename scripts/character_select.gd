extends Control

## Friend roster: pick one of five Dalbear friends and preview their trait/signature gear.

const CARD_SIZE := Vector2(222, 438)
const CARD_GAP := 16.0
const CARD_Y := 150.0

var _args: PackedStringArray
var _cards := {}
var _message: Label
var _portrait := false
var _reloading := false


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
	_refresh_cards()
	if "--capture-characters" in _args:
		_capture()
	if "--test-characters" in _args:
		_test_characters.call_deferred()


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

	var over := UIKit.label("FRIENDS OF DALBEAR  ·  DALBEAR.COM", 13, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("달베어의 친구들", 40 if _portrait else 44, UIKit.GOLD, 7)
	title.position = Vector2(24, 38) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("다섯 명의 친구, 다섯 가지 전투 방식. 친구마다 전용 장비 세트가 함께합니다.", 14 if _portrait else 15, UIKit.CREAM)
	sub.position = Vector2(26, 94) if _portrait else Vector2(56, 96)
	add_child(sub)

	var back := UIKit.button("← 돌아가기", Vector2(164, 42))
	back.position = Vector2(540, 22) if _portrait else Vector2(1074, 30)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_go_back)
	add_child(back)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.28)
	line.position = Vector2(26, 130) if _portrait else Vector2(36, 132)
	line.size = Vector2(668, 1) if _portrait else Vector2(1208, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

	if _portrait:
		# 3 columns x 2 rows at full card size; the last row holds two centered
		# cards so the roster does not look left-heavy.
		for i in CharacterData.ORDER.size():
			var id: String = CharacterData.ORDER[i]
			var x := 15.0 + float(i % 3) * 236.0
			var y := 150.0
			if i >= 3:
				x = 133.0 + float(i - 3) * 236.0
				y = 602.0
			_make_card(id, Vector2(x, y))
	else:
		var start_x := (1280.0 - (CARD_SIZE.x * 5.0 + CARD_GAP * 4.0)) * 0.5
		for i in CharacterData.ORDER.size():
			var id: String = CharacterData.ORDER[i]
			_make_card(id, Vector2(start_x + i * (CARD_SIZE.x + CARD_GAP), CARD_Y))

	var hint := UIKit.label("선택한 친구의 전용 장비는 인벤토리에 추가되며, 더 강한 장비가 없으면 자동 장착됩니다.",
		11, UIKit.MUTED)
	hint.position = Vector2(0, 1080) if _portrait else Vector2(0, 606)
	hint.size = Vector2(720, 18) if _portrait else Vector2(1280, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)
	hint = UIKit.label("전용 장비는 해당 친구만 장착할 수 있습니다 · ESC 돌아가기", 10, Color(0.47, 0.56, 0.64))
	hint.position = Vector2(0, 1106) if _portrait else Vector2(0, 630)
	hint.size = Vector2(720, 16) if _portrait else Vector2(1280, 16)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)

	_message = UIKit.label("", 13, UIKit.MINT)
	_message.position = Vector2(26, 1200) if _portrait else Vector2(56, 668)
	_message.size = Vector2(668, 20) if _portrait else Vector2(1168, 20)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_message)


func _make_card(id: String, pos: Vector2) -> void:
	var info := CharacterData.get_character(id)
	var accent: Color = info["color"]
	var card := UIKit.panel(Color(0.045, 0.07, 0.105, 0.96), accent.darkened(0.25), 2)
	card.position = pos
	card.size = CARD_SIZE
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(card)

	var stripe := ColorRect.new()
	stripe.color = accent
	stripe.position = Vector2(2, 2)
	stripe.size = Vector2(CARD_SIZE.x - 4, 4)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(stripe)

	var name_label := UIKit.label(String(info["name"]), 22, accent, 3)
	name_label.position = Vector2(16, 10)
	card.add_child(name_label)
	var title_label := UIKit.label(String(info["title"]), 11, UIKit.CREAM)
	title_label.position = Vector2(16, 34)
	card.add_child(title_label)
	var tag_label := UIKit.label(String(info["tag"]), 9, accent)
	tag_label.position = Vector2(16, 49)
	card.add_child(tag_label)

	var atlas := AtlasTexture.new()
	atlas.atlas = load(String(info["sheet"]))
	atlas.region = Rect2(0, 0, 32, 36)
	var portrait := TextureRect.new()
	portrait.texture = atlas
	portrait.position = Vector2(51, 66)
	portrait.size = Vector2(120, 135)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_SCALE
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(portrait)

	var trait_label := UIKit.label("특성 · %s" % String(info["trait_name"]), 11, UIKit.GOLD)
	trait_label.position = Vector2(16, 208)
	card.add_child(trait_label)
	var trait_desc := UIKit.label(_wrap_text(String(info["trait_desc"]), 18), 10, Color(0.82, 0.86, 0.9))
	trait_desc.position = Vector2(16, 226)
	trait_desc.size = Vector2(190, 48)
	trait_desc.custom_minimum_size = Vector2(190, 48)
	trait_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_desc.clip_text = true
	trait_desc.add_theme_constant_override("line_spacing", 2)
	card.add_child(trait_desc)

	var stats := UIKit.label("HP %d  ·  피해 ×%.2f  ·  대시 %.1fs" % [
		int(info["max_hp"]), float(info["damage"]), float(info["dash_cd"]),
	], 9, UIKit.MUTED)
	stats.position = Vector2(16, 278)
	card.add_child(stats)

	var sig_label := UIKit.label("전용 장비", 10, UIKit.GOLD)
	sig_label.position = Vector2(16, 300)
	card.add_child(sig_label)
	var names: Array = []
	for template in EquipmentData.signature_set(id):
		names.append("· " + String(template.get("name", "")))
	var sig_text := "\n".join(names)
	var sig_names := UIKit.label(sig_text, 9, accent)
	sig_names.position = Vector2(16, 316)
	sig_names.size = Vector2(190, 54)
	sig_names.custom_minimum_size = Vector2(190, 54)
	sig_names.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sig_names.clip_text = true
	sig_names.add_theme_constant_override("line_spacing", 1)
	card.add_child(sig_names)

	var btn := UIKit.button("이 친구 선택", Vector2(164, 30))
	btn.position = Vector2(29, 388)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(_select_character.bind(id))
	card.add_child(btn)

	card.gui_input.connect(_on_card_input.bind(id))
	card.mouse_entered.connect(_on_card_hover.bind(card, id, true))
	card.mouse_exited.connect(_on_card_hover.bind(card, id, false))
	_cards[id] = {"root": card, "button": btn, "accent": accent, "stripe": stripe}


func _refresh_cards() -> void:
	for id in _cards:
		var refs: Dictionary = _cards[id]
		var card: Panel = refs["root"]
		var btn: Button = refs["button"]
		var accent: Color = refs["accent"]
		var selected: bool = String(id) == Game.selected_character
		card.add_theme_stylebox_override("panel", UIKit.style(
			Color(0.085, 0.12, 0.17, 0.98) if selected else Color(0.045, 0.07, 0.105, 0.96),
			UIKit.GOLD if selected else accent.darkened(0.25), 3 if selected else 2, 0))
		btn.text = "선택됨" if selected else "이 친구 선택"
		btn.disabled = selected
		btn.modulate.a = 1.0 if not selected else 0.65


func _on_card_hover(card: Panel, id: String, hovered: bool) -> void:
	if not is_instance_valid(card):
		return
	if id == Game.selected_character:
		return
	var accent := CharacterData.color(id)
	card.add_theme_stylebox_override("panel", UIKit.style(
		Color(0.075, 0.11, 0.155, 0.98) if hovered else Color(0.045, 0.07, 0.105, 0.96),
		accent if hovered else accent.darkened(0.25), 2, 0))


func _on_card_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_character(id)


func _select_character(id: String) -> void:
	if id == Game.selected_character:
		return
	var result := Game.select_character(id)
	Audio.play_click()
	if _message != null:
		_message.text = String(result.get("message", ""))
		_message.add_theme_color_override("font_color", UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_refresh_cards()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_go_back()
			get_viewport().set_input_as_handled()
		else:
			var idx := -1
			match event.keycode:
				KEY_1:
					idx = 0
				KEY_2:
					idx = 1
				KEY_3:
					idx = 2
				KEY_4:
					idx = 3
				KEY_5:
					idx = 4
			if idx >= 0 and idx < CharacterData.ORDER.size():
				_select_character(CharacterData.ORDER[idx])
				get_viewport().set_input_as_handled()


func _go_back() -> void:
	Audio.play_click()
	Game.close_characters()


func _wrap_text(text: String, max_chars: int) -> String:
	var words := text.split(" ")
	var lines: Array = []
	var line := ""
	for word in words:
		var candidate := word if line == "" else line + " " + word
		if line != "" and candidate.length() > max_chars:
			lines.append(line)
			line = word
		else:
			line = candidate
	if line != "":
		lines.append(line)
	return "\n".join(lines)


func _test_characters() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	var errors: Array = []
	for id in CharacterData.ORDER:
		var result := Game.select_character(id)
		Game.ensure_character_signature(id, true)
		if id != Game.selected_character:
			errors.append("select failed for %s: %s" % [id, result])
			continue
		for template in EquipmentData.signature_set(id):
			var item := Game.item_by_sig_id(String(template.get("sig_id", "")))
			if item.is_empty():
				errors.append("missing signature %s" % template.get("sig_id", ""))
			elif EquipmentData.item_character(item) != id:
				errors.append("wrong affinity %s" % template.get("sig_id", ""))
		var equipped_signatures := 0
		for slot in EquipmentData.SLOT_ORDER:
			var item := Game.equipped_item(slot)
			if item.is_empty():
				continue
			var owner := EquipmentData.item_character(item)
			if owner != "" and owner != id:
				errors.append("%s has foreign signature in %s" % [id, slot])
			if owner == id:
				equipped_signatures += 1
		if equipped_signatures <= 0:
			errors.append("%s has no signature equipped" % id)
		if Game.equipped.size() < 11:
			errors.append("%s left empty slots: %d" % [id, Game.equipped.size()])
		var bonuses := Game.equipment_bonuses()
		if float(bonuses.get("damage_pct", 0.0)) <= 0.0:
			errors.append("%s gear bonuses missing" % id)
	Game.save_settings()
	Game.load_record()
	if Game.selected_character != "shade":
		errors.append("selected character did not persist: %s" % Game.selected_character)
	var dal_sig := Game.item_by_sig_id("dal_blade")
	if not dal_sig.is_empty():
		var blocked := Game.equip_item(String(dal_sig.get("uid", "")), "main")
		if bool(blocked.get("ok", false)):
			errors.append("foreign signature was equippable")
		var broken := Game.dismantle_item(String(dal_sig.get("uid", "")))
		if bool(broken.get("ok", false)):
			errors.append("signature gear was dismantlable")
	if errors.is_empty():
		print("CHARACTER TEST OK selected=", Game.selected_character,
			" inventory=", Game.inventory.size(), " equipped=", Game.equipped.size())
	else:
		for error in errors:
			push_error("CHARACTER TEST: " + String(error))
		print("CHARACTER TEST FAILED: ", errors)
	get_tree().quit()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "characters" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()
