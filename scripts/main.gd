extends Node2D

## Builds a run: battlefield, player, camera, post FX, HUD and overlays.

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const WORLD_SCRIPT := preload("res://scripts/world.gd")
const MANAGER_SCRIPT := preload("res://scripts/enemy_manager.gd")
const CAMERA_SCRIPT := preload("res://scripts/camera.gd")
const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")
const OVERLAY_SCRIPT := preload("res://scripts/ui/overlay.gd")
const TOUCH_SCRIPT := preload("res://scripts/ui/touch_controls.gd")

var player
var world
var manager
var camera: Camera2D
var hud
var overlay
var touch_controls
var post_mat: ShaderMaterial
var canvas_mod: CanvasModulate

var _end_shown := false
var _levelup_pending := false
var _fade: ColorRect
var _args: PackedStringArray


func _ready() -> void:
	randomize()
	_args = OS.get_cmdline_user_args()
	for a in _args:
		if a.begins_with("--stage="):
			var sid := a.substr(8)
			if GameData.STAGES.has(sid):
				Game.stage_id = sid
		elif a.begins_with("--diff="):
			var did := a.substr(7)
			if GameData.DIFFICULTIES.has(did):
				Game.difficulty_id = did
		elif a.begins_with("--friend="):
			var fid := a.substr(9)
			if CharacterData.CHARACTERS.has(fid):
				Game.select_character(fid)
	if "--capture-boss" in _args or "--capture-final" in _args:
		Game.stage_id = "ship"
	elif "--capture-queen" in _args:
		Game.stage_id = "hive"
	elif "--capture-hive" in _args:
		Game.stage_id = "hive"
	elif "--capture-ship" in _args:
		Game.stage_id = "ship"
	Game.begin_run()
	Game.levelup_open = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_build_world()
	_build_player()
	_build_camera()
	_build_post()
	_build_ui()
	_build_touch()
	_build_fade()
	Game.run_ended.connect(_on_run_ended)
	Game.level_up_requested.connect(_on_level_up_requested)
	Game.warning.connect(hud.show_warning)
	var stage := Game.stage_data()
	Game.warning.emit("%s · %s — %s" % [String(stage["name"]), String(stage["short"]), String(stage["subtitle"])], 4.5)
	Audio.set_music_volume(-16.0, 2.0)
	Audio.set_music_pitch(float(stage.get("music_pitch", 1.0)))
	if "--capture-game" in _args:
		_capture_game()
	elif "--capture-base" in _args:
		_capture_base()
	elif "--capture-boss" in _args or "--capture-final" in _args:
		_capture_boss()
	elif "--capture-queen" in _args:
		_capture_queen()
	elif "--capture-hive" in _args:
		_capture_game()
	elif "--capture-ship" in _args:
		_capture_game()
	elif "--capture-levelup" in _args:
		_capture_levelup()
	elif "--capture-rewards" in _args:
		_capture_rewards()
	elif "--capture-banish" in _args:
		_capture_banish()
	elif "--test-reroll-banish" in _args:
		_test_reroll_banish()
	elif "--test-settings-effects" in _args:
		_test_settings_effects()
	elif "--test-settings-close" in _args:
		_test_settings_close()
	elif "--test-equipment-run" in _args:
		_test_equipment_run()
	elif "--test-touch" in _args:
		_test_touch()
	elif "--capture-pause" in _args:
		_capture_pause()
	elif "--capture-pause-settings" in _args:
		_capture_pause_settings()
	elif "--capture-victory" in _args:
		_capture_end(true)
	elif "--capture-defeat" in _args:
		_capture_end(false)
	elif "--capture-death" in _args:
		_capture_death()
	elif "--capture-timer" in _args:
		_capture_timer_victory()
	elif "--capture-clear" in _args:
		_capture_boss_clear()
	elif "--test-patterns" in _args:
		_test_patterns()
	elif "--test-upgrade" in _args:
		_test_upgrade()
	elif "--capture-evolution" in _args:
		_capture_evolution()
	elif "--capture-evolution-gameplay" in _args:
		_capture_evolution_gameplay()
	elif "--capture-abilities" in _args:
		_capture_abilities()
	elif "--test-abilities" in _args:
		_test_abilities()
	for a in _args:
		if a.begins_with("--evolution-test="):
			_test_evolution(a.substr(17))
	if "--smoke-start" in _args:
		await get_tree().create_timer(2.5, true, false, true).timeout
		print("SMOKE START OK")
		get_tree().quit()


