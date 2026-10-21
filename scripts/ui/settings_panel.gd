extends Control

## Reusable settings panel for the title and the pause menu.
## Lives above the screen it is opened from; works while the tree is paused.

signal closed

const PANEL_SIZE := Vector2(560, 460)
const PANEL_POS := Vector2(360, 130)

const ROWS := [
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

var _buttons := {}
var _close_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 200
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build()


func _build() -> void:
	var dim := UIKit.dimmer(0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99),
		UIKit.GOLD.darkened(0.35), 3, 0)
	panel.position = PANEL_POS
	panel.size = PANEL_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := UIKit.label("설정", 44, UIKit.GOLD, 7)
	title.position = Vector2(32, 16)
	title.size = Vector2(PANEL_SIZE.x - 64, 54)
	panel.add_child(title)

	var sub := UIKit.label("달빛 연출과 전투 피드백을 조절합니다", 15, UIKit.MUTED)
	sub.position = Vector2(34, 72)
	sub.size = Vector2(PANEL_SIZE.x - 68, 24)
	panel.add_child(sub)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.32)
	line.position = Vector2(32, 106)
	line.size = Vector2(PANEL_SIZE.x - 64, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(line)

	for i in ROWS.size():
		var row: Dictionary = ROWS[i]
		var key := String(row["key"])
		var y := 122.0 + i * 68.0

		var name_label := UIKit.label(String(row["name"]), 20, UIKit.CREAM)
		name_label.position = Vector2(34, y)
		name_label.size = Vector2(340, 26)
		panel.add_child(name_label)

		var desc := UIKit.label(String(row["desc"]), 13, UIKit.MUTED)
		desc.position = Vector2(34, y + 27)
		desc.size = Vector2(360, 22)
		panel.add_child(desc)

		var toggle := UIKit.button("", Vector2(104, 40))
		toggle.position = Vector2(PANEL_SIZE.x - 136, y - 4)
		toggle.toggle_mode = true
		toggle.focus_mode = Control.FOCUS_ALL
		toggle.add_theme_font_size_override("font_size", 16)
		toggle.button_pressed = Settings.get_option(key)
		toggle.text = "켜짐" if toggle.button_pressed else "꺼짐"
		toggle.toggled.connect(_on_toggle.bind(key))
		panel.add_child(toggle)
		_buttons[key] = toggle

	var line2 := ColorRect.new()
	line2.color = Color(0.85, 0.68, 0.35, 0.22)
	line2.position = Vector2(32, 336)
	line2.size = Vector2(PANEL_SIZE.x - 64, 1)
	line2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(line2)

	_close_button = UIKit.button("닫기", Vector2(180, 46))
	_close_button.position = Vector2((PANEL_SIZE.x - 180) * 0.5, 356)
	_close_button.add_theme_font_size_override("font_size", 19)
	_close_button.add_theme_stylebox_override("focus",
		UIKit.style(Color(0, 0, 0, 0), UIKit.GOLD, 2, 0))
	_close_button.pressed.connect(close)
	panel.add_child(_close_button)

	var note := UIKit.label("설정은 자동으로 저장됩니다", 13, UIKit.MUTED)
	note.position = Vector2(0, 414)
	note.size = Vector2(PANEL_SIZE.x, 20)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(note)

	var esc_hint := UIKit.label("ESC 닫기", 12, Color(0.46, 0.54, 0.62))
	esc_hint.position = Vector2(PANEL_SIZE.x - 116, 20)
	esc_hint.size = Vector2(92, 20)
	esc_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(esc_hint)


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


func _on_toggle(pressed: bool, key: String) -> void:
	Settings.set_option(key, pressed)
	var b: Button = _buttons[key]
	b.text = "켜짐" if pressed else "꺼짐"
	Audio.play("click", 1.2, -8.0)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
