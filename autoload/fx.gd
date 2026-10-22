extends Node

## VFX director: particles, shockwaves, beams, damage numbers, screen shake,
## impact punch, bloom pulses and the full-screen post-process.

const P := "res://assets/particles/small/kenney_"
const MAX_FX := 260
const TEX_PATHS := {
	"star": P + "star_08.png",
	"star4": P + "star_02.png",
	"spark": P + "spark_05.png",
	"bolt": P + "spark_06.png",
	"streak": P + "spark_07.png",
	"trace": P + "trace_05.png",
	"dirt": P + "dirt_02.png",
	"smoke": P + "smoke_03.png",
	"smoke2": P + "smoke_06.png",
	"flare": P + "flare_01.png",
	"magic": P + "magic_02.png",
	"starfield": P + "magic_04.png",
	"ring": P + "circle_03.png",
	"halo": P + "circle_05.png",
	"light": P + "light_03.png",
	"rune": P + "symbol_02.png",
	"slash": P + "slash_02.png",
	"muzzle": P + "muzzle_02.png",
	"twirl": P + "twirl_01.png",
	"dirt2": P + "flame_05.png",
}

var camera: Camera2D
var fx_root: Node2D
var damage_root: Node2D
var decal_root: Node2D
var post: ShaderMaterial

var _tex := {}
var _add_mat: CanvasItemMaterial
var _font: Font

var _shake_amp := 0.0
var _shake_time := 0.0
var _shake_dur := 0.1
var _ab := 0.0
var _warp := 0.0
var _hurt_pulse := 0.0
var _low_hp := 0.0
var _bloom_base := 0.78
var _bloom_boost := 0.0
var _zoom := 1.0
var _shock := 0.0
var _speed_lines := 0.0
var _speed_color := Color(1.0, 0.82, 0.45)
var _saturation := 1.0
var _hitstop_token := 0
var _light_burst_count := 0
var _flash_tween: Tween
var _grade_tween: Tween
var _numbers: Array[Label] = []
var _decals: Array[Node] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_rng.randomize()
	for key in TEX_PATHS:
		_tex[key] = load(TEX_PATHS[key])
	_font = load("res://assets/fonts/Galmuri11.ttf")
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD


func setup(cam: Camera2D, fx: Node2D, dmg: Node2D, decals: Node2D, post_mat: ShaderMaterial) -> void:
	camera = cam
	fx_root = fx
	damage_root = dmg
	decal_root = decals
	post = post_mat
	if post != null:
		post.set_shader_parameter("bloom_strength", 0.0 if not Settings.bloom else _bloom_base)
		post.set_shader_parameter("vignette", 0.62)


func _process(delta: float) -> void:
	if _shake_time > 0.0:
		_shake_time = maxf(0.0, _shake_time - delta)
	_ab = maxf(0.0, _ab - delta * 0.055)
	_warp = maxf(0.0, _warp - delta * 0.55)
	_hurt_pulse = maxf(0.0, _hurt_pulse - delta * 3.6)
	_bloom_boost = maxf(0.0, _bloom_boost - delta * 2.8)
	_zoom = lerpf(_zoom, 1.0, 1.0 - exp(-delta * 12.0))
	_shock = maxf(0.0, _shock - delta * 2.4)
	_speed_lines = maxf(0.0, _speed_lines - delta * 1.9)
	_saturation = lerpf(_saturation, 1.0, 1.0 - exp(-delta * 3.2))
	if post != null:
		post.set_shader_parameter("aberration", _ab)
		post.set_shader_parameter("warp", _warp)
		post.set_shader_parameter("hurt", maxf(_hurt_pulse, _low_hp * 0.35))
		post.set_shader_parameter("bloom_strength", 0.0 if not Settings.bloom else _bloom_base + _bloom_boost)
		post.set_shader_parameter("zoom", _zoom)
		post.set_shader_parameter("shock", _shock)
		post.set_shader_parameter("speed_lines", _speed_lines)
		post.set_shader_parameter("speed_color", _speed_color)
		post.set_shader_parameter("saturation", _saturation)


func teardown() -> void:
	camera = null
	fx_root = null
	damage_root = null
	decal_root = null
	post = null
	_numbers.clear()
	_decals.clear()
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	if _grade_tween != null and _grade_tween.is_valid():
		_grade_tween.kill()
	_hitstop_token += 1
	Engine.time_scale = 1.0