func _build_world() -> void:
	world = WORLD_SCRIPT.new()
	world.name = "World"
	add_child(world)
	world.build(Game.stage_id)

	manager = MANAGER_SCRIPT.new()
	manager.name = "EnemyManager"
	manager.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(manager)

	canvas_mod = CanvasModulate.new()
	canvas_mod.color = Game.stage_data()["tint"]
	add_child(canvas_mod)


func _build_player() -> void:
	player = PLAYER_SCENE.instantiate()
	world.actors.add_child(player)
	player.global_position = Vector2.ZERO
	manager.setup(player, world.actors, world.projectiles, world.pickups)
	player.setup(manager)
	world.target = player


func _build_camera() -> void:
	camera = Camera2D.new()
	camera.set_script(CAMERA_SCRIPT)
	camera.name = "Camera"
	camera.limit_left = -int(GameData.ARENA_HALF)
	camera.limit_right = int(GameData.ARENA_HALF)
	camera.limit_top = -int(GameData.ARENA_HALF)
	camera.limit_bottom = int(GameData.ARENA_HALF)
	camera.limit_smoothed = true
	add_child(camera)
	camera.set_target(player)
	camera.global_position = player.global_position


func _build_post() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PostFX"
	layer.layer = 8
	add_child(layer)
	var rect := ColorRect.new()
	rect.name = "PostRect"
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	post_mat = ShaderMaterial.new()
	post_mat.shader = load("res://assets/shaders/post_fx.gdshader")
	rect.material = post_mat
	layer.add_child(rect)
	FX.setup(camera, world.fx_root, world.damage_root, world.decals, post_mat)


func _build_ui() -> void:
	hud = HUD_SCRIPT.new()
	hud.layer = 20
	add_child(hud)
	hud.bind(player, manager, world)

	overlay = OVERLAY_SCRIPT.new()
	overlay.layer = 30
	add_child(overlay)
	overlay.bind(player, hud)

	Game.xp_changed.emit(Game.xp, Game.xp_need, Game.level)
	Game.kills_changed.emit(Game.kills)


func _build_touch() -> void:
	var forced := "--touch" in _args
	var available := OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	if not forced and not available:
		return
	var layer := CanvasLayer.new()
	layer.name = "TouchControls"
	layer.layer = 25
	add_child(layer)
	touch_controls = TOUCH_SCRIPT.new()
	layer.add_child(touch_controls)
	touch_controls.bind(player, overlay)
	touch_controls.set_active(true)
	player.touch_controls = touch_controls
	if hud != null and hud.has_method("set_touch_mode"):
		hud.set_touch_mode(true)


func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 40
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0.02, 0.03, 0.05, 1.0)
	_fade.anchor_right = 1.0
	_fade.anchor_bottom = 1.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_callback(layer.queue_free)


func _exit_tree() -> void:
	FX.teardown()


