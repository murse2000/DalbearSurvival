class_name PixelBar
extends Control

var value := 0.0
var max_value := 1.0
var fill_color := Color(1.0, 0.816, 0.424)
var back_color := Color(0.035, 0.055, 0.085, 0.95)
var border_color := Color(0.13, 0.19, 0.26)
var display_ratio := 0.0
var smoothing := 6.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func set_values(v: float, m: float, snap: bool = false) -> void:
	value = v
	max_value = maxf(0.001, m)
	if snap:
		display_ratio = clampf(value / max_value, 0.0, 1.0)
	queue_redraw()


func _process(delta: float) -> void:
	var target := clampf(value / max_value, 0.0, 1.0) if max_value > 0.0 else 0.0
	if absf(display_ratio - target) < 0.0005:
		display_ratio = target
	else:
		display_ratio = lerpf(display_ratio, target, 1.0 - exp(-delta * smoothing))
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, back_color)
	var w := size.x * display_ratio
	if w > 2.0:
		draw_rect(Rect2(2, 2, maxf(0.0, w - 4), size.y - 4), fill_color)
		draw_rect(Rect2(2, 2, maxf(0.0, w - 4), 2.0), fill_color.lightened(0.4))
		draw_rect(Rect2(2, size.y - 3, maxf(0.0, w - 4), 1.0), fill_color.darkened(0.35))
	# 25% notches
	for i in range(1, 4):
		var x := size.x * 0.25 * i
		draw_line(Vector2(x, size.y * 0.55), Vector2(x, size.y - 2.0), Color(0, 0, 0, 0.22), 1.0)
	draw_rect(rect, border_color, false, 2.0)
