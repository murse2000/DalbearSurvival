extends Control

## Reusable settings panel for the title and the pause menu.
## Lives above the screen it is opened from; works while the tree is paused.
## Rebuilds itself for landscape / portrait so phones get readable controls.

signal closed

const TOGGLE_ROWS := [
	{
		"key": "bloom",
		"name": "블룸 (빛 번짐)",
		"desc": "폭발과 달빛의 빛 번짐 연출을 켜거나 끕니다.",
	},
	{
		"key": "shake",
		"name": "화면 흔들림",
		"desc": "피격과 폭발 시 카메라 흔들림을 켜거나 끕니다.",
	},
	{
		"key": "damage_numbers",
		"name": "데미지 숫자",
		"desc": "적 위에 뜨는 피해량 숫자를 표시합니다.",
	},
]

const CHOICE_ROWS := [
	{
		"key": "quality",
		"name": "그래픽 프리셋",
		"desc": "연출 밀도와 전투 효과량을 조절합니다.",
		"options": [
			{"value": "low", "label": "절전"},
			{"value": "balanced", "label": "균형"},
			{"value": "high", "label": "고품질"},
		],
	},
	{
		"key": "hud_size",
		"name": "전투 HUD 크기",
		"desc": "타이머·체력·스킬 UI를 확대하거나 줄입니다.",
		"options": [
			{"value": "small", "label": "작게"},
			{"value": "normal", "label": "보통"},
			{"value": "large", "label": "크게"},
		],
	},
	{
		"key": "joystick_side",
		"name": "조이스틱 위치",
		"desc": "왼손/오른손에 맞춰 이동과 버튼을 바꿉니다.",
		"options": [
			{"value": "left", "label": "왼손"},
			{"value": "right", "label": "오른손"},
		],
	},
	{
		"key": "joystick_size",
		"name": "조이스틱 크기",
		"desc": "이동·대시·궁극기 버튼 크기를 조절합니다.",
		"options": [
			{"value": "small", "label": "작게"},
			{"value": "normal", "label": "보통"},
			{"value": "large", "label": "크게"},
		],
	},
]

var _buttons := {}
var _choice_buttons := {}
var _close_button: Button
var _portrait := false
var _panel_w := 640.0
var _panel_h := 690.0


func _is_portrait() -> bool:
	var size := get_viewport_rect().size
	return size.y > size.x


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 200
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_portrait = _is_portrait()
	_build()
	get_viewport().size_changed.connect(_on_viewport_resized)


func _on_viewport_resized() -> void:
	if _is_portrait() == _portrait:
		return
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	_choice_buttons.clear()
	_portrait = _is_portrait()
	_build()
	_sync()