func _process(delta: float) -> void:
	if player != null and is_instance_valid(player):
		var st := Game.stage_data()
		var p := clampf(Game.time / float(st["duration"]), 0.0, 1.0)
		var base: Color = st["tint"]
		canvas_mod.color = base.lerp(Color(1.14, 1.0, 0.86), pow(p, 2.8) * 0.4)
		if hud != null and hud.has_method("tick"):
			hud.tick(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if overlay == null or not Game.running:
			return
		if overlay.is_blocking():
			return
		overlay.toggle_pause()
		get_viewport().set_input_as_handled()


func _on_level_up_requested() -> void:
	if _levelup_pending or overlay == null:
		return
	_levelup_pending = true
	player.invuln = maxf(player.invuln, 1.0)
	FX.levelup_burst(player.global_position + Vector2(0, -10))
	FX.flash(Color(1.0, 0.9, 0.6), 0.28, 0.6)
	Audio.play("levelup", 1.0, -2.0)
	Audio.duck_music(true)
	await get_tree().create_timer(0.32, true, false, true).timeout
	_levelup_pending = false
	if not Game.running:
		return
	get_tree().paused = true
	overlay.show_levelup(player.get_upgrade_choices(3))


func _on_run_ended(victory: bool, boss_killed: bool) -> void:
	if _end_shown:
		return
	_end_shown = true
	Engine.time_scale = 1.0
	Audio.duck_music(true)
	if victory:
		Audio.play("victory", 1.0, -2.0)
		FX.levelup_burst(player.global_position)
		FX.flash(Color(1.0, 0.95, 0.75), 0.55, 1.2)
		FX.grade(Color(0.9, 0.75, 0.5), 0.2, 2.0)
		FX.shake(8.0, 0.6)
	await get_tree().create_timer(1.6 if victory else 1.2, true, false, true).timeout
	get_tree().paused = true
	overlay.show_end(victory, boss_killed)


func _capture_abilities() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	player.ultimate_charge = player.ultimate_max
	Game.levelup_open = true
	var kinds := ["blob", "drone", "grey", "blob", "jelly", "drone", "blob", "grey", "jelly", "blob"]
	for i in kinds.size():
		var a := TAU * float(i) / float(kinds.size()) + 0.1
		manager.spawn_enemy(kinds[i], player.global_position + Vector2.from_angle(a) * (150.0 + (i % 3) * 40.0), false)
	await get_tree().create_timer(0.4, true, false, true).timeout
	player._try_dash(Vector2.RIGHT)
	await get_tree().create_timer(0.12, true, false, true).timeout
	player._try_ultimate()
	await get_tree().create_timer(0.35, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("abilities")


func _test_abilities() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	player.ultimate_charge = player.ultimate_max
	Game.levelup_open = true
	for i in 8:
		var a := TAU * float(i) / 8.0
		manager.spawn_enemy("blob", player.global_position + Vector2.from_angle(a) * 160.0, false)
	await get_tree().create_timer(0.3, true, false, true).timeout
	player._try_dash(Vector2.RIGHT)
	await get_tree().create_timer(0.1, true, false, true).timeout
	player._try_ultimate()
	await get_tree().create_timer(2.0, true, false, true).timeout
	print("ABILITY TEST OK dash_cd=", player.dash_cd, " charge=", player.ultimate_charge,
		" kills=", Game.kills, " enemies=", manager.enemies.size())
	get_tree().quit()


func _capture_evolution() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	_setup_evolution("moon_shot", "core")
	Game.add_xp(12)
	await get_tree().create_timer(1.0, true, false, true).timeout
	await _capture("evolution")


func _capture_evolution_gameplay() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	_setup_evolution("moon_shot", "core")
	Game.add_xp(12)
	await get_tree().create_timer(1.0, true, false, true).timeout
	if overlay != null and overlay.is_blocking():
		overlay._choose(0)
	await get_tree().create_timer(0.5, true, false, true).timeout
	for i in 9:
		var a := TAU * float(i) / 9.0 + 0.2
		manager.spawn_enemy("blob", player.global_position + Vector2.from_angle(a) * 170.0, i == 8)
	await get_tree().create_timer(2.4, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("evolution_gameplay")


func _setup_evolution(base_id: String, passive_id: String) -> void:
	if not player.weapon_levels.has(base_id):
		player.add_weapon(base_id)
	while int(player.weapon_levels.get(base_id, 0)) < 6:
		player.upgrade_weapon(base_id)
	player.passive_levels[passive_id] = maxi(3, int(player.passive_levels.get(passive_id, 0)))
	player.recalc_stats()
	player.check_evolution_ready()


func _test_evolution(which: String) -> void:
	var base := "moon_shot"
	var passive := "core"
	match which:
		"orbit":
			base = "satellite"
			passive = "coolant"
		"gravity":
			base = "pulse"
			passive = "armor"
		"nebula":
			base = "laser"
			passive = "star"
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	_setup_evolution(base, passive)
	Game.add_xp(12)
	await get_tree().create_timer(1.0, true, false, true).timeout
	if overlay == null or not overlay.is_blocking():
		push_error("EVOLUTION TEST: overlay did not open")
		get_tree().quit()
		return
	overlay._choose(0)
	await get_tree().create_timer(0.6, true, false, true).timeout
	for i in 6:
		var a := TAU * float(i) / 6.0
		manager.spawn_enemy("blob", player.global_position + Vector2.from_angle(a) * 150.0, false)
	await get_tree().create_timer(2.5, true, false, true).timeout
	print("EVOLUTION TEST OK base=", base, " evolutions=", player.evolutions,
		" weapons=", player.weapon_levels, " passives=", player.passive_levels)
	get_tree().quit()


func _capture_game() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.add_weapon("satellite")
	player.add_weapon("pulse")
	player.add_weapon("laser")
	for i in 3:
		player.upgrade_weapon("moon_shot")
	player.upgrade_weapon("satellite")
	player.upgrade_weapon("laser")
	Game.time = 143.0
	Game.kills = 87
	Game.level = 9
	Game.xp = 34
	Game.xp_need = 61
	Game.kills_changed.emit(Game.kills)
	Game.xp_changed.emit(Game.xp, Game.xp_need, Game.level)
	var kinds := ["blob", "blob", "drone", "drone", "grey", "jelly", "blob", "drone", "grey", "jelly", "blob", "mech"]
	if Game.stage_id == "hive":
		kinds = ["spitter", "bomber", "burrower", "spitter", "blob", "drone", "spitter", "bomber", "brute", "spitter", "burrower", "blob"]
	elif Game.stage_id == "ship":
		kinds = ["sentinel", "phase", "splitter", "drone", "grey", "phase", "sentinel", "splitter", "mech", "phase", "sentinel", "drone"]
	for i in kinds.size():
		var a := TAU * float(i) / float(kinds.size()) + 0.2
		var d := 235.0 + (i % 5) * 36.0
		manager.spawn_enemy(kinds[i], player.global_position + Vector2.from_angle(a) * d, i == 10)
	await get_tree().create_timer(2.0, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	player.invuln = 999.0
	await get_tree().create_timer(0.5, true, false, true).timeout
	var shot := "gameplay" if Game.stage_id == "forest" else "stage_" + Game.stage_id
	if "--touch" in _args:
		shot = "touch_gameplay"
	await _capture(shot)


func _capture_base() -> void:
	await get_tree().create_timer(1.0, true, false, true).timeout
	var kinds := ["blob", "blob", "drone", "grey", "blob", "drone", "jelly", "blob"]
	for i in kinds.size():
		var a := TAU * float(i) / float(kinds.size()) + 0.4
		var d := 150.0 + (i % 3) * 45.0
		manager.spawn_enemy(kinds[i], player.global_position + Vector2.from_angle(a) * d, false)
	await get_tree().create_timer(1.6, true, false, true).timeout
	await _capture("base")


func _capture_boss() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.add_weapon("satellite")
	player.add_weapon("pulse")
	player.add_weapon("laser")
	for i in 5:
		player.upgrade_weapon("moon_shot")
		player.upgrade_weapon("laser")
	Game.time = 178.0
	Game.level = 18
	Game.kills = 420
	Game.xp = 40
	Game.xp_need = 101
	Game.kills_changed.emit(Game.kills)
	Game.xp_changed.emit(Game.xp, Game.xp_need, Game.level)
	manager.boss_spawned = true
	var pos: Vector2 = player.global_position + Vector2(0, -170)
	manager.spawn_enemy("boss_final", pos, false)
	await get_tree().create_timer(1.4, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await get_tree().create_timer(1.2, true, false, true).timeout
	await _capture("boss")


func _capture_queen() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.add_weapon("satellite")
	player.add_weapon("pulse")
	player.add_weapon("laser")
	for i in 5:
		player.upgrade_weapon("moon_shot")
		player.upgrade_weapon("laser")
	Game.time = 178.0
	Game.level = 18
	Game.kills = 380
	Game.xp = 40
	Game.xp_need = 101
	Game.kills_changed.emit(Game.kills)
	Game.xp_changed.emit(Game.xp, Game.xp_need, Game.level)
	manager.boss_spawned = true
	var pos: Vector2 = player.global_position + Vector2(0, -160)
	manager.spawn_enemy("boss_queen", pos, false)
	await get_tree().create_timer(1.4, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await get_tree().create_timer(1.2, true, false, true).timeout
	await _capture("queen")


func _capture_levelup() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	Game.add_xp(40)
	await get_tree().create_timer(0.7, true, false, true).timeout
	await _capture("levelup")


func _capture_rewards() -> void:
	await get_tree().create_timer(0.9, true, false, true).timeout
	player.invuln = 999.0
	Game.time = 216.0
	Game.level = 18
	Game.kills = 420
	Game.end_run(true, true)
	await get_tree().create_timer(2.0, true, false, true).timeout
	await _capture("rewards")


func _capture_banish() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	Game.add_xp(40)
	await get_tree().create_timer(0.7, true, false, true).timeout
	if overlay != null and overlay.is_blocking():
		overlay._toggle_banish()
	await get_tree().create_timer(0.35, true, false, true).timeout
	await _capture("banish")


func _test_reroll_banish() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	player.invuln = 999.0
	Game.add_xp(40)
	await get_tree().create_timer(1.0, true, false, true).timeout
	if overlay == null or not overlay.is_blocking():
		push_error("REROLL BANISH TEST: overlay did not open")
		get_tree().quit()
		return
	var rerolls_before: int = Game.rerolls
	overlay._reroll()
	await get_tree().create_timer(0.3, true, false, true).timeout
	if Game.rerolls != rerolls_before - 1:
		push_error("REROLL BANISH TEST: reroll count wrong")
		get_tree().quit()
		return
	var target_idx := -1
	for i in overlay._choices.size():
		var kind := String(overlay._choices[i].get("kind", ""))
		if kind in ["weapon", "passive", "evolution"]:
			target_idx = i
			break
	if target_idx < 0:
		push_error("REROLL BANISH TEST: no bannable card")
		get_tree().quit()
		return
	var target_id := String(overlay._choices[target_idx].get("id", ""))
	var banishes_before: int = Game.banishes
	overlay._toggle_banish()
	if not overlay._banish_mode:
		push_error("REROLL BANISH TEST: banish mode did not open")
		get_tree().quit()
		return
	overlay._banish(target_idx)
	await get_tree().create_timer(0.3, true, false, true).timeout
	if Game.banishes != banishes_before - 1:
		push_error("REROLL BANISH TEST: banish count wrong")
		get_tree().quit()
		return
	if not player.banned.has(target_id):
		push_error("REROLL BANISH TEST: player.banned missing ", target_id)
		get_tree().quit()
		return
	for c in overlay._choices:
		if String(c.get("id", "")) == target_id:
			push_error("REROLL BANISH TEST: banned card still offered ", target_id)
			get_tree().quit()
			return
	print("REROLL BANISH TEST OK target=", target_id, " banned=", player.banned,
		" rerolls=", Game.rerolls, " banishes=", Game.banishes,
		" choices=", overlay._choices.size())
	get_tree().quit()


func _capture_pause() -> void:
	await get_tree().create_timer(0.9, true, false, true).timeout
	Game.time = 142.0
	Game.level = 9
	Game.kills = 88
	overlay.toggle_pause()
	await get_tree().create_timer(0.4, true, false, true).timeout
	await _capture("pause")


func _capture_pause_settings() -> void:
	await get_tree().create_timer(0.9, true, false, true).timeout
	Game.time = 142.0
	Game.level = 9
	Game.kills = 88
	overlay.toggle_pause()
	await get_tree().create_timer(0.3, true, false, true).timeout
	overlay._settings_panel.open()
	await get_tree().create_timer(0.4, true, false, true).timeout
	await _capture("pause_settings")


func _test_settings_effects() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	var old_bloom: bool = Settings.bloom
	var old_shake: bool = Settings.shake
	var old_numbers: bool = Settings.damage_numbers

	Settings.set_option("bloom", false)
	await get_tree().process_frame
	await get_tree().process_frame
	var bloom_value = post_mat.get_shader_parameter("bloom_strength")
	if not is_equal_approx(float(bloom_value), 0.0):
		push_error("SETTINGS EFFECTS: bloom not disabled: ", bloom_value)
		_restore_settings(old_bloom, old_shake, old_numbers)
		get_tree().quit()
		return

	FX._shake_amp = 0.0
	FX._shake_time = 0.0
	Settings.set_option("shake", false)
	FX.shake(10.0, 1.0)
	if FX._shake_amp > 0.0:
		push_error("SETTINGS EFFECTS: shake not disabled")
		_restore_settings(old_bloom, old_shake, old_numbers)
		get_tree().quit()
		return

	var before := 0
	if FX.damage_root != null and is_instance_valid(FX.damage_root):
		before = FX.damage_root.get_child_count()
	Settings.set_option("damage_numbers", false)
	FX.damage_number(player.global_position + Vector2(0, -30), 123.0, Color.WHITE, true)
	var after := 0
	if FX.damage_root != null and is_instance_valid(FX.damage_root):
		after = FX.damage_root.get_child_count()
	if after != before:
		push_error("SETTINGS EFFECTS: damage number was created while disabled")
		_restore_settings(old_bloom, old_shake, old_numbers)
		get_tree().quit()
		return

	_restore_settings(old_bloom, old_shake, old_numbers)
	print("SETTINGS EFFECTS TEST OK bloom=", bloom_value, " shake_amp=", FX._shake_amp,
		" damage_children=", after)
	get_tree().quit()


func _restore_settings(bloom: bool, shake: bool, numbers: bool) -> void:
	Settings.set_option("bloom", bloom)
	Settings.set_option("shake", shake)
	Settings.set_option("damage_numbers", numbers)


func _test_settings_close() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	overlay.toggle_pause()
	await get_tree().create_timer(0.3, true, false, true).timeout
	if not overlay._pause_visible:
		push_error("SETTINGS CLOSE TEST: pause did not open")
		get_tree().quit()
		return
	overlay._settings_panel.open()
	await get_tree().create_timer(0.3, true, false, true).timeout
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().create_timer(0.3, true, false, true).timeout
	if overlay._settings_panel.visible:
		push_error("SETTINGS CLOSE TEST: ESC did not close settings")
		get_tree().quit()
		return
	if not overlay._pause_visible or not get_tree().paused:
		push_error("SETTINGS CLOSE TEST: ESC resumed the game instead of returning to pause")
		get_tree().quit()
		return
	print("SETTINGS CLOSE TEST OK pause_visible=", overlay._pause_visible,
		" paused=", get_tree().paused)
	get_tree().quit()


func _test_equipment_run() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	var errors: Array = []
	if Game.equipped.size() < 11:
		errors.append("hub slots=%d" % Game.equipped.size())
	if player.max_hp <= 100.0:
		errors.append("gear max_hp not applied: %.1f" % player.max_hp)
	if player.damage_mult <= 1.0:
		errors.append("gear damage not applied: %.3f" % player.damage_mult)
	if player.weapon_levels.size() < 2:
		errors.append("two equipped weapons did not start: %s" % player.weapon_levels)
	if not player.weapon_levels.has("moon_shot"):
		errors.append("main weapon missing")
	if not player.weapon_levels.has("satellite"):
		errors.append("secondary weapon missing")
	var bonuses := Game.equipment_bonuses()
	if float(bonuses.get("damage_pct", 0.0)) <= 0.0:
		errors.append("bonus damage missing")
	if errors.is_empty():
		print("EQUIPMENT RUN TEST OK hp=%.1f damage=%.3f weapons=%s armor=%.1f crit=%.3f" % [
			player.max_hp, player.damage_mult, player.weapon_levels, player.armor, player.crit,
		])
	else:
		for error in errors:
			push_error("EQUIPMENT RUN TEST: " + String(error))
		print("EQUIPMENT RUN TEST FAILED: ", errors)
	get_tree().quit()


func _test_touch() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	if touch_controls == null:
		push_error("TOUCH TEST: controls were not created")
		get_tree().quit()
		return
	player.invuln = 999.0
	var start_x: float = player.global_position.x
	touch_controls.move_vector = Vector2(1, 0)
	await get_tree().create_timer(0.25, true, false, true).timeout
	var moved: float = player.global_position.x - start_x
	touch_controls.move_vector = Vector2.ZERO
	touch_controls._joy_origin = Vector2(640, 360)
	touch_controls._update_move(Vector2(700, 360))
	var floating_ok: bool = touch_controls.move_vector.x > 0.5
	touch_controls._joy_origin = Vector2(150, 548)
	touch_controls._knob_pos = Vector2(150, 548)
	touch_controls.move_vector = Vector2.ZERO
	player.ultimate_charge = player.ultimate_max
	touch_controls._dash_requested = true
	await get_tree().create_timer(0.1, true, false, true).timeout
	var dashed: bool = player.dash_cd > 0.0
	touch_controls._ult_requested = true
	await get_tree().create_timer(0.2, true, false, true).timeout
	var ultimate_used: bool = player.ultimate_charge <= 0.0
	if moved < 8.0:
		push_error("TOUCH TEST: joystick did not move player (%.1f)" % moved)
		get_tree().quit()
		return
	if not floating_ok:
		push_error("TOUCH TEST: floating joystick origin did not move")
		get_tree().quit()
		return
	if not dashed:
		push_error("TOUCH TEST: dash button did not trigger dash")
		get_tree().quit()
		return
	if not ultimate_used:
		push_error("TOUCH TEST: ultimate button did not consume charge")
		get_tree().quit()
		return
	print("TOUCH TEST OK moved=%.1f floating=%s dash_cd=%.2f ultimate_charge=%.1f" % [
		moved, floating_ok, player.dash_cd, player.ultimate_charge,
	])
	get_tree().quit()


func _capture_end(victory: bool) -> void:
	await get_tree().create_timer(0.9, true, false, true).timeout
	Game.time = 216.0
	Game.level = 18
	Game.kills = 420
	Game.last_boss_killed = victory
	Game.record["best_time"] = 216.0
	Game.record["best_level"] = 18
	Game.record["best_kills"] = 420
	Game.record["victory"] = victory
	Game.record_stage_result(Game.stage_id, Game.difficulty_id, victory, victory, 216.0, 18, 420)
	overlay.show_end(victory, victory)
	await get_tree().create_timer(0.5, true, false, true).timeout
	await _capture("victory" if victory else "defeat")


func _capture_death() -> void:
	await get_tree().create_timer(1.0, true, false, true).timeout
	player.invuln = 0.0
	player.hp = 1.0
	player.take_damage(999.0)
	await get_tree().create_timer(2.4, true, false, true).timeout
	await _capture("death")


func _capture_timer_victory() -> void:
	await get_tree().create_timer(1.0, true, false, true).timeout
	Game.time = 238.8
	await get_tree().create_timer(4.0, true, false, true).timeout
	await _capture("timer_victory")


func _capture_boss_clear() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.add_weapon("satellite")
	player.add_weapon("pulse")
	player.add_weapon("laser")
	for i in 4:
		player.upgrade_weapon("moon_shot")
		player.upgrade_weapon("laser")
	Game.time = 175.0
	Game.level = 16
	Game.kills = 310
	Game.kills_changed.emit(Game.kills)
	Game.xp_changed.emit(Game.xp, Game.xp_need, Game.level)
	manager.boss_spawned = true
	var pos: Vector2 = player.global_position + Vector2(0, -170)
	manager.spawn_enemy(String(Game.stage_data()["boss"]), pos, false)
	var b = Game.boss
	if b != null and is_instance_valid(b):
		b.hp = 1.0
	await get_tree().create_timer(0.8, true, false, true).timeout
	if b != null and is_instance_valid(b) and not b.dead:
		b.take_damage(999.0, true, b.global_position, 0.0)
	await get_tree().create_timer(3.6, true, false, true).timeout
	await _capture("final_clear" if Game.stage_id == "ship" else "stage_clear")


func _test_patterns() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	Game.levelup_open = true
	manager.boss_spawned = true
	Game.time = 178.0
	var kinds := ["spitter", "bomber", "burrower", "brute", "sentinel", "phase", "splitter"]
	for i in kinds.size():
		var a := TAU * float(i) / float(kinds.size())
		manager.spawn_enemy(kinds[i], player.global_position + Vector2.from_angle(a) * 210.0, false)
	var boss_kind := String(Game.stage_data()["boss"])
	manager.spawn_enemy(boss_kind, player.global_position + Vector2(0, -160), false)
	var b = Game.boss
	if b != null and is_instance_valid(b):
		b.max_hp = 99999.0
		b.hp = 99999.0
		b.set("boss_orb_cd", 0.2)
		b.set("boss_summon_cd", 0.6)
		b.set("slam_cd", 0.5)
		b.set("boss_beam_cd", 1.0)
		b.set("spiral_cd", 0.5)
	await get_tree().create_timer(8.0, true, false, true).timeout
	print("PATTERN TEST OK stage=", Game.stage_id, " enemies=", manager.enemies.size())
	get_tree().quit()


func _test_upgrade() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	Game.add_xp(40)
	await get_tree().create_timer(1.0, true, false, true).timeout
	if overlay == null or not overlay.is_blocking():
		push_error("UPGRADE TEST: overlay did not open")
		get_tree().quit()
		return
	overlay._choose(0)
	await get_tree().create_timer(0.5, true, false, true).timeout
	if overlay.is_blocking():
		overlay._choose(0)
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("UPGRADE TEST: weapons=", player.weapon_levels, " passives=", player.passive_levels,
		" paused=", get_tree().paused, " running=", Game.running)
	get_tree().quit()


func _capture(name: String) -> void:
	# Avoid frame_post_draw: it can stall when the window is occluded.
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/" + name + ".png")
	print("CAPTURED: ", dir + "/" + name + ".png")
	get_tree().quit()
