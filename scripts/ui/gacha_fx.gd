class_name GachaFx
extends Control

## Full-screen summon theatre: rotating moonlight rays, charge pulses,
## rarity flashes, shockwaves and card-impact bursts.
## It lives in Control space so it also works in the menu scene, where the
## gameplay FX director (which needs a Camera2D) is not available.

const PARTICLE_DIR := "res://assets/particles/small/"
const RAYS_TEX := "res://assets/art/fx/gacha_rays.png"
const VIGNETTE_TEX := "res://assets/art/fx/gacha_vignette.png"

var _dark: ColorRect
var _world: Control
var _vignette: TextureRect
var _flash: ColorRect
var _caption: Label
var _sub: Label
var _rays: TextureRect
var _rays2: TextureRect
var _rune: TextureRect
var _ring: TextureRect
var _core: TextureRect
var _flare: TextureRect
var _ambient: CPUParticles2D
var _add_mat: CanvasItemMaterial
var _loops: Array[Tween] = []
var _shake_tween: Tween
var _rng := RandomNumberGenerator.new()
var _color := Color(1.0, 0.82, 0.42)
var _active := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_rng.randomize()
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_build()
	resized.connect(_layout)
	call_deferred("_layout")


func _build() -> void:
	_dark = ColorRect.new()
	_dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dark.color = Color(0.004, 0.007, 0.02, 0.0)
	_dark.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dark)

	_world = Control.new()
	_world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_world)

	_ambient = CPUParticles2D.new()
	_ambient.texture = load(PARTICLE_DIR + "kenney_star_08.png")
	_ambient.amount = 28
	_ambient.lifetime = 2.8
	_ambient.one_shot = false
	_ambient.emitting = false
	_ambient.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_ambient.emission_sphere_radius = 270.0
	_ambient.direction = Vector2.UP
	_ambient.spread = 180.0
	_ambient.initial_velocity_min = 8.0
	_ambient.initial_velocity_max = 34.0
	_ambient.gravity = Vector2(0.0, -18.0)
	_ambient.scale_amount_min = 0.25
	_ambient.scale_amount_max = 0.75
	_ambient.color = Color(0.72, 0.86, 1.0, 0.62)
	_ambient.local_coords = false
	_ambient.material = _add_mat
	_world.add_child(_ambient)

	_rays = _texture(RAYS_TEX, 980.0)
	_rays2 = _texture(RAYS_TEX, 720.0)
	_rune = _texture(PARTICLE_DIR + "kenney_magic_02.png", 470.0)
	_ring = _texture(PARTICLE_DIR + "kenney_circle_05.png", 300.0)
	_flare = _texture(PARTICLE_DIR + "kenney_flare_01.png", 500.0)
	_core = _texture("res://assets/art/fx/glow_gold.png", 230.0)

	_vignette = TextureRect.new()
	_vignette.texture = load(VIGNETTE_TEX)
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_vignette.modulate = Color(1, 1, 1, 0)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_vignette)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)

	_caption = UIKit.label("", 34, UIKit.GOLD_L, 8)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.modulate.a = 0.0
	add_child(_caption)
	_sub = UIKit.label("", 14, UIKit.CREAM, 4)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sub.modulate.a = 0.0
	add_child(_sub)


func _texture(path: String, side: float) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.size = Vector2(side, side)
	t.pivot_offset = t.size * 0.5
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.material = _add_mat
	t.modulate = Color(1, 1, 1, 0)
	_world.add_child(t)
	return t


func _layout() -> void:
	if _world == null:
		return
	var vp := size
	if vp.x < 2.0 or vp.y < 2.0:
		return
	var c := vp * 0.5
	var big := minf(vp.x, vp.y) * 1.52
	_place(_rays, c, big)
	_place(_rays2, c, big * 0.72)
	_place(_rune, c, minf(vp.x, vp.y) * 0.66)
	_place(_ring, c, minf(vp.x, vp.y) * 0.45)
	_place(_flare, c, minf(vp.x, vp.y) * 0.68)
	_place(_core, c, minf(vp.x, vp.y) * 0.36)
	_ambient.position = c
	_caption.position = Vector2(0, c.y - 112.0)
	_caption.size = Vector2(vp.x, 48)
	_caption.pivot_offset = _caption.size * 0.5
	_sub.position = Vector2(0, c.y - 66.0)
	_sub.size = Vector2(vp.x, 28)