# ------------------------------------------------------------------ primitives
func _add(node: Node2D, additive: bool = false, parent: Node2D = null) -> void:
	var p := parent if parent != null else fx_root
	if p == null or not is_instance_valid(p):
		node.queue_free()
		return
	p.add_child(node)
	if additive:
		node.material = _add_mat


func _sprite(pos: Vector2, key: String, color: Color, scale: float, additive: bool = true) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = _tex.get(key)
	s.position = pos
	s.modulate = color
	s.scale = Vector2.ONE * scale
	_add(s, additive)
	return s


func _fade_sprite(pos: Vector2, key: String, color: Color, start_scale: float,
		end_scale: float, dur: float, additive: bool = true, rot: float = 0.0) -> void:
	if fx_root == null or not is_instance_valid(fx_root) or fx_root.get_child_count() > MAX_FX:
		return
	var s := _sprite(pos, key, color, start_scale, additive)
	if not is_instance_valid(s):
		return
	s.rotation = rot
	var tw := s.create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2.ONE * end_scale, dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(s, "modulate:a", 0.0, dur).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "rotation", rot + _rng.randf_range(-0.4, 0.4), dur)
	tw.chain().tween_callback(s.queue_free)


func ring(pos: Vector2, color: Color, radius: float, dur: float = 0.35, key: String = "ring") -> void:
	if fx_root == null or not is_instance_valid(fx_root):
		return
	var s := _sprite(pos, key, color, 0.05, true)
	if not is_instance_valid(s):
		return
	var target := radius / 62.0
	var tw := s.create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2.ONE * target, dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_property(s, "modulate:a", 0.0, dur).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(s.queue_free)


func rune(pos: Vector2, color: Color, radius: float, dur: float = 0.7, alpha: float = 0.85) -> void:
	if fx_root == null or not is_instance_valid(fx_root):
		return
	var s := _sprite(pos, "magic", color, radius / 64.0, true)
	if not is_instance_valid(s):
		return
	s.modulate.a = alpha
	var tw := s.create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2.ONE * (radius / 48.0), dur).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "rotation", s.rotation + PI * 1.4, dur)
	tw.tween_property(s, "modulate:a", 0.0, dur)
	tw.chain().tween_callback(s.queue_free)


func particles(pos: Vector2, key: String, color: Color, amount: int, lifetime: float,
		speed_min: float, speed_max: float, size: float, spread: float = 180.0,
		gravity: Vector2 = Vector2.ZERO, additive: bool = true, spin: float = 0.0) -> void:
	if fx_root == null or not is_instance_valid(fx_root) or fx_root.get_child_count() > MAX_FX:
		return
	var p := CPUParticles2D.new()
	p.texture = _tex.get(key)
	p.position = pos
	p.amount = maxi(1, amount)
	p.lifetime = lifetime
	p.one_shot = true
	p.explosiveness = 0.92
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 5.0
	p.direction = Vector2.UP
	p.spread = spread
	p.initial_velocity_min = speed_min
	p.initial_velocity_max = speed_max
	p.gravity = gravity
	p.scale_amount_min = size * 0.7
	p.scale_amount_max = size * 1.15
	p.angular_velocity_min = -spin
	p.angular_velocity_max = spin
	p.damping_min = 20.0
	p.damping_max = 60.0
	p.color = color
	p.local_coords = false
	p.emitting = true
	_add(p, additive)
	var t := get_tree().create_timer(lifetime + 0.5, false, false, false)
	t.timeout.connect(func():
		if is_instance_valid(p):
			p.queue_free()
	)


# ------------------------------------------------------------------ screen
func shake(amount: float, duration: float) -> void:
	if not Settings.shake:
		return
	_shake_amp = maxf(_shake_amp, amount)
	_shake_dur = maxf(_shake_dur, duration)
	_shake_time = maxf(_shake_time, duration)


func get_shake_offset() -> Vector2:
	if not Settings.shake:
		_shake_amp = 0.0
		_shake_time = 0.0
		return Vector2.ZERO
	if _shake_time <= 0.0:
		_shake_amp = 0.0
		return Vector2.ZERO
	var f := _shake_time / maxf(0.001, _shake_dur)
	f = f * f
	return Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * _shake_amp * f


func punch(amount: float) -> void:
	if camera != null and is_instance_valid(camera) and camera.has_method("punch"):
		camera.punch(amount)


