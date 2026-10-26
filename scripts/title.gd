extends Control

## Title screen: moonlit key art, logo, story, start / settings / quit.

const SettingsPanel := preload("res://scripts/ui/settings_panel.gd")

var _args: PackedStringArray
var _bg: TextureRect
var _fireflies: CPUParticles2D
var _content: Control
var _warning: Label
var _ticker: Panel
var _domain: Label
var _credits: Label
var _version: Label
var _start_btn: Button
var _new_run_btn: Button
var _continue_info: Label
var _record_label: Label
var _hint_label: Label
var _button_row: HBoxContainer
var _time := 0.0
var _starting := false
var _settings_panel: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.running = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 2.0)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_build()
	_refresh_input_hint()
	_fit_title()
	get_viewport().size_changed.connect(_fit_title)
	if "--capture-title" in _args:
		_capture()
	if "--capture-settings" in _args:
		_capture_settings()
	if "--test-settings" in _args:
		_test_settings()
	if "--test-title-continue" in _args:
		_test_title_continue()
	if "--test-title-resume" in _args:
		_test_title_resume()
	if "--test-title-layout" in _args:
		_test_title_layout.call_deferred()
	if "--smoke-start" in _args:
		Game.clear_run_checkpoint()
		_start.call_deferred()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_bg = TextureRect.new()
	_bg.texture = load("res://assets/art/ui/title_bg.png")
	_bg.position = Vector2(-26, -14)
	_bg.size = Vector2(1332, 748)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	var grad := ColorRect.new()
	grad.set_anchors_preset(Control.PRESET_FULL_RECT)
	grad.anchor_right = 1.0
	grad.anchor_bottom = 1.0
	grad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gm := ShaderMaterial.new()
	gm.shader = load("res://assets/shaders/title_gradient.gdshader")
	grad.material = gm
	add_child(grad)

	_build_fireflies()

	_content = Control.new()
	_content.position = Vector2(96, 96)
	_content.size = Vector2(640, 560)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)

	var over := HBoxContainer.new()
	over.position = Vector2(4, 0)
	over.add_theme_constant_override("separation", 10)
	_content.add_child(over)
	var moon := UIKit.icon("res://assets/art/ui/icon_moon.png", 26)
	over.add_child(moon)
	var over_label := UIKit.label("달빛 수호대  ·  MOON GUARDIAN", 15, UIKit.MINT)
	over.add_child(over_label)

	var title := UIKit.label("달베어", 99, UIKit.GOLD, 12)
	title.position = Vector2(-4, 28)
	title.size = Vector2(600, 124)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 6)
	_content.add_child(title)

	var sub := UIKit.label("지구를 지켜라", 44, UIKit.CREAM, 7)
	sub.position = Vector2(2, 146)
	_content.add_child(sub)

	var eng := UIKit.label("D A L B E A R   ·   E A R T H   D E F E N S E", 14, UIKit.MINT)
	eng.position = Vector2(4, 206)
	_content.add_child(eng)

	var line := ColorRect.new()
	line.color = Color(0.85, 0.68, 0.35, 0.65)
	line.position = Vector2(4, 238)
	line.size = Vector2(390, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(line)

	var story := UIKit.label(
		"달빛을 먹고 자란 곰, 달베어.\n외계 함대가 지구를 덮친 밤, 홀로 숲을 지킨다.",
		17, Color(0.78, 0.82, 0.85)
	)
	story.position = Vector2(4, 256)
	story.add_theme_constant_override("line_spacing", 8)
	_content.add_child(story)

	var goal := UIKit.label("스무 개의 전선을 지켜내면 태초의 새벽이 온다", 17, UIKit.GOLD)
	goal.position = Vector2(4, 320)
	_content.add_child(goal)

	var fronts := UIKit.label("20 FRONTS  ·  4 DIFFICULTIES  ·  BOSS AT 02:50", 13, UIKit.MUTED)
	fronts.position = Vector2(4, 344)
	_content.add_child(fronts)

	var buttons := HBoxContainer.new()
	buttons.position = Vector2(0, 380)
	buttons.add_theme_constant_override("separation", 10)
	_content.add_child(buttons)
	_button_row = buttons
	var start := UIKit.button("모험 시작", Vector2(200, 60))
	start.add_theme_font_size_override("font_size", 24)
	start.pressed.connect(_start)
	start.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(start)
	_start_btn = start
	var friends_btn := UIKit.button("친구들", Vector2(110, 60))
	friends_btn.add_theme_font_size_override("font_size", 18)
	friends_btn.pressed.connect(_open_characters)
	friends_btn.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(friends_btn)
	var equipment_btn := UIKit.button("장비", Vector2(110, 60))
	equipment_btn.add_theme_font_size_override("font_size", 18)
	equipment_btn.pressed.connect(_open_equipment)
	equipment_btn.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(equipment_btn)
	var gacha_btn := UIKit.button("소환", Vector2(90, 60))
	gacha_btn.add_theme_font_size_override("font_size", 18)
	gacha_btn.pressed.connect(_open_gacha)
	gacha_btn.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(gacha_btn)
	var settings_btn := UIKit.button("설정", Vector2(100, 60))
	settings_btn.add_theme_font_size_override("font_size", 18)
	settings_btn.pressed.connect(_open_settings)
	settings_btn.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(settings_btn)
	var quit := UIKit.button("종료", Vector2(130, 60))
	quit.add_theme_font_size_override("font_size", 18)
	quit.pressed.connect(_quit)
	quit.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	buttons.add_child(quit)
	start.grab_focus()

	_new_run_btn = UIKit.button("새 모험", Vector2(140, 30))
	_new_run_btn.add_theme_font_size_override("font_size", 13)
	_new_run_btn.position = Vector2(4, 446)
	_new_run_btn.pressed.connect(_new_adventure)
	_new_run_btn.mouse_entered.connect(func(): Audio.play("click", 1.3, -14.0))
	_new_run_btn.visible = false
	_content.add_child(_new_run_btn)

	_continue_info = UIKit.label("", 12, UIKit.MUTED)
	_continue_info.position = Vector2(4, 486)
	_continue_info.size = Vector2(600, 18)
	_continue_info.visible = false
	_content.add_child(_continue_info)

	var record := UIKit.label(Game.record_text(), 15, UIKit.MINT)
	record.position = Vector2(4, 462)
	_content.add_child(record)
	_record_label = record

	var hint := UIKit.label("이동 WASD / 방향키   대시 Space   궁극기 Q   장비 I   친구들 C", 13, UIKit.MUTED)
	hint.position = Vector2(4, 496)
	_content.add_child(hint)
	_hint_label = hint

	# top-right invasion ticker
	var ticker := UIKit.panel(Color(0.12, 0.035, 0.045, 0.75), Color(0.9, 0.3, 0.3, 0.6), 1)
	UIKit.place(ticker, 1024, 26, 228, 34)
	add_child(ticker)
	_ticker = ticker
	var dot := ColorRect.new()
	dot.color = Color(1.0, 0.25, 0.25, 1)
	dot.position = Vector2(12, 14)
	dot.size = Vector2(6, 6)
	ticker.add_child(dot)
	_warning = UIKit.label("외계 함대 접근 중", 13, Color(1.0, 0.62, 0.56))
	_warning.position = Vector2(26, 7)
	ticker.add_child(_warning)

	# bottom branding
	var domain := UIKit.label("dalbear.com", 17, UIKit.GOLD)
	domain.position = Vector2(96, 664)
	add_child(domain)
	_domain = domain
	var credits := UIKit.label("무료 에셋  Kenney (CC0)  ·  Galmuri 폰트 (OFL)  ·  Godot 4.7", 12, UIKit.MUTED)
	credits.position = Vector2(96, 690)
	add_child(credits)
	_credits = credits
	var version_text := String(ProjectSettings.get_setting("application/config/version", "1.0"))
	var version := UIKit.label("v%s  ·  MOONLIT EARTH" % version_text, 12, Color(0.5, 0.58, 0.66))
	version.position = Vector2(1030, 690)
	version.size = Vector2(220, 20)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(version)
	_version = version

	_settings_panel = SettingsPanel.new()
	add_child(_settings_panel)
	_refresh_continue()

	# intro animation (fade only; positioning is handled by _fit_title)
	_content.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_content, "modulate:a", 1.0, 0.7).set_delay(0.1)


