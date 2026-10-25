class_name UIKit
extends RefCounted

const GOLD := Color(1.0, 0.816, 0.424)
const GOLD_L := Color(1.0, 0.929, 0.702)
const CREAM := Color(0.953, 0.902, 0.812)
const MUTED := Color(0.58, 0.66, 0.74)
const MINT := Color(0.55, 0.886, 0.729)
const CORAL := Color(0.92, 0.4, 0.38)
const RED := Color(0.85, 0.2, 0.22)
const BG := Color(0.047, 0.075, 0.114, 0.96)
const BG_SOFT := Color(0.063, 0.098, 0.145, 0.92)
const BORDER := Color(0.152, 0.235, 0.318)
const INK := Color(0.027, 0.039, 0.059)
const PURPLE := Color(0.62, 0.44, 0.9)

const FANTASY_DIR := "res://assets/ui/fantasy/"
const BUTTON_NORMAL := FANTASY_DIR + "button_normal.png"
const BUTTON_HOVER := FANTASY_DIR + "button_hover.png"
const BUTTON_PRESSED := FANTASY_DIR + "button_pressed.png"
const BUTTON_DISABLED := FANTASY_DIR + "button_disabled.png"
const PANEL_FRAME := FANTASY_DIR + "panel_frame.png"


static func style(bg: Color, border: Color = BORDER, width: int = 2,
		margin: int = 0, radius: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_left = width
	s.border_width_top = width
	s.border_width_right = width
	s.border_width_bottom = width
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left = margin
	s.content_margin_top = margin
	s.content_margin_right = margin
	s.content_margin_bottom = margin
	s.anti_aliasing = false
	return s


static func label(text: String, size: int, color: Color = CREAM, outline: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if outline > 0:
		l.add_theme_color_override("font_outline_color", INK)
		l.add_theme_constant_override("outline_size", outline)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func panel(bg: Color = BG, border: Color = BORDER, width: int = 2,
		margin: int = 0) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", style(bg, border, width, margin))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_panel_ornament(p)
	return p


static func set_panel_ornament(p: Control, tint: Color) -> void:
	var n := p.get_node_or_null("Ornament")
	if n != null:
		n.modulate = tint


static func _add_panel_ornament(p: Control, tint: Color = Color(1.0, 0.82, 0.44, 0.62)) -> void:
	var texture := load(PANEL_FRAME)
	if texture == null:
		return
	var n := NinePatchRect.new()
	n.name = "Ornament"
	n.texture = texture
	n.patch_margin_left = 16
	n.patch_margin_top = 16
	n.patch_margin_right = 16
	n.patch_margin_bottom = 16
	n.modulate = tint
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	n.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p.add_child(n)
	var update := func() -> void:
		n.visible = p.size.x >= 44.0 and p.size.y >= 36.0
	p.resized.connect(update)
	p.tree_entered.connect(update)
	update.call()


static func add_panel_ornament(p: Control, tint: Color = Color(1.0, 0.82, 0.44, 0.62)) -> void:
	_add_panel_ornament(p, tint)


static func panel_container(bg: Color = BG, border: Color = BORDER, width: int = 2,
		margin: int = 0) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(bg, border, width, margin))
	_add_panel_ornament(p)
	return p


static func icon(path: String, px: float) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(path)
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


static func button(text: String, min_size: Vector2 = Vector2(220, 54)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", 24)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", _button_style(BUTTON_NORMAL))
	b.add_theme_stylebox_override("hover", _button_style(BUTTON_HOVER))
	b.add_theme_stylebox_override("pressed", _button_style(BUTTON_PRESSED))
	b.add_theme_stylebox_override("disabled", _button_style(BUTTON_DISABLED))
	b.add_theme_stylebox_override("focus", _focus_style())
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", GOLD_L)
	b.add_theme_color_override("font_pressed_color", GOLD_L)
	b.add_theme_color_override("font_disabled_color", MUTED.darkened(0.12))
	b.add_theme_color_override("font_outline_color", INK)
	b.add_theme_constant_override("outline_size", 2)
	return b


static func apply_tab_style(b: Button, selected: bool) -> void:
	b.add_theme_stylebox_override("normal",
		_button_style(BUTTON_HOVER if selected else BUTTON_NORMAL))
	b.add_theme_stylebox_override("hover", _button_style(BUTTON_HOVER))
	b.add_theme_stylebox_override("pressed", _button_style(BUTTON_PRESSED))
	b.add_theme_stylebox_override("disabled", _button_style(BUTTON_DISABLED))
	b.add_theme_color_override("font_color", GOLD_L if selected else CREAM)


static func _button_style(path: String) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = load(path)
	s.texture_margin_left = 12
	s.texture_margin_top = 12
	s.texture_margin_right = 12
	s.texture_margin_bottom = 12
	s.content_margin_left = 0
	s.content_margin_top = 0
	s.content_margin_right = 0
	s.content_margin_bottom = 0
	return s


static func _focus_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)
	s.border_color = GOLD
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.expand_margin_left = 2
	s.expand_margin_top = 2
	s.expand_margin_right = 2
	s.expand_margin_bottom = 2
	s.anti_aliasing = false
	return s


static func place(c: Control, x: float, y: float, w: float, h: float) -> void:
	c.position = Vector2(x, y)
	c.size = Vector2(w, h)


static func dimmer(alpha: float = 0.68) -> ColorRect:
	var c := ColorRect.new()
	c.color = Color(0.01, 0.018, 0.03, alpha)
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	return c
