extends Control

## Reusable settings panel for the title and the pause menu.
## Lives above the screen it is opened from; works while the tree is paused.
## Three tabs keep display, controls and accessibility options readable on
## both desktop and portrait phones.

signal closed

const TABS := [
	{"id": "display", "label": "화면"},
	{"id": "controls", "label": "조작"},
	{"id": "access", "label": "접근성"},
	{"id": "account", "label": "계정"},
]

const PAGES := {
	"display": [
		{"type": "choice", "key": "quality", "name": "그래픽 품질",
			"desc": "프레임과 연출 효과의 균형을 선택합니다.",
			"options": [
				{"value": "low", "label": "낮음"},
				{"value": "balanced", "label": "보통"},
				{"value": "high", "label": "고품질"},
			]},
		{"type": "choice", "key": "window_mode", "name": "창 모드",
			"desc": "창·테두리 없음·전체 화면을 즉시 적용합니다. F11로도 전환됩니다.",
			"options": [
				{"value": "windowed", "label": "창"},
				{"value": "borderless", "label": "테두리 없음"},
				{"value": "fullscreen", "label": "전체 화면"},
			]},
		{"type": "choice", "key": "fps_limit", "name": "FPS 제한",
			"desc": "프레임 상한을 제한해 발열과 전력 사용을 줄입니다.",
			"options": [
				{"value": "60", "label": "60"},
				{"value": "120", "label": "120"},
				{"value": "144", "label": "144"},
				{"value": "unlimited", "label": "무제한"},
			]},
		{"type": "toggle", "key": "vsync", "name": "수직 동기화",
			"desc": "화면 찢어짐을 줄입니다. 입력 지연이 느껴지면 끄세요."},
		{"type": "toggle", "key": "bloom", "name": "블룸 (빛 번짐)",
			"desc": "밝은 빛과 달빛의 번짐 효과를 켜거나 끕니다."},
		{"type": "choice", "key": "hud_size", "name": "인게임 HUD 크기",
			"desc": "타이머·체력·스킬 UI를 확대하거나 줄입니다.",
			"options": [
				{"value": "small", "label": "작게"},
				{"value": "normal", "label": "보통"},
				{"value": "large", "label": "크게"},
			]},
	],
	"controls": [
		{"type": "toggle", "key": "haptics", "name": "진동 피드백",
			"desc": "스마트폰과 연결된 게임패드에 상황별 진동을 전달합니다."},
		{"type": "choice", "key": "haptic_strength", "name": "진동 세기",
			"desc": "피격·보스·궁극기 진동의 강도를 조절합니다.",
			"options": [
				{"value": "weak", "label": "약하게"},
				{"value": "normal", "label": "보통"},
				{"value": "strong", "label": "강하게"},
			]},
		{"type": "choice", "key": "joystick_side", "name": "조이스틱 위치",
			"desc": "왼손/오른손잡이에 맞춰 이동 버튼을 바꿉니다.",
			"options": [
				{"value": "left", "label": "왼쪽"},
				{"value": "right", "label": "오른쪽"},
			]},
		{"type": "choice", "key": "joystick_size", "name": "조이스틱 크기",
			"desc": "이동 조이스틱과 대시·궁극기 버튼 크기를 조절합니다.",
			"options": [
				{"value": "small", "label": "작게"},
				{"value": "normal", "label": "보통"},
				{"value": "large", "label": "크게"},
			]},
		{"type": "toggle", "key": "focus_pause", "name": "포커스 상실 시 일시정지",
			"desc": "다른 창으로 전환해도 전투가 계속되지 않도록 합니다."},
	],
	"access": [
		{"type": "choice", "key": "flash_intensity", "name": "화면 플래시",
			"desc": "폭발·보스 연출의 섬광 강도를 줄이거나 끕니다.",
			"options": [
				{"value": "off", "label": "끔"},
				{"value": "reduced", "label": "약하게"},
				{"value": "normal", "label": "보통"},
			]},
		{"type": "choice", "key": "motion_intensity", "name": "모션 강도",
			"desc": "화면 흔들림·충격 줌·속도선의 강도를 조절합니다.",
			"options": [
				{"value": "off", "label": "끔"},
				{"value": "reduced", "label": "약하게"},
				{"value": "normal", "label": "보통"},
			]},
		{"type": "choice", "key": "colorblind", "name": "색약 팔레트",
			"desc": "적 탄막의 산성/일반 색을 구분하기 쉬운 색으로 바꿉니다.",
			"options": [
				{"value": "off", "label": "기본"},
				{"value": "deuteranopia", "label": "녹색약"},
				{"value": "protanopia", "label": "적색약"},
				{"value": "tritanopia", "label": "청색약"},
			]},
		{"type": "toggle", "key": "high_contrast", "name": "고대비 적 탄막",
			"desc": "적 탄막에 흰색 외곽선과 더 밝은 궤적을 추가합니다."},
		{"type": "toggle", "key": "shake", "name": "화면 흔들림 사용",
			"desc": "모션 강도와 별개로 카메라 흔들림을 완전히 끕니다."},
		{"type": "toggle", "key": "damage_numbers", "name": "데미지 숫자",
			"desc": "적에게 들어간 피해 숫자를 표시합니다."},
	],
}