func _place(node: Control, center: Vector2, side: float) -> void:
	node.size = Vector2(side, side)
	node.pivot_offset = node.size * 0.5
	node.position = center - node.size * 0.5


func open(color: Color, level: int) -> void:
	_stop_loops()
	_kill_shake()
	_active = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color = color
	_dark.mouse_filter = Control.MOUSE_FILTER_STOP
	_dark.color = Color(0.004, 0.007, 0.02, 0.0)
	_flash.color = Color(color.r, color.g, color.b, 0.0)
	_vignette.modulate.a = 0.0
	_caption.modulate.a = 0.0
	_sub.modulate.a = 0.0
	_caption.text = "달빛이 모여듭니다"
	_caption.add_theme_color_override("font_color", color.lightened(0.2))
	_sub.text = "장비의 형체를 응축하는 중..."
	_sub.add_theme_color_override("font_color", UIKit.CREAM)
	_ambient.color = Color(color.r, color.g, color.b, 0.62)
	_ambient.position = size * 0.5
	_ambient.emitting = true
	_apply_color(color, 0.42 + level * 0.08)
	_rays.rotation = 0.0
	_rays2.rotation = 0.0
	_rune.rotation = 0.0
	_ring.scale = Vector2(0.55, 0.55)
	_flare.scale = Vector2(0.6, 0.6)
	_core.scale = Vector2(0.25, 0.25)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_dark, "color:a", 0.93, 0.24)
	tw.tween_property(_vignette, "modulate:a", 0.92, 0.28)
	tw.tween_property(_caption, "modulate:a", 1.0, 0.22)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.24).set_delay(0.08)
	tw.tween_property(_rays, "scale", Vector2(1.02, 1.02), 0.75).from(Vector2(0.72, 0.72)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_rune, "scale", Vector2(1.04, 1.04), 0.8).from(Vector2(0.65, 0.65)).set_ease(Tween.EASE_OUT)
	tw.tween_property(_ring, "scale", Vector2.ONE, 0.7).from(Vector2(0.55, 0.55)).set_ease(Tween.EASE_OUT)
	tw.tween_property(_core, "scale", Vector2.ONE, 0.8).from(Vector2(0.25, 0.25)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_add_loop(_rays, "rotation", TAU, 8.5)
	_add_loop(_rays2, "rotation", -TAU, 5.8)
	_add_loop(_rune, "rotation", TAU, 13.0)
	_add_pulse_loop(_ring, 1.0, 1.08, 0.75)
	_add_pulse_loop(_core, 1.0, 1.16, 0.55)


func _apply_color(color: Color, alpha: float) -> void:
	_rays.modulate = Color(color.r, color.g, color.b, alpha)
	_rays2.modulate = Color(color.r, color.g, color.b, alpha * 0.62)
	_rune.modulate = Color(color.r, color.g, color.b, alpha * 0.78)
	_ring.modulate = Color(color.r, color.g, color.b, minf(1.0, alpha + 0.28))
	_flare.modulate = Color(color.r, color.g, color.b, alpha * 0.72)
	_core.modulate = Color(color.r, color.g, color.b, 0.95)


func _add_loop(node: Node, property: String, amount: float, duration: float) -> void:
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(node, property, amount, duration)
	_loops.append(tw)


func _add_pulse_loop(node: Node, from_scale: float, to_scale: float, duration: float) -> void:
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(node, "scale", Vector2.ONE * to_scale, duration).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "scale", Vector2.ONE * from_scale, duration).set_ease(Tween.EASE_IN_OUT)
	_loops.append(tw)


