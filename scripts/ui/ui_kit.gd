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
	return p


static func panel_container(bg: Color = BG, border: Color = BORDER, width: int = 2,
		margin: int = 0) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(bg, border, width, margin))
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
	return b


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