func flash(color: Color = Color(1, 1, 1), amount: float = 0.55, dur: float = 0.35) -> void:
	if post == null:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	post.set_shader_parameter("flash_color", color)
	post.set_shader_parameter("flash", amount)
	_flash_tween = create_tween()
	_flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_flash_tween.tween_property(post, "shader_parameter/flash", 0.0, dur).set_ease(Tween.EASE_OUT)


func grade(color: Color, amount: float = 0.35, dur: float = 1.6) -> void:
	if post == null:
		return
	if _grade_tween != null and _grade_tween.is_valid():
		_grade_tween.kill()
	post.set_shader_parameter("grade_color", color)
	post.set_shader_parameter("grade_amount", amount)
	_grade_tween = create_tween()
	_grade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_grade_tween.tween_property(post, "shader_parameter/grade_amount", 0.0, dur).set_ease(Tween.EASE_IN)


func set_low_hp(on: bool) -> void:
	_low_hp = 1.0 if on else 0.0


func boost_bloom(amount: float) -> void:
	_bloom_boost = maxf(_bloom_boost, amount)


func impact(amount: float = 0.04, warp: float = 0.02, ab: float = 0.012) -> void:
	punch(amount)
	_warp = maxf(_warp, warp)
	_ab = maxf(_ab, ab)


func screen_shock(strength: float = 0.55, zoom_amount: float = 0.025,
		line_amount: float = 0.0, color: Color = Color(1.0, 0.82, 0.45)) -> void:
	_shock = maxf(_shock, strength)
	_zoom = maxf(_zoom, 1.0 + zoom_amount)
	_speed_lines = maxf(_speed_lines, line_amount)
	if line_amount > 0.0:
		_speed_color = color
	_saturation = maxf(_saturation, 1.0 + strength * 0.22)


func speed_lines(amount: float = 0.55, color: Color = Color(1.0, 0.82, 0.45)) -> void:
	_speed_lines = maxf(_speed_lines, amount)
	_speed_color = color


func light_burst(pos: Vector2, color: Color, light_range: float = 180.0,
		energy: float = 1.4, duration: float = 0.3) -> void:
	if fx_root == null or not is_instance_valid(fx_root):
		return
	var cap := 14 if LightRig.lit_enabled() else 6
	if _light_burst_count >= cap:
		return
	var light := LightRig.add_point_light(fx_root, color, light_range, energy, false, pos)
	if light == null:
		return
	_light_burst_count += 1
	var tw := light.create_tween()
	tw.tween_property(light, "energy", 0.0, duration).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		_light_burst_count = maxi(0, _light_burst_count - 1)
		if is_instance_valid(light):
			light.queue_free()
	)


func hitstop(duration: float = 0.055, scale: float = 0.08) -> void:
	_hitstop_token += 1
	var token := _hitstop_token
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	if token == _hitstop_token:
		Engine.time_scale = 1.0


func combo_tick(pos: Vector2, combo: int, color: Color) -> void:
	if combo < 3:
		return
	var t := clampf(float(combo) / 80.0, 0.0, 1.0)
	ring(pos + Vector2(0, -12), color, 18.0 + 22.0 * t, 0.2, "halo")
	particles(pos + Vector2(0, -14), "star", color, 3 + int(3 * t), 0.25,
		35, 110 + 80 * t, 0.2, 180, Vector2(0, -20), true, 180)


func combo_burst(pos: Vector2, combo: int) -> void:
	var t := clampf(float(combo) / 100.0, 0.0, 1.0)
	var color := Color(1.0, 0.82, 0.4).lerp(Color(1.0, 0.32, 0.62), t)
	ring(pos, color, 90.0 + 80.0 * t, 0.55)
	ring(pos, color.lerp(Color.WHITE, 0.25), 160.0 + 130.0 * t, 0.75, "halo")
	rune(pos, color, 120.0 + 90.0 * t, 0.9, 0.65)
	particles(pos, "star", color, 24 + int(22 * t), 0.9, 90, 300 + 160 * t, 0.34, 180, Vector2(0, -30), true, 480)
	_fade_sprite(pos, "flare", color, 0.8 + t, 2.2 + t, 0.45)
	flash(color, 0.16 + 0.12 * t, 0.35)
	grade(color, 0.08 + 0.12 * t, 1.2)
	light_burst(pos, color, 220.0 + 120.0 * t, 1.8 + t, 0.5)
	boost_bloom(0.45 + t * 0.7)
	speed_lines(0.35 + t * 0.45, color)
	screen_shock(0.25 + t * 0.5, 0.012 + t * 0.035, 0.0, color)
	shake(4.0 + 7.0 * t, 0.25 + 0.3 * t)
	punch(0.035 + 0.05 * t)
	if combo >= 50:
		hitstop(0.035, 0.12)
	Audio.play("levelup", 1.32 - t * 0.18, -9.0)