func _build() -> void:
	var vp := get_viewport_rect().size
	_panel_w = 660.0 if _portrait else 640.0
	_panel_h = 800.0 if _portrait else 690.0

	var dim := UIKit.dimmer(0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99),
		UIKit.GOLD.darkened(0.35), 3, 0)
	# The project may scale 2D UI down on phones (e.g. 1280 logical width on a
	# 720px screen). Counter-scale the panel so its physical size stays usable.
	var stretch := get_viewport().get_final_transform().get_scale().x
	var panel_scale := maxf(1.0, 1.0 / maxf(0.01, stretch))
	var fit_scale := minf(vp.x / (_panel_w + 24.0), vp.y / (_panel_h + 24.0))
	panel_scale = minf(panel_scale, maxf(0.55, fit_scale))
	panel.scale = Vector2(panel_scale, panel_scale)
	panel.size = Vector2(_panel_w, _panel_h)
	panel.position = (vp - panel.size * panel_scale) * 0.5
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title_size := 46 if _portrait else 42
	var title := UIKit.label("설정", title_size, UIKit.GOLD, 7)
	title.position = Vector2(28, 16)
	title.size = Vector2(_panel_w - 56, 56)
	panel.add_child(title)

	var sub := UIKit.label("그래픽 · 조작 · 화면 크기를 기기에 맞게 조절합니다",
		15 if _portrait else 14, UIKit.MUTED)
	sub.position = Vector2(30, 70 if _portrait else 66)
	sub.size = Vector2(_panel_w - 60, 24)
	panel.add_child(sub)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.32)
	line.position = Vector2(28, 100 if _portrait else 94)
	line.size = Vector2(_panel_w - 56, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(line)

	var row_h := 76.0 if _portrait else 64.0
	var start_y := 116.0 if _portrait else 108.0
	for i in CHOICE_ROWS.size():
		_make_choice_row(panel, CHOICE_ROWS[i], start_y + i * row_h)

	var sep_y := start_y + CHOICE_ROWS.size() * row_h + 4.0
	var sep := ColorRect.new()
	sep.color = Color(0.85, 0.68, 0.35, 0.22)
	sep.position = Vector2(28, sep_y)
	sep.size = Vector2(_panel_w - 56, 1)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(sep)

	var toggle_y := sep_y + 12.0
	for i in TOGGLE_ROWS.size():
		_make_toggle_row(panel, TOGGLE_ROWS[i], toggle_y + i * row_h)

	var close_y := toggle_y + TOGGLE_ROWS.size() * row_h + 6.0
	_close_button = UIKit.button("닫기", Vector2(180, 48))
	_close_button.position = Vector2((_panel_w - 180) * 0.5, close_y)
	_close_button.add_theme_font_size_override("font_size", 20 if _portrait else 19)
	_close_button.add_theme_stylebox_override("focus",
		UIKit.style(Color(0, 0, 0, 0), UIKit.GOLD, 2, 0))
	_close_button.pressed.connect(close)
	panel.add_child(_close_button)

	var note := UIKit.label("설정은 자동으로 저장됩니다", 12, UIKit.MUTED)
	note.position = Vector2(0, close_y + 58.0)
	note.size = Vector2(_panel_w, 20)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(note)

	var esc_hint := UIKit.label("ESC 닫기", 12, Color(0.46, 0.54, 0.62))
	esc_hint.position = Vector2(_panel_w - 110, 20)
	esc_hint.size = Vector2(84, 20)
	esc_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(esc_hint)


func _make_choice_row(panel: Panel, row: Dictionary, y: float) -> void:
	var key := String(row["key"])
	var name_label := UIKit.label(String(row["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(30, y)
	name_label.size = Vector2(300, 26)
	panel.add_child(name_label)

	var desc := UIKit.label(String(row["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(30, y + 27)
	desc.size = Vector2(300, 22)
	panel.add_child(desc)

	var options: Array = row["options"]
	var area_w := 300.0 if _portrait else 270.0
	var gap := 6.0
	var bw := (area_w - gap * float(options.size() - 1)) / float(options.size())
	var bx := _panel_w - 28.0 - area_w
	_choice_buttons[key] = {}
	for i in options.size():
		var opt: Dictionary = options[i]
		var value := String(opt["value"])
		var button := UIKit.button(String(opt["label"]), Vector2(bw, 40))
		button.position = Vector2(bx + float(i) * (bw + gap), y - 2)
		button.toggle_mode = true
		button.add_theme_font_size_override("font_size", 15 if _portrait else 14)
		button.pressed.connect(_on_choice.bind(key, value))
		panel.add_child(button)
		_choice_buttons[key][value] = button


func _make_toggle_row(panel: Panel, row: Dictionary, y: float) -> void:
	var key := String(row["key"])
	var name_label := UIKit.label(String(row["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(30, y)
	name_label.size = Vector2(360, 26)
	panel.add_child(name_label)

	var desc := UIKit.label(String(row["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(30, y + 27)
	desc.size = Vector2(_panel_w - 190, 22)
	panel.add_child(desc)

	var toggle := UIKit.button("", Vector2(104, 40))
	toggle.position = Vector2(_panel_w - 132, y - 2)
	toggle.toggle_mode = true
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.add_theme_font_size_override("font_size", 16)
	toggle.button_pressed = Settings.get_option(key)
	toggle.text = "켜짐" if toggle.button_pressed else "꺼짐"
	toggle.toggled.connect(_on_toggle.bind(key))
	panel.add_child(toggle)
	_buttons[key] = toggle


func open() -> void:
	_sync()
	visible = true
	Audio.play_click()
	if _close_button != null:
		_close_button.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	if _close_button != null:
		_close_button.release_focus()
	closed.emit()


func _sync() -> void:
	for key in _buttons.keys():
		var b: Button = _buttons[key]
		var on := Settings.get_option(String(key))
		b.set_pressed_no_signal(on)
		b.text = "켜짐" if on else "꺼짐"
	for key in _choice_buttons.keys():
		var value := Settings.get_choice(String(key))
		var row: Dictionary = _choice_buttons[key]
		for option_value in row.keys():
			var b: Button = row[option_value]
			b.set_pressed_no_signal(String(option_value) == value)


func _on_toggle(pressed: bool, key: String) -> void:
	Settings.set_option(key, pressed)
	var b: Button = _buttons[key]
	b.text = "켜짐" if pressed else "꺼짐"
	Audio.play("click", 1.2, -8.0)


func _on_choice(key: String, value: String) -> void:
	Settings.set_choice(key, value)
	_sync()
	Audio.play("click", 1.2, -8.0)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