var _buttons := {}
var _choice_buttons := {}
var _tab_buttons := {}
var _close_button: Button
var _page_root: Control
var _account_status: Label
var _account_message: Label
var _account_buttons := {}
var _portrait := false
var _panel_w := 700.0
var _panel_h := 720.0
var _tab := "display"


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
	PlayGames.status_changed.connect(_on_play_games_status)
	PlayGames.sign_in_changed.connect(_on_play_games_sign_in)
	PlayGames.cloud_saved.connect(_on_play_games_cloud_saved)
	PlayGames.cloud_loaded.connect(_on_play_games_cloud_loaded)
	get_viewport().size_changed.connect(_on_viewport_resized)


func _on_viewport_resized() -> void:
	if _is_portrait() == _portrait:
		return
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	_choice_buttons.clear()
	_tab_buttons.clear()
	_portrait = _is_portrait()
	_build()
	_sync()


func _build() -> void:
	var vp := get_viewport_rect().size
	_panel_w = 680.0 if _portrait else 720.0
	_panel_h = 840.0 if _portrait else 720.0

	var dim := UIKit.dimmer(0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99),
		UIKit.GOLD.darkened(0.35), 3, 0)
	var stretch := get_viewport().get_final_transform().get_scale().x
	var panel_scale := maxf(1.0, 1.0 / maxf(0.01, stretch))
	var fit_scale := minf(vp.x / (_panel_w + 24.0), vp.y / (_panel_h + 24.0))
	panel_scale = minf(panel_scale, maxf(0.55, fit_scale))
	panel.scale = Vector2(panel_scale, panel_scale)
	panel.size = Vector2(_panel_w, _panel_h)
	panel.position = (vp - panel.size * panel_scale) * 0.5
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := UIKit.label("설정", 44 if _portrait else 42, UIKit.GOLD, 7)
	title.position = Vector2(28, 14)
	title.size = Vector2(_panel_w - 56, 54)
	panel.add_child(title)

	var sub := UIKit.label("화면 · 조작 · 접근성 · 계정", 14, UIKit.MUTED)
	sub.position = Vector2(30, 66 if _portrait else 62)
	sub.size = Vector2(_panel_w - 60, 24)
	panel.add_child(sub)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.32)
	line.position = Vector2(28, 94 if _portrait else 90)
	line.size = Vector2(_panel_w - 56, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(line)

	var tab_y := 106.0 if _portrait else 102.0
	var tab_w := 132.0 if _portrait else 138.0
	var gap := 8.0
	for i in TABS.size():
		var tab: Dictionary = TABS[i]
		var tid := String(tab["id"])
		var button := UIKit.button(String(tab["label"]), Vector2(tab_w, 38))
		button.position = Vector2(28.0 + float(i) * (tab_w + gap), tab_y)
		button.toggle_mode = true
		button.add_theme_font_size_override("font_size", 17 if _portrait else 16)
		button.pressed.connect(_switch_tab.bind(tid))
		panel.add_child(button)
		_tab_buttons[tid] = button

	_page_root = Control.new()
	_page_root.position = Vector2(0, 158 if _portrait else 150)
	_page_root.size = Vector2(_panel_w, _panel_h - 260.0)
	panel.add_child(_page_root)

	_close_button = UIKit.button("닫기", Vector2(180, 48))
	_close_button.position = Vector2((_panel_w - 180) * 0.5, _panel_h - 92.0)
	_close_button.add_theme_font_size_override("font_size", 20 if _portrait else 19)
	_close_button.add_theme_stylebox_override("focus",
		UIKit.style(Color(0, 0, 0, 0), UIKit.GOLD, 2, 0))
	_close_button.pressed.connect(close)
	panel.add_child(_close_button)

	var note := UIKit.label("설정은 자동으로 저장됩니다 · 게임패드 A 확인 / B 닫기",
		12, UIKit.MUTED)
	note.position = Vector2(0, _panel_h - 38.0)
	note.size = Vector2(_panel_w, 20)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(note)

	_build_page()


func _build_page() -> void:
	for child in _page_root.get_children():
		_page_root.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_choice_buttons.clear()
	_account_buttons.clear()
	if _tab == "account":
		_build_account_page()
		_update_tab_styles()
		return
	var rows: Array = PAGES.get(_tab, [])
	var row_h := 78.0 if _portrait else 72.0
	for i in rows.size():
		var row: Dictionary = rows[i]
		if String(row["type"]) == "choice":
			_make_choice_row(_page_root, row, float(i) * row_h)
		else:
			_make_toggle_row(_page_root, row, float(i) * row_h)
	_add_input_hint(_page_root, float(rows.size()) * row_h + 8.0)
	_update_tab_styles()
	_sync()


func _build_account_page() -> void:
	var status := UIKit.label(PlayGames.status_text(), 18, UIKit.CREAM)
	status.position = Vector2(30, 6)
	status.size = Vector2(_panel_w - 60, 34)
	_page_root.add_child(status)
	_account_status = status

	var intro := UIKit.label(
		"Android 전용입니다. 로그인하면 진행과 런이 자동 저장됩니다.",
		12, UIKit.MUTED)
	intro.position = Vector2(30, 42)
	intro.size = Vector2(_panel_w - 60, 24)
	_page_root.add_child(intro)

	var sign_in := UIKit.button("Google Play Games 로그인", Vector2(300, 46))
	sign_in.position = Vector2(30, 88)
	sign_in.add_theme_font_size_override("font_size", 16)
	sign_in.pressed.connect(_on_play_games_sign_in_pressed)
	_page_root.add_child(sign_in)
	_account_buttons["sign_in"] = sign_in

	var sync := UIKit.button("로컬 기록 동기화", Vector2(220, 46))
	sync.position = Vector2(342, 88)
	sync.add_theme_font_size_override("font_size", 15)
	sync.pressed.connect(_on_play_games_sync_pressed)
	_page_root.add_child(sync)
	_account_buttons["sync"] = sync

	var save := UIKit.button("클라우드 저장", Vector2(220, 46))
	save.position = Vector2(30, 146)
	save.add_theme_font_size_override("font_size", 15)
	save.pressed.connect(_on_play_games_save_pressed)
	_page_root.add_child(save)
	_account_buttons["save"] = save

	var load := UIKit.button("클라우드 불러오기", Vector2(220, 46))
	load.position = Vector2(262, 146)
	load.add_theme_font_size_override("font_size", 15)
	load.pressed.connect(_on_play_games_load_pressed)
	_page_root.add_child(load)
	_account_buttons["load"] = load

	var note := UIKit.label("자동 저장: 런 종료 · 앱 전환 · 변경 후", 12, UIKit.MUTED)
	note.position = Vector2(30, 204)
	note.size = Vector2(_panel_w - 60, 24)
	_page_root.add_child(note)

	var switch_note := UIKit.label("계정 전환: Play Games 앱 → 프로필 → 계정 선택", 12, UIKit.MUTED)
	switch_note.position = Vector2(30, 234)
	switch_note.size = Vector2(_panel_w - 60, 24)
	_page_root.add_child(switch_note)

	var switch_app := UIKit.button("Play Games 앱 열기", Vector2(220, 40))
	switch_app.position = Vector2(30, 280)
	switch_app.add_theme_font_size_override("font_size", 15)
	switch_app.pressed.connect(_on_play_games_open_app_pressed)
	_page_root.add_child(switch_app)
	_account_buttons["open_app"] = switch_app

	var refresh := UIKit.button("로그인 상태 확인", Vector2(200, 40))
	refresh.position = Vector2(262, 280)
	refresh.add_theme_font_size_override("font_size", 15)
	refresh.pressed.connect(_on_play_games_refresh_pressed)
	_page_root.add_child(refresh)
	_account_buttons["refresh"] = refresh

	_account_message = UIKit.label("", 13, UIKit.MINT)
	_account_message.position = Vector2(30, 332)
	_account_message.size = Vector2(_panel_w - 60, 72)
	_account_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_page_root.add_child(_account_message)
	_sync_account()


func _sync_account() -> void:
	if _account_status == null:
		return
	_account_status.text = PlayGames.status_text()
	var signed := PlayGames.is_signed_in()
	var sign_in: Button = _account_buttons.get("sign_in")
	if sign_in != null:
		sign_in.disabled = not PlayGames.is_available() or signed
		sign_in.text = "로그인됨" if signed else "Google Play Games 로그인"
	for key in ["sync", "save"]:
		var button: Button = _account_buttons.get(key)
		if button != null:
			button.disabled = not signed
	var load: Button = _account_buttons.get("load")
	if load != null:
		load.disabled = not signed or Game.running
	var open_app: Button = _account_buttons.get("open_app")
	if open_app != null:
		open_app.disabled = not PlayGames.is_available()
	var refresh: Button = _account_buttons.get("refresh")
	if refresh != null:
		refresh.disabled = not PlayGames.is_available()
	if not signed and not PlayGames.last_error.is_empty() and _account_message != null:
		_account_message.text = PlayGames.last_error
		_account_message.add_theme_color_override("font_color", UIKit.CORAL)
	elif signed and _account_message != null and _account_message.text.begins_with("로그인에 실패"):
		_account_message.text = ""
		_account_message.add_theme_color_override("font_color", UIKit.MINT)


func _on_play_games_status() -> void:
	if _tab == "account":
		_sync_account()


func _on_play_games_sign_in(signed: bool, _name: String) -> void:
	if _tab == "account":
		_sync_account()
		if not signed and not PlayGames.last_error.is_empty() and _account_message != null:
			_account_message.text = PlayGames.last_error
			_account_message.add_theme_color_override("font_color", UIKit.CORAL)
		elif signed and _account_message != null:
			_account_message.text = "로그인되었습니다. 클라우드 저장을 사용할 수 있습니다."
			_account_message.add_theme_color_override("font_color", UIKit.MINT)


func _on_play_games_cloud_saved(ok: bool, message: String) -> void:
	if _account_message != null:
		_account_message.text = message
		_account_message.add_theme_color_override("font_color", UIKit.MINT if ok else UIKit.CORAL)


func _on_play_games_cloud_loaded(ok: bool, message: String) -> void:
	if _account_message != null:
		_account_message.text = message
		_account_message.add_theme_color_override("font_color", UIKit.MINT if ok else UIKit.CORAL)


func _on_play_games_sign_in_pressed() -> void:
	PlayGames.sign_in()
	Audio.play_click()


func _on_play_games_open_app_pressed() -> void:
	var opened := PlayGames.open_play_games_app()
	if _account_message != null:
		_account_message.text = "Play Games 앱에서 프로필을 바꾼 뒤 DALBEAR를 다시 실행하세요." if opened \
			else "Play Games 앱을 열지 못했습니다. 기기의 Play Games 앱에서 계정을 전환해 주세요."
		_account_message.add_theme_color_override("font_color", UIKit.MINT if opened else UIKit.CORAL)
	Audio.play_click()


func _on_play_games_refresh_pressed() -> void:
	PlayGames.refresh_account()
	if _account_message != null:
		_account_message.text = "로그인 상태를 다시 확인하는 중입니다."
		_account_message.add_theme_color_override("font_color", UIKit.MUTED)
	Audio.play_click()


func _on_play_games_sync_pressed() -> void:
	PlayGames.sync_pending()
	Audio.play_click()


func _on_play_games_save_pressed() -> void:
	PlayGames.save_cloud()
	Audio.play_click()


func _on_play_games_load_pressed() -> void:
	PlayGames.load_cloud()
	Audio.play_click()


func _add_input_hint(parent: Control, y: float) -> void:
	var text := "키보드: 방향키 · ENTER · ESC   |   게임패드: 스틱/D-PAD · A · B · START"
	var hint := UIKit.label(text, 12, UIKit.MUTED)
	hint.position = Vector2(30, y)
	hint.size = Vector2(_panel_w - 60, 20)
	parent.add_child(hint)


func _make_choice_row(parent: Control, row: Dictionary, y: float) -> void:
	var key := String(row["key"])
	var name_label := UIKit.label(String(row["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(30, y)
	name_label.size = Vector2(300, 26)
	parent.add_child(name_label)

	var desc := UIKit.label(String(row["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(30, y + 27)
	desc.size = Vector2(300, 36)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(desc)

	var options: Array = row["options"]
	var area_w := 300.0 if _portrait else 330.0
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
		button.add_theme_font_size_override("font_size", 14 if _portrait else 13)
		button.pressed.connect(_on_choice.bind(key, value))
		parent.add_child(button)
		_choice_buttons[key][value] = button


func _make_toggle_row(parent: Control, row: Dictionary, y: float) -> void:
	var key := String(row["key"])
	var name_label := UIKit.label(String(row["name"]), 20 if _portrait else 19, UIKit.CREAM)
	name_label.position = Vector2(30, y)
	name_label.size = Vector2(360, 26)
	parent.add_child(name_label)

	var desc := UIKit.label(String(row["desc"]), 12, UIKit.MUTED)
	desc.position = Vector2(30, y + 27)
	desc.size = Vector2(_panel_w - 190, 32)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(desc)

	var toggle := UIKit.button("", Vector2(104, 40))
	toggle.position = Vector2(_panel_w - 132, y - 2)
	toggle.toggle_mode = true
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.add_theme_font_size_override("font_size", 16)
	toggle.button_pressed = Settings.get_option(key)
	toggle.text = "켜짐" if toggle.button_pressed else "꺼짐"
	toggle.toggled.connect(_on_toggle.bind(key))
	parent.add_child(toggle)
	_buttons[key] = toggle


func _update_tab_styles() -> void:
	for tid in _tab_buttons.keys():
		var button: Button = _tab_buttons[tid]
		var selected: bool = String(tid) == _tab
		button.set_pressed_no_signal(selected)
		UIKit.apply_tab_style(button, selected)


func _switch_tab(tid: String) -> void:
	if tid == _tab:
		return
	_tab = tid
	_build_page()
	Audio.play_click()


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
	if _tab == "account":
		_sync_account()
		return
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
	var b: Button = _buttons.get(key)
	if b != null:
		b.text = "켜짐" if pressed else "꺼짐"
	Audio.play("click", 1.2, -8.0)


func _on_choice(key: String, value: String) -> void:
	Settings.set_choice(key, value)
	_sync()
	Audio.play("click", 1.2, -8.0)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACKSPACE:
			close()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_B:
			close()
			get_viewport().set_input_as_handled()