# ------------------------------------------------------------------ combat fx
func damage_number(pos: Vector2, amount: float, color: Color, crit: bool = false) -> void:
	if not Settings.damage_numbers:
		return
	if damage_root == null or not is_instance_valid(damage_root):
		return
	if _numbers.size() > 55:
		var old = _numbers.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	var l := Label.new()
	l.text = ("%d!" % int(round(amount))) if crit else str(int(round(amount)))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size = Vector2(190, 42)
	l.position = pos + Vector2(-95 + _rng.randf_range(-10, 10), -22)
	l.scale = Vector2(0.5, 0.5) * (1.65 if crit else 1.0)
	l.pivot_offset = Vector2(95, 21)
	l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", 36 if crit else 21)
	l.add_theme_color_override("font_color", Color(1.0, 0.14, 0.18) if crit else color)
	l.add_theme_color_override("font_outline_color", Color(0.18, 0.01, 0.03, 1.0) if crit else Color(0.03, 0.04, 0.07, 1.0))
	l.add_theme_constant_override("outline_size", 8 if crit else 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_root.add_child(l)
	_numbers.append(l)
	var dur := 0.62 if crit else 0.5
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - (34 if crit else 24), dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(l, "modulate:a", 0.0, dur * 0.65).set_delay(dur * 0.35)
	tw.tween_property(l, "scale", Vector2(0.5, 0.5), 0.12).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(l.queue_free)


func float_text(pos: Vector2, text: String, color: Color, size: int = 20) -> void:
	if damage_root == null or not is_instance_valid(damage_root):
		return
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(220, 30)
	l.position = pos + Vector2(-110, -30)
	l.scale = Vector2(0.5, 0.5)
	l.pivot_offset = Vector2(110, 15)
	l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07))
	l.add_theme_constant_override("outline_size", 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_root.add_child(l)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 30, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)


func crit_burst(pos: Vector2, amount: float = 0.0) -> void:
	var red := Color(1.0, 0.08, 0.13)
	var hot := Color(1.0, 0.52, 0.22)
	ring(pos, red, 62.0, 0.42, "ring")
	ring(pos, hot, 112.0, 0.52, "halo")
	rune(pos, red, 92.0, 0.55, 0.7)
	particles(pos, "star", red, 22, 0.55, 100, 360, 0.38, 180, Vector2(0, 110), true, 460)
	_fade_sprite(pos, "flare", red, 0.75, 1.9, 0.3)
	flash(Color(1.0, 0.06, 0.10), 0.12, 0.22)
	grade(Color(1.0, 0.08, 0.12), 0.16, 0.55)
	light_burst(pos, red, 280.0, 2.5, 0.4)
	screen_shock(0.34, 0.025, 0.24, red)
	shake(5.5, 0.22)
	float_text(pos + Vector2(0, -38), "CRIT!", hot, 32)
	if amount >= 20.0:
		hitstop(0.025, 0.18)
	Audio.play("hit", 0.72, -1.0)


func hit(pos: Vector2, color: Color, crit: bool = false) -> void:
	if fx_root == null:
		return
	particles(pos, "star", color, 4 if not crit else 8, 0.3, 50, 150, 0.24, 180, Vector2(0, 90), true, 300)
	_fade_sprite(pos, "flare", color, 0.25 if not crit else 0.4, 0.5, 0.12)
	if crit:
		ring(pos, Color(1.0, 0.1, 0.14), 38, 0.3, "halo")
		crit_burst(pos)


func muzzle(pos: Vector2, angle: float, color: Color) -> void:
	if fx_root == null:
		return
	var s := _sprite(pos, "muzzle", color, 0.24, true)
	if is_instance_valid(s):
		s.rotation = angle
		s.scale = Vector2(0.26, 0.18)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(s, "scale", Vector2(0.40, 0.28), 0.07)
		tw.tween_property(s, "modulate:a", 0.0, 0.09)
		tw.chain().tween_callback(s.queue_free)