func phase(text: String, level: int, strength: float = 1.0) -> void:
	if not _active:
		return
	_caption.text = text
	_caption.add_theme_color_override("font_color", _color.lightened(0.18))
	_caption.modulate.a = 0.0
	_caption.scale = Vector2(1.1, 1.1)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_caption, "modulate:a", 1.0, 0.12)
	tw.tween_property(_caption, "scale", Vector2.ONE, 0.24).set_ease(Tween.EASE_OUT)
	if level >= 2:
		_sub.text = "공간이 달빛으로 뒤틀립니다..."
	elif level >= 1:
		_sub.text = "별의 파편이 소환진에 닿습니다..."
	pulse(strength)


func pulse(strength: float = 1.0) -> void:
	if not _active:
		return
	var c := size * 0.5
	_spawn_ring(c, _color, 260.0 + strength * 90.0, 0.55)
	_spawn_particles(c, _color, int(8 + strength * 8), 70.0, 0.55, 0.55)
	_core.scale = Vector2.ONE * 1.18
	var tw := create_tween()
	tw.tween_property(_core, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT)


func burst(level: int) -> void:
	if not _active:
		return
	var c := size * 0.5
	var flash_strength := Settings.flash_scale_value()
	_flash.color = Color(_color.r, _color.g, _color.b, 0.0)
	if flash_strength > 0.0:
		_flash.color.a = (0.28 + level * 0.10) * flash_strength
		var ft := create_tween()
		ft.tween_property(_flash, "color:a", 0.0, 0.62).set_ease(Tween.EASE_IN)
	_spawn_ring(c, _color, 620.0 + level * 150.0, 0.95)
	for i in 2 + level:
		_spawn_ring(c, _color.lightened(0.2), 240.0 + i * 105.0, 0.55 + i * 0.1)
	_spawn_particles(c, _color, 24 + level * 22, 180.0 + level * 90.0, 1.0, 1.0)
	_spawn_particles(c, Color(1, 1, 1, 0.9), 10 + level * 8, 110.0 + level * 50.0, 0.8, 0.55, 9.0)
	_core.scale = Vector2.ONE * (1.4 + level * 0.25)
	_ring.scale = Vector2.ONE * 1.2
	_shake(level + 1)
	if level >= 3:
		_caption.text = "전설 강림"
		_sub.text = "달빛이 선택한 장비가 깨어납니다"
		_caption.add_theme_color_override("font_color", UIKit.GOLD_L)
	elif level == 2:
		_caption.text = "에픽 강림"
		_sub.text = "강력한 기운이 형체를 이룹니다"
		_caption.add_theme_color_override("font_color", _color.lightened(0.2))
	else:
		_caption.text = "장비 획득"
		_sub.text = "달빛이 잦아들고 형체가 드러납니다"
	_caption.modulate.a = 0.0
	_caption.scale = Vector2(1.18, 1.18)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_caption, "modulate:a", 1.0, 0.12)
	tw.tween_property(_caption, "scale", Vector2.ONE, 0.42).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.3)


func card_burst(level: int, color: Color, global_pos: Vector2) -> void:
	if not visible or level <= 0:
		return
	var pos: Vector2 = get_global_transform().affine_inverse() * global_pos
	var ring_size := 90.0 + level * 45.0
	_spawn_ring(pos, color, ring_size, 0.45)
	if level >= 2:
		_spawn_ring(pos, color.lightened(0.22), ring_size * 0.65, 0.55)
		_spawn_particles(pos, color, 12 + level * 8, 75.0 + level * 35.0, 0.6, 0.62)
	if level >= 3:
		var rays := _texture(RAYS_TEX, 280.0)
		rays.position = pos - rays.size * 0.5
		rays.modulate = Color(color.r, color.g, color.b, 0.72)
		var tw := rays.create_tween()
		tw.set_parallel(true)
		tw.tween_property(rays, "scale", Vector2.ONE * 1.8, 0.7)
		tw.tween_property(rays, "rotation", 1.8, 0.7)
		tw.tween_property(rays, "modulate:a", 0.0, 0.7)
		tw.chain().tween_callback(rays.queue_free)
		_spawn_particles(pos, Color(1.0, 0.88, 0.5), 46, 130.0, 0.9, 0.9, 12.0)
		_caption.text = "전설 장비 획득"
		_sub.text = "달빛의 축복이 장비에 깃들었습니다"
		_caption.add_theme_color_override("font_color", UIKit.GOLD_L)
		_caption.modulate.a = 0.0
		var ct := create_tween()
		ct.tween_property(_caption, "modulate:a", 1.0, 0.12)
		ct.tween_property(_caption, "modulate:a", 0.0, 0.6).set_delay(0.75)
		_sub.modulate.a = 0.0
		var st := create_tween()
		st.tween_property(_sub, "modulate:a", 1.0, 0.12)
		st.tween_property(_sub, "modulate:a", 0.0, 0.5).set_delay(0.7)