func _fit_title() -> void:
	var vp := get_viewport_rect().size
	var portrait := vp.y > vp.x
	if portrait:
		# The key art is wide: keep the bear and moon visible by showing the
		# right side of the illustration, and fit all six menu buttons inside
		# the narrow screen instead of letting the row run off the edge.
		var s := minf((vp.x - 48.0) / 780.0, 1.25)
		_content.scale = Vector2(s, s)
		var cover := vp.y / 720.0
		var bear_top := 390.0 * cover
		var max_y := bear_top - 560.0 * s - 20.0
		var content_y := maxf(48.0, max_y)
		_content.position = Vector2(maxf(16.0, (vp.x - 780.0 * s) * 0.5), content_y)
		var art_w := 1280.0 * cover
		_bg.size = Vector2(art_w, vp.y)
		_bg.position = Vector2(vp.x * 0.70 - 1010.0 * cover, 0.0)
		_bg.scale = Vector2.ONE
		_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		if _fireflies != null:
			_fireflies.position = Vector2(vp.x * 0.62, vp.y * 0.60)
		if _hint_label != null:
			_hint_label.visible = false
			_hint_label.position.y = 552.0
		if _continue_info != null:
			_continue_info.position.y = 500.0
		if _record_label != null:
			_record_label.position.y = 530.0
		var has_run := _new_run_btn != null and _new_run_btn.visible
		if _button_row != null:
			_button_row.position.y = 360.0 if has_run else 380.0
		if _new_run_btn != null:
			if has_run:
				_new_run_btn.custom_minimum_size = Vector2(170, 50)
				_new_run_btn.position = Vector2(4, 430)
				_new_run_btn.add_theme_font_size_override("font_size", 14)
			else:
				_new_run_btn.custom_minimum_size = Vector2(140, 36)
				_new_run_btn.position = Vector2(4, 446)
				_new_run_btn.add_theme_font_size_override("font_size", 15)
	else:
		var row_w := 790.0
		if _button_row != null:
			row_w = maxf(row_w, _button_row.get_combined_minimum_size().x)
		var s := clampf(minf(vp.y / 720.0, (vp.x * 0.72 - 96.0) / row_w), 0.65, 2.4)
		_content.scale = Vector2(s, s)
		_content.position = Vector2(96.0 * s, maxf(24.0, (vp.y - 560.0 * s) * 0.5))
		_bg.position = Vector2.ZERO
		_bg.size = vp
		_bg.scale = Vector2.ONE
		_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		if _fireflies != null:
			_fireflies.position = Vector2(640, 380)
		if _hint_label != null:
			_hint_label.visible = true
		if _button_row != null:
			_button_row.position.y = 380.0
		if _new_run_btn != null:
			_new_run_btn.custom_minimum_size = Vector2(140, 36)
			_new_run_btn.position = Vector2(4, 446)
			_new_run_btn.add_theme_font_size_override("font_size", 15)
	if _ticker != null:
		_ticker.position = Vector2(vp.x - 256.0, 26)
	if _domain != null:
		_domain.position = Vector2(maxf(24.0, _content.position.x), vp.y - 56.0)
	if _credits != null:
		_credits.position = Vector2(maxf(24.0, _content.position.x), vp.y - 30.0)
	if _version != null:
		_version.position = Vector2(vp.x - 260.0, vp.y - 30.0)
		_version.size = Vector2(240, 20)