func slash(pos: Vector2, angle: float, color: Color, scale: float = 0.4) -> void:
	var s := _sprite(pos, "slash", color, scale, true)
	if not is_instance_valid(s):
		return
	s.rotation = angle
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2.ONE * scale * 1.5, 0.18).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "rotation", angle + 0.5, 0.18)
	tw.tween_property(s, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(s.queue_free)


func enemy_death(pos: Vector2, color: Color, big: bool = false) -> void:
	if fx_root == null:
		return
	var n := 26 if big else 13
	particles(pos, "star", color, n, 0.5, 70, 220, 0.32, 180, Vector2(0, 190), true, 420)
	particles(pos, "dirt", color.darkened(0.15), n / 2 + 3, 0.65, 40, 150, 0.34, 120, Vector2(0, 240), false)
	particles(pos, "smoke", Color(color.r, color.g, color.b, 0.55), 4, 0.8, 20, 60, 0.45, 90, Vector2(0, -30), false)
	_fade_sprite(pos, "flare", color, 0.5, 1.1, 0.22)
	ring(pos, color, 34 if not big else 64, 0.3, "halo")
	death_decal(pos, color)
	shake(3.0 if not big else 7.0, 0.15 if not big else 0.3)
	if big:
		flash(color, 0.18, 0.3)
		punch(0.035)
		screen_shock(0.28, 0.012, 0.15, color)
		hitstop(0.025, 0.25)


func death_decal(pos: Vector2, color: Color) -> void:
	if decal_root == null or not is_instance_valid(decal_root):
		return
	var s := Sprite2D.new()
	s.texture = _tex["dirt"]
	s.position = pos
	s.rotation = _rng.randf_range(0, TAU)
	s.scale = Vector2.ONE * _rng.randf_range(0.35, 0.65)
	s.modulate = Color(color.r * 0.7, color.g * 0.8, color.b * 0.75, 0.30)
	decal_root.add_child(s)
	_decals.append(s)
	while _decals.size() > 45:
		var old = _decals.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	var tw := s.create_tween()
	tw.tween_interval(3.0)
	tw.tween_property(s, "modulate:a", 0.0, 4.0)
	tw.tween_callback(s.queue_free)


func pickup_fx(pos: Vector2, color: Color, value: int = 1) -> void:
	particles(pos, "star", color, 3 + mini(value, 6), 0.35, 40, 120, 0.24, 180, Vector2(0, 40), true, 260)
	if value >= 5:
		ring(pos, color, 30, 0.3, "halo")
		_fade_sprite(pos, "star4", color, 0.3, 0.6, 0.2)


func hurt(player_pos: Vector2) -> void:
	# Contact damage is constant in a horde game: keep it to a red edge pulse,
	# shake and sparks instead of washing the whole screen red.
	_hurt_pulse = 0.75
	_ab = maxf(_ab, 0.004)
	_warp = maxf(_warp, 0.014)
	shake(5.0, 0.24)
	punch(0.045)
	particles(player_pos + Vector2(0, -12), "star", Color(1.0, 0.45, 0.4), 10, 0.35, 80, 180, 0.26, 180, Vector2(0, 160), true, 300)


func chain_lightning(points: Array, color: Color) -> void:
	if fx_root == null or not is_instance_valid(fx_root) or points.size() < 2:
		return
	var line := Line2D.new()
	line.z_index = 7
	line.width = 3.0
	line.default_color = color
	line.material = _add_mat
	var jagged := PackedVector2Array()
	for i in points.size() - 1:
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		for s in 6:
			var t := float(s) / 6.0
			var p := a.lerp(b, t) + Vector2(_rng.randf_range(-5, 5), _rng.randf_range(-5, 5))
			jagged.append(p)
	jagged.append(points[points.size() - 1])
	line.points = jagged
	fx_root.add_child(line)
	for p in points:
		_fade_sprite(p, "flare", color, 0.18, 0.4, 0.18)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.22)
	tw.tween_callback(line.queue_free)
	Audio.play("laser", 1.25, -9.0)


