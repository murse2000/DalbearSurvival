class_name UIFit
extends RefCounted

## Centre a 1280x720 UI on any aspect ratio, with a full-bleed backdrop behind it.

const DESIGN := Vector2(1280, 720)


static func wrap_menu(root: Control, backdrop_path: String = "res://assets/art/ui/menu_backdrop.png") -> void:
	if root.has_meta("ui_fit_done"):
		return
	root.set_meta("ui_fit_done", true)
	var old_children := root.get_children()

	var layer := CanvasLayer.new()
	layer.name = "MenuBackdrop"
	layer.layer = -10
	root.add_child(layer)
	var bg := TextureRect.new()
	bg.texture = load(backdrop_path)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.02, 0.04, 0.35)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)

	var content := Control.new()
	content.name = "ResponsiveContent"
	content.size = DESIGN
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(content)
	for child in old_children:
		root.remove_child(child)
		content.add_child(child)

	var apply := func() -> void:
		if not is_instance_valid(content):
			return
		var vp := root.get_viewport_rect().size
		var s := minf(vp.x / DESIGN.x, vp.y / DESIGN.y)
		content.scale = Vector2(s, s)
		content.position = (vp - DESIGN * s) * 0.5

	apply.call()
	root.get_viewport().size_changed.connect(apply)


static func fit_canvas_control(root: Control) -> void:
	var apply := func() -> void:
		if not is_instance_valid(root):
			return
		var vp := root.get_viewport_rect().size
		var s := minf(vp.x / DESIGN.x, vp.y / DESIGN.y)
		root.scale = Vector2(s, s)
		root.position = (vp - DESIGN * s) * 0.5
	apply.call()
	root.get_viewport().size_changed.connect(apply)