func _build_fireflies() -> void:
	var p := CPUParticles2D.new()
	_fireflies = p
	p.texture = load("res://assets/art/fx/firefly.png")
	p.position = Vector2(640, 380)
	p.amount = 55
	p.lifetime = 7.0
	p.preprocess = 5.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 420.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 10.0
	p.gravity = Vector2(0, -1.5)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.5
	p.color = Color(1, 0.85, 0.5, 0.7)
	p.local_coords = false
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = mat
	add_child(p)


func _process(delta: float) -> void:
	_time += delta
	if _warning != null:
		_warning.modulate.a = 0.55 + 0.45 * absf(sin(_time * 2.0))


func _start() -> void:
	if _starting:
		return
	if Game.has_run_checkpoint():
		_continue_run()
	else:
		_new_adventure()


func _continue_run() -> void:
	if _starting:
		return
	_starting = true
	Audio.play_click()
	if not Game.resume_run_checkpoint():
		_starting = false
		_refresh_continue()


func _new_adventure() -> void:
	if _starting:
		return
	_starting = true
	Audio.play_click()
	Game.clear_run_checkpoint()
	Game.go_stage_select()


func _refresh_continue() -> void:
	var has_run := Game.has_run_checkpoint()
	if _start_btn != null:
		_start_btn.text = "이어하기" if has_run else "모험 시작"
	if _new_run_btn != null:
		_new_run_btn.visible = has_run
	if _continue_info != null:
		_continue_info.visible = has_run
		_continue_info.text = "이어서  %s" % Game.run_checkpoint_summary() if has_run else ""
	if _record_label != null:
		if get_viewport_rect().size.y > get_viewport_rect().size.x:
			_record_label.position.y = 530.0
		else:
			_record_label.position.y = 506.0 if has_run else 462.0
	if _hint_label != null:
		if get_viewport_rect().size.y > get_viewport_rect().size.x:
			_hint_label.position.y = 552.0
		else:
			_hint_label.position.y = 536.0 if has_run else 496.0