func explosion(pos: Vector2, color: Color, size: float = 1.0) -> void:
	if fx_root == null or not is_instance_valid(fx_root):
		return
	ring(pos, color, 70.0 * size, 0.4, "ring")
	ring(pos, color, 110.0 * size, 0.55, "halo")
	rune(pos, color, 80.0 * size, 0.5, 0.5)
	particles(pos, "star", color, int(16 * size) + 4, 0.5, 90, 260 * size, 0.32, 180, Vector2(0, 120), true, 300)
	particles(pos, "smoke", Color(color.r, color.g, color.b, 0.5), 4, 0.8, 30, 90, 0.45, 100, Vector2(0, -30), false)
	_fade_sprite(pos, "flare", color, 0.5 * size, 1.4 * size, 0.3)
	flash(Color(color.r, color.g, color.b), 0.10, 0.25)
	boost_bloom(0.25)
	shake(5.0 * size, 0.3)
	punch(0.04 * size)
	screen_shock(0.22 * size, 0.009 * size, 0.10, color)
	light_burst(pos, color, 155.0 * size, 1.35 * size, 0.32)
	death_decal(pos, color)


func pulse_fx(pos: Vector2, radius: float, color: Color) -> void:
	ring(pos, color, radius, 0.45, "ring")
	ring(pos + Vector2(0, -8), color, radius * 0.7, 0.32, "halo")
	rune(pos + Vector2(0, -4), color, radius * 0.8, 0.55, 0.45)
	# keep the center clear so the bear stays readable
	for i in 6:
		var a := TAU * float(i) / 6.0 + 0.2
		var p := pos + Vector2.from_angle(a) * radius * 0.58
		particles(p, "star", color, 4, 0.5, radius * 0.7, radius * 1.4, 0.3, 100, Vector2.ZERO, true, 300)
	flash(color, 0.08, 0.2)
	boost_bloom(0.25)
	shake(4.5, 0.25)
	punch(0.035)
	screen_shock(0.30, 0.016, 0.18, color)


func laser_fx(start: Vector2, end: Vector2, color: Color, width: float) -> void:
	if fx_root == null or not is_instance_valid(fx_root):
		return
	var dir := end - start
	var length := dir.length()
	if length < 2.0:
		return
	var holder := Node2D.new()
	holder.position = start
	holder.rotation = dir.angle()
	fx_root.add_child(holder)
	var beam := Sprite2D.new()
	beam.texture = load("res://assets/art/fx/laser_beam.png")
	beam.centered = false
	beam.scale = Vector2(length / 96.0, maxf(0.7, width / 24.0))
	beam.modulate = color
	holder.add_child(beam)
	beam.material = _add_mat
	var glow := Sprite2D.new()
	glow.texture = beam.texture
	glow.centered = false
	glow.scale = Vector2(length / 96.0, maxf(1.6, width / 12.0))
	glow.modulate = Color(color.r, color.g, color.b, 0.35)
	holder.add_child(glow)
	glow.material = _add_mat
	# electric arcs along the beam
	for i in 2:
		var arc := Sprite2D.new()
		arc.texture = _tex["streak"]
		arc.centered = false
		arc.position.y = _rng.randf_range(-width * 0.5, width * 0.5)
		arc.scale = Vector2(length / 128.0, _rng.randf_range(0.25, 0.6))
		arc.modulate = Color(0.95, 1.0, 0.95, 0.55)
		arc.rotation = _rng.randf_range(-0.08, 0.08)
		holder.add_child(arc)
		arc.material = _add_mat
	# muzzle + tip
	_fade_sprite(start, "flare", color, 0.55, 1.1, 0.18)
	_fade_sprite(end, "star4", color, 0.45, 0.9, 0.26)
	for i in 8:
		var pp := start + dir * _rng.randf_range(0.2, 1.0)
		particles(pp, "star", color, 2, 0.35, 20, 90, 0.22, 180, Vector2.ZERO, true, 200)
	flash(color, 0.20, 0.24)
	boost_bloom(0.45)
	shake(5.5, 0.22)
	punch(0.04)
	screen_shock(0.36, 0.018, 0.22, color)
	var tw := holder.create_tween()
	tw.tween_property(holder, "modulate:a", 0.0, 0.24).set_ease(Tween.EASE_IN)
	tw.tween_callback(holder.queue_free)


