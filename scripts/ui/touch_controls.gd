extends Control

## On-screen joystick, dash / ultimate buttons and pause for touch devices.

var _joy_c := Vector2(150, 548)
var _joy_r := 78.0
var _joy_k := 32.0
var _dash_c := Vector2(1138, 520)
var _dash_r := 52.0
var _ult_c := Vector2(1000, 594)
var _ult_r := 46.0
var _pause_c := Vector2(1218, 146)
var _pause_r := 22.0
var _design := Vector2(1280, 720)
var _portrait := false
var _layout_ready := false

var player
var overlay
var active := false
var move_vector := Vector2.ZERO

var _font: Font
var _move_index := -1
var _dash_index := -1
var _ult_index := -1
var _mouse_move := false
var _mouse_dash := false
var _mouse_ult := false
var _dash_requested := false
var _ult_requested := false
var _dash_down := false
var _ult_down := false
var _knob_pos := _joy_c
var _joy_origin := _joy_c
var _use_touch_events := false
var _ui_scale := 1.0
var _ui_offset := Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = load("res://assets/fonts/Galmuri11.ttf")
	if _font == null:
		_font = ThemeDB.fallback_font
	_use_touch_events = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	visible = false


func bind(player_ref: Node, overlay_ref: Node) -> void:
	player = player_ref
	overlay = overlay_ref


func set_active(value: bool) -> void:
	active = value
	visible = false
	if not active:
		_reset()


func consume_dash() -> bool:
	var value := _dash_requested
	_dash_requested = false
	return value


func consume_ultimate() -> bool:
	var value := _ult_requested
	_ult_requested = false
	return value


func _process(_delta: float) -> void:
	if not active:
		visible = false
		return
	var vp := get_viewport_rect().size
	_apply_layout(vp)
	_ui_scale = minf(vp.x / _design.x, vp.y / _design.y)
	_ui_offset = (vp - _design * _ui_scale) * 0.5
	var blocking: bool = overlay != null and overlay.has_method("is_blocking") and overlay.is_blocking()
	var should_show: bool = Game.running and not get_tree().paused and not blocking
	if should_show != visible:
		visible = should_show
		if not should_show:
			_reset()
	if visible:
		queue_redraw()


func _apply_layout(vp: Vector2) -> void:
	var portrait := vp.y > vp.x
	if portrait:
		# Fill the whole portrait screen: joystick bottom-left, actions
		# bottom-right, pause top-right. The design height follows the device
		# aspect so nothing floats in a letterboxed middle band.
		_design = Vector2(720.0, 720.0 * vp.y / maxf(1.0, vp.x))
		_joy_c = Vector2(112, _design.y - 160)
		_joy_r = 96.0
		_joy_k = 40.0
		_dash_c = Vector2(_design.x - 154, _design.y - 222)
		_dash_r = 62.0
		_ult_c = Vector2(_design.x - 292, _design.y - 230)
		_ult_r = 54.0
		_pause_c = Vector2(_design.x - 62, 122)
		_pause_r = 26.0
	else:
		_design = Vector2(1280, 720)
		_joy_c = Vector2(150, 548)
		_joy_r = 78.0
		_joy_k = 32.0
		_dash_c = Vector2(1138, 520)
		_dash_r = 52.0
		_ult_c = Vector2(1000, 594)
		_ult_r = 46.0
		_pause_c = Vector2(1218, 146)
		_pause_r = 22.0
	if not _layout_ready or portrait != _portrait:
		_layout_ready = true
		_portrait = portrait
		_reset()


func _reset() -> void:
	_move_index = -1
	_dash_index = -1
	_ult_index = -1
	_mouse_move = false
	_mouse_dash = false
	_mouse_ult = false
	_dash_down = false
	_ult_down = false
	move_vector = Vector2.ZERO
	_knob_pos = _joy_c
	_joy_origin = _joy_c
	_dash_requested = false
	_ult_requested = false


func _input(event: InputEvent) -> void:
	if not active or not visible:
		return
	if _use_touch_events:
		if event is InputEventScreenTouch:
			_handle_screen_touch(event)
		elif event is InputEventScreenDrag:
			if event.index == _move_index:
				_update_move(_to_design(event.position))
				queue_redraw()
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _mouse_move:
		_update_move(_to_design(event.position))
		queue_redraw()