func _quit() -> void:
	Audio.play_click()
	get_tree().quit()


func _refresh_input_hint() -> void:
	if _hint_label == null:
		return
	if Input.get_connected_joypads().size() > 0:
		_hint_label.text = "스틱/D-PAD 선택  ·  A 확인  ·  B 뒤로  ·  START 일시정지"
	else:
		_hint_label.text = "이동 WASD / 방향키   대시 Space   궁극기 Q   장비 I   친구 C"


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_input_hint()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _settings_panel != null and _settings_panel.visible:
			_settings_panel.close()
		else:
			_quit()


func _open_settings() -> void:
	if _settings_panel != null:
		_settings_panel.open()


func _open_equipment() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_equipment("title")


func _open_gacha() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_gacha("title")


func _open_characters() -> void:
	if _starting:
		return
	Audio.play_click()
	Game.go_characters("title")


func _unhandled_input(event: InputEvent) -> void:
	if _settings_panel != null and _settings_panel.visible:
		return
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			_start()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			_open_equipment()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_open_characters()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_start()
			get_viewport().set_input_as_handled()


func _capture_settings() -> void:
	await get_tree().create_timer(1.0, true, false, true).timeout
	if _settings_panel != null:
		_settings_panel.open()
	await get_tree().create_timer(0.4, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "settings" + ("_portrait" if get_viewport_rect().size.y > get_viewport_rect().size.x else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _test_settings() -> void:
	await get_tree().create_timer(0.5, true, false, true).timeout
	var original := Settings.bloom
	var original_numbers := Settings.damage_numbers
	_settings_panel.open()
	_settings_panel._on_toggle(not original, "bloom")
	var target := not original
	if Settings.bloom != target:
		push_error("SETTINGS TEST: toggle did not update value")
		get_tree().quit()
		return
	if String(_settings_panel._buttons["bloom"].text) != ("켜짐" if target else "꺼짐"):
		push_error("SETTINGS TEST: toggle label not updated")
		get_tree().quit()
		return
	Settings.load_settings()
	if Settings.bloom != target:
		push_error("SETTINGS TEST: value did not persist")
		get_tree().quit()
		return
	Settings.set_option("bloom", original)
	var old_quality := Settings.get_choice("quality")
	_settings_panel._on_choice("quality", "low")
	if Settings.get_choice("quality") != "low":
		push_error("SETTINGS TEST: quality choice did not update")
		get_tree().quit()
		return
	Settings.load_settings()
	if Settings.get_choice("quality") != "low":
		push_error("SETTINGS TEST: quality choice did not persist")
		Settings.set_choice("quality", old_quality)
		get_tree().quit()
		return
	_settings_panel._switch_tab("controls")
	if _settings_panel._tab != "controls" or not _settings_panel._buttons.has("haptics") \
			or not _settings_panel._choice_buttons.has("haptic_strength"):
		push_error("SETTINGS TEST: controls tab did not build")
		get_tree().quit()
		return
	_settings_panel._switch_tab("access")
	if _settings_panel._tab != "access" or not _settings_panel._buttons.has("high_contrast") \
			or not _settings_panel._choice_buttons.has("colorblind"):
		push_error("SETTINGS TEST: accessibility tab did not build")
		get_tree().quit()
		return
	_settings_panel._switch_tab("account")
	if _settings_panel._tab != "account" or _settings_panel._account_status == null \
			or not _settings_panel._account_buttons.has("sign_in"):
		push_error("SETTINGS TEST: account tab did not build")
		get_tree().quit()
		return
	_settings_panel._switch_tab("display")
	if _settings_panel._tab != "display" or not _settings_panel._buttons.has("bloom"):
		push_error("SETTINGS TEST: display tab did not restore")
		get_tree().quit()
		return
	_settings_panel._on_choice("quality", old_quality)
	Settings.set_option("bloom", original)
	Settings.set_option("damage_numbers", original_numbers)
	print("SETTINGS TEST OK bloom=", target, " persisted and restored=", original,
		" quality_restored=", Settings.get_choice("quality"))
	get_tree().quit()


func _test_title_layout() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	var errors: Array = []
	var vp := get_viewport_rect().size
	if _button_row == null:
		errors.append("button row missing")
	else:
		var row := _button_row.get_global_rect()
		if row.position.x < -2.0 or row.end.x > vp.x + 2.0:
			errors.append("row x %.1f..%.1f vp %.1f" % [row.position.x, row.end.x, vp.x])
		if row.position.y < -2.0 or row.end.y > vp.y + 2.0:
			errors.append("row y %.1f..%.1f vp %.1f" % [row.position.y, row.end.y, vp.y])
		for child in _button_row.get_children():
			var button := child as Control
			if button == null:
				continue
			var rect := button.get_global_rect()
			if rect.position.x < -2.0 or rect.end.x > vp.x + 2.0:
				errors.append("button %s x %.1f..%.1f" % [button.name, rect.position.x, rect.end.x])
	if errors.is_empty():
		print("TITLE LAYOUT PASS vp=%s scale=%.3f" % [str(vp), _content.scale.x])
		get_tree().quit()
		return
	push_error("TITLE LAYOUT FAIL vp=%s %s" % [str(vp), str(errors)])
	get_tree().quit(1)


func _test_title_continue() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	var has_checkpoint := Game.has_run_checkpoint()
	var continue_text := _start_btn.text if _start_btn != null else ""
	var new_run_visible := _new_run_btn != null and _new_run_btn.visible
	print("TITLE CONTINUE TEST checkpoint=%s text=%s new_run=%s summary=%s" % [
		has_checkpoint, continue_text, new_run_visible, Game.run_checkpoint_summary(),
	])
	Game.clear_run_checkpoint()
	if not has_checkpoint or continue_text != "이어하기" or not new_run_visible:
		push_error("TITLE CONTINUE TEST FAILED")
		get_tree().quit(1)
		return
	print("TITLE CONTINUE TEST OK")
	get_tree().quit()


func _test_title_resume() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	if not Game.has_run_checkpoint():
		push_error("TITLE RESUME TEST: no checkpoint")
		get_tree().quit(1)
		return
	print("TITLE RESUME TEST continue ", Game.run_checkpoint_summary())
	Audio.play_click()
	Game.resume_run_checkpoint()


func _capture() -> void:
	await get_tree().create_timer(1.2, true, false, true).timeout
	await get_tree().process_frame
	var shot := "title"
	var view := get_viewport_rect().size
	if view.y > view.x:
		shot += "_portrait"
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()