func close() -> void:
	if not _active:
		return
	_active = false
	_stop_loops()
	_ambient.emitting = false
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_dark, "color:a", 0.0, 0.34)
	tw.tween_property(_vignette, "modulate:a", 0.0, 0.3)
	tw.tween_property(_caption, "modulate:a", 0.0, 0.22)
	tw.tween_property(_sub, "modulate:a", 0.0, 0.22)
	tw.tween_property(_rays, "modulate:a", 0.0, 0.3)
	tw.tween_property(_rays2, "modulate:a", 0.0, 0.3)
	tw.tween_property(_rune, "modulate:a", 0.0, 0.3)
	tw.tween_property(_ring, "modulate:a", 0.0, 0.3)
	tw.tween_property(_flare, "modulate:a", 0.0, 0.3)
	tw.tween_property(_core, "modulate:a", 0.0, 0.3)
	tw.chain().tween_callback(func() -> void:
		_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)


func finish() -> void:
	_active = false
	_stop_loops()
	_kill_shake()
	_ambient.emitting = false
	_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func cancel() -> void:
	_active = false
	_stop_loops()
	_kill_shake()
	_ambient.emitting = false
	_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _spawn_ring(pos: Vector2, color: Color, side: float, duration: float) -> void:
	if _world == null:
		return
	var ring := _texture(PARTICLE_DIR + "kenney_circle_05.png", side)
	ring.position = pos - ring.size * 0.5
	ring.modulate = Color(color.r, color.g, color.b, 0.9)
	ring.scale = Vector2(0.18, 0.18)
	var tw := ring.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * 1.45, duration).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(ring.queue_free)


func _spawn_particles(pos: Vector2, color: Color, amount: int, speed: float,
		lifetime: float, size_scale: float, speed_max: float = 0.0) -> void:
	if _world == null:
		return
	var p := CPUParticles2D.new()
	p.texture = load(PARTICLE_DIR + "kenney_star_08.png")
	p.position = pos
	p.amount = maxi(1, int(round(float(amount) * Settings.particle_scale())))
	p.lifetime = lifetime
	p.one_shot = true
	p.explosiveness = 0.94
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 4.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.35
	p.initial_velocity_max = maxf(speed, speed_max)
	p.gravity = Vector2(0.0, 34.0)
	p.scale_amount_min = size_scale * 0.55
	p.scale_amount_max = size_scale
	p.angular_velocity_min = -180.0
	p.angular_velocity_max = 180.0
	p.damping_min = 20.0
	p.damping_max = 55.0
	p.color = color
	p.local_coords = false
	p.material = _add_mat
	p.emitting = true
	_world.add_child(p)
	var timer := get_tree().create_timer(lifetime + 0.55, true, false, false)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(p):
			p.queue_free()
	)


func _shake(power: float) -> void:
	var motion := Settings.motion_scale_value()
	if motion <= 0.0:
		return
	_kill_shake()
	var base := Vector2.ZERO
	_shake_tween = create_tween()
	for i in 7:
		var amp := 4.0 * power * motion * (1.0 - float(i) / 8.0)
		_shake_tween.tween_property(_world, "position",
			base + Vector2(_rng.randf_range(-amp, amp), _rng.randf_range(-amp, amp)), 0.025)
	_shake_tween.tween_property(_world, "position", base, 0.09)


func _kill_shake() -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_world.position = Vector2.ZERO


func _stop_loops() -> void:
	for tw in _loops:
		if tw != null and tw.is_valid():
			tw.kill()
	_loops.clear()