func _to_design(pos: Vector2) -> Vector2:
	if _ui_scale <= 0.0001:
		return pos
	return (pos - _ui_offset) / _ui_scale


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	var pos := _to_design(event.position)
	if event.pressed:
		if _hit(pos, _dash_c, _dash_r + 18.0):
			_dash_index = event.index
			_dash_requested = true
			_dash_down = true
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif _hit(pos, _ult_c, _ult_r + 18.0):
			_ult_index = event.index
			_ult_requested = true
			_ult_down = true
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif _hit(pos, _pause_c, _pause_r + 12.0):
			_toggle_pause()
			get_viewport().set_input_as_handled()
		elif _move_index == -1:
			# Floating joystick: any non-button touch starts movement at the
			# touch point, then the knob follows relative to that origin.
			_move_index = event.index
			_joy_origin = pos
			_update_move(pos)
			queue_redraw()
			get_viewport().set_input_as_handled()
	else:
		if event.index == _move_index:
			_move_index = -1
			move_vector = Vector2.ZERO
			_knob_pos = _joy_c
			_joy_origin = _joy_c
			queue_redraw()
		if event.index == _dash_index:
			_dash_index = -1
			_dash_down = false
			queue_redraw()
		if event.index == _ult_index:
			_ult_index = -1
			_ult_down = false
			queue_redraw()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	var pos := _to_design(event.position)
	if event.pressed:
		if _hit(pos, _dash_c, _dash_r + 18.0):
			_mouse_dash = true
			_dash_requested = true
			_dash_down = true
			get_viewport().set_input_as_handled()
		elif _hit(pos, _ult_c, _ult_r + 18.0):
			_mouse_ult = true
			_ult_requested = true
			_ult_down = true
			get_viewport().set_input_as_handled()
		elif _hit(pos, _pause_c, _pause_r + 12.0):
			_toggle_pause()
			get_viewport().set_input_as_handled()
		elif _mouse_move == false:
			_mouse_move = true
			_joy_origin = pos
			_update_move(pos)
			get_viewport().set_input_as_handled()
	else:
		if _mouse_move:
			_mouse_move = false
			move_vector = Vector2.ZERO
			_knob_pos = _joy_c
			_joy_origin = _joy_c
		if _mouse_dash:
			_mouse_dash = false
			_dash_down = false
		if _mouse_ult:
			_mouse_ult = false
			_ult_down = false
	queue_redraw()


func _hit(pos: Vector2, center: Vector2, radius: float) -> bool:
	return pos.distance_to(center) <= radius


func _update_move(pos: Vector2) -> void:
	var delta := pos - _joy_origin
	var dist := delta.length()
	if dist < 10.0:
		move_vector = Vector2.ZERO
		_knob_pos = _joy_origin
		return
	var dir := delta / dist
	var clamped := minf(dist, _joy_r)
	_knob_pos = _joy_origin + dir * clamped
	var value := clamped / _joy_r
	if value < 0.12:
		move_vector = Vector2.ZERO
	else:
		move_vector = dir * value


func _toggle_pause() -> void:
	if overlay != null and overlay.has_method("toggle_pause"):
		Audio.play_click()
		overlay.toggle_pause()