func levelup_burst(pos: Vector2) -> void:
	if fx_root == null:
		return
	ring(pos, Color(1.0, 0.86, 0.4), 150, 0.8)
	ring(pos, Color(0.7, 1.0, 0.85), 210, 1.0, "halo")
	rune(pos, Color(1.0, 0.82, 0.35), 170, 1.1)
	particles(pos, "star", Color(1.0, 0.9, 0.5), 60, 1.2, 80, 320, 0.36, 180, Vector2(0, -40), true, 450)
	particles(pos, "spark", Color(1.0, 0.95, 0.7), 20, 0.8, 120, 320, 0.3, 80, Vector2.ZERO, true, 0)
	_fade_sprite(pos, "flare", Color(1.0, 0.9, 0.6), 1.2, 3.0, 0.6)
	flash(Color(1.0, 0.87, 0.52), 0.42, 0.65)
	boost_bloom(1.2)
	shake(6.0, 0.4)
	punch(0.07)
	screen_shock(0.65, 0.045, 0.55, Color(1.0, 0.86, 0.42))
	light_burst(pos, Color(1.0, 0.86, 0.42), 380.0, 2.6, 0.7)
	grade(Color(1.0, 0.75, 0.35), 0.16, 1.0)


func boss_spawn(pos: Vector2) -> void:
	if fx_root == null:
		return
	rune(pos, Color(0.75, 0.45, 1.0), 220, 1.6)
	rune(pos, Color(0.45, 1.0, 0.75), 320, 1.9)
	ring(pos, Color(0.75, 0.45, 1.0), 260, 1.0)
	ring(pos, Color(1.0, 0.5, 0.8), 340, 1.4, "halo")
	particles(pos, "star", Color(0.8, 0.55, 1.0), 50, 1.4, 60, 260, 0.4, 180, Vector2(0, -60), true, 400)
	# descending beam
	var beam := Sprite2D.new()
	beam.texture = load("res://assets/art/char/boss_beam.png")
	beam.position = pos + Vector2(0, -150)
	beam.scale = Vector2(2.4, 1.5)
	beam.modulate = Color(0.7, 1.0, 0.85, 0.9)
	beam.material = _add_mat
	_add(beam, true)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(beam, "modulate:a", 0.0, 1.5)
	tw.tween_property(beam, "scale:x", 4.0, 1.5)
	tw.chain().tween_callback(beam.queue_free)
	flash(Color(0.65, 0.4, 1.0), 0.4, 0.8)
	grade(Color(0.6, 0.35, 0.9), 0.35, 2.4)
	boost_bloom(0.8)
	shake(11.0, 0.8)
	punch(0.09)
	screen_shock(0.62, 0.04, 0.58, Color(0.75, 0.45, 1.0))
	light_burst(pos, Color(0.75, 0.45, 1.0), 420.0, 2.2, 0.75)


func boss_death(pos: Vector2) -> void:
	_boss_death_sequence(pos)


func _boss_death_sequence(pos: Vector2) -> void:
	if fx_root == null:
		return
	var slow := create_tween()
	slow.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	slow.tween_property(Engine, "time_scale", 0.45, 0.08)
	slow.tween_interval(0.55)
	slow.tween_property(Engine, "time_scale", 1.0, 0.25)
	for i in 10:
		if not is_inside_tree() or fx_root == null or not is_instance_valid(fx_root):
			break
		var offset := Vector2(_rng.randf_range(-70, 70), _rng.randf_range(-60, 50))
		enemy_death(pos + offset, Color(1.0, 0.6 - i * 0.03, 0.25 + i * 0.04), true)
		light_burst(pos + offset, Color(1.0, 0.62, 0.28), 230.0, 1.8, 0.55)
		flash(Color(1.0, 0.75, 0.4), 0.22, 0.35)
		shake(8.0, 0.3)
		await get_tree().create_timer(0.13, true, false, false).timeout
	Engine.time_scale = 1.0
	if fx_root == null:
		return
	flash(Color(1.0, 1.0, 0.92), 0.9, 1.2)
	ring(pos, Color(1.0, 0.9, 0.6), 520, 1.4)
	particles(pos, "star", Color(1.0, 0.85, 0.5), 90, 2.0, 100, 480, 0.45, 180, Vector2(0, 120), true, 500)
	light_burst(pos, Color(1.0, 0.82, 0.42), 620.0, 3.4, 1.2)
	boost_bloom(1.8)
	shake(16.0, 1.3)
	punch(0.12)
	screen_shock(1.0, 0.075, 0.9, Color(1.0, 0.82, 0.4))
	grade(Color(1.0, 0.78, 0.35), 0.3, 2.2)