func _draw() -> void:
	if not active:
		return
	draw_set_transform(_ui_offset, 0.0, Vector2(_ui_scale, _ui_scale))
	var character_color := CharacterData.color(Game.selected_character)
	var ready_dash := true
	var dash_ratio := 1.0
	var ult_ratio := 0.0
	if player != null and is_instance_valid(player):
		ready_dash = player.dash_cd <= 0.0
		dash_ratio = 1.0 - clampf(player.dash_cd / maxf(0.01, player.dash_cd_max), 0.0, 1.0)
		ult_ratio = clampf(player.ultimate_charge / maxf(0.01, player.ultimate_max), 0.0, 1.0)

	# Joystick (floating: base follows the touch origin)
	draw_circle(_joy_origin, _joy_r, Color(0.012, 0.025, 0.045, 0.58))
	draw_arc(_joy_origin, _joy_r, 0.0, TAU, 64, Color(0.82, 0.9, 1.0, 0.34), 2.0, true)
	draw_arc(_joy_origin, _joy_r - 10.0, 0.0, TAU, 64, Color(0.82, 0.9, 1.0, 0.14), 1.0, true)
	for i in 4:
		var a := TAU * float(i) / 4.0 + PI * 0.25
		var p1 := _joy_origin + Vector2.from_angle(a) * (_joy_r - 14.0)
		var p2 := _joy_origin + Vector2.from_angle(a) * (_joy_r - 4.0)
		draw_line(p1, p2, Color(0.82, 0.9, 1.0, 0.22), 1.0, true)
	draw_circle(_knob_pos, _joy_k, Color(0.82, 0.94, 1.0, 0.18))
	draw_circle(_knob_pos, _joy_k - 4.0, Color(0.82, 0.94, 1.0, 0.42))
	draw_arc(_knob_pos, _joy_k - 4.0, 0.0, TAU, 32, Color(1, 1, 1, 0.45), 1.0, true)

	# Dash
	var dash_color := Color(0.48, 0.94, 0.86) if ready_dash else Color(0.35, 0.48, 0.56)
	var dash_fill := Color(0.03, 0.11, 0.12, 0.72) if not _dash_down else Color(0.10, 0.30, 0.28, 0.82)
	draw_circle(_dash_c, _dash_r, dash_fill)
	draw_arc(_dash_c, _dash_r, 0.0, TAU, 48,
		Color(dash_color.r, dash_color.g, dash_color.b, 0.55 if ready_dash else 0.28), 3.0, true)
	draw_arc(_dash_c, _dash_r + 6.0, -PI * 0.5, -PI * 0.5 + TAU * dash_ratio, 40,
		Color(dash_color.r, dash_color.g, dash_color.b, 0.85), 3.0, true)
	_draw_center_text("대시", _dash_c + Vector2(0, 2), 15,
		Color(0.78, 1.0, 0.95) if ready_dash else Color(0.55, 0.66, 0.7))
	if not ready_dash and player != null:
		_draw_center_text("%.1f" % player.dash_cd, _dash_c + Vector2(0, 21), 9,
			Color(0.6, 0.72, 0.76))

	# Ultimate
	var ult_ready := ult_ratio >= 1.0
	var ult_color := character_color.lerp(Color.WHITE, 0.2)
	var ult_fill := Color(0.08, 0.07, 0.02, 0.75) if not ult_ready else Color(0.23, 0.18, 0.05, 0.88)
	if _ult_down:
		ult_fill = Color(0.36, 0.28, 0.08, 0.9)
	draw_circle(_ult_c, _ult_r, ult_fill)
	draw_arc(_ult_c, _ult_r, 0.0, TAU, 48,
		Color(ult_color.r, ult_color.g, ult_color.b, 0.5 if ult_ready else 0.25), 3.0, true)
	draw_arc(_ult_c, _ult_r + 6.0, -PI * 0.5, -PI * 0.5 + TAU * ult_ratio, 40,
		Color(ult_color.r, ult_color.g, ult_color.b, 0.9), 3.0, true)
	_draw_center_text("궁극기", _ult_c + Vector2(0, 0), 13,
		Color(1.0, 0.93, 0.72) if ult_ready else Color(0.62, 0.62, 0.58))
	_draw_center_text("%d%%" % int(round(ult_ratio * 100.0)), _ult_c + Vector2(0, 20), 9,
		Color(0.72, 0.7, 0.62))

	# Pause
	draw_circle(_pause_c, _pause_r, Color(0.02, 0.03, 0.05, 0.58))
	draw_arc(_pause_c, _pause_r, 0.0, TAU, 32, Color(0.82, 0.9, 1.0, 0.35), 2.0, true)
	draw_rect(Rect2(_pause_c + Vector2(-7, -8), Vector2(4, 16)), Color(0.9, 0.94, 1.0, 0.8))
	draw_rect(Rect2(_pause_c + Vector2(3, -8), Vector2(4, 16)), Color(0.9, 0.94, 1.0, 0.8))


func _draw_center_text(text: String, center: Vector2, size: int, color: Color) -> void:
	var width := 140.0
	var pos := Vector2(center.x - width * 0.5, center.y + size * 0.35)
	draw_string(_font, pos + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_CENTER, width, size,
		Color(0, 0, 0, 0.6))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, color)
