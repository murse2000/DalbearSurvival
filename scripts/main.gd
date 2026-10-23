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
var canvas_mod: Node

var _end_shown := false
var _levelup_pending := false
var _backgrounded := false
const RELIC_TIMES := [45.0, 100.0, 155.0]

var _relic_index := 0
var _checkpoint_timer := 8.0
var _dev_mode := false
var _fade: ColorRect
var _args: PackedStringArray


func _ready() -> void:
	randomize()
	_args = OS.get_cmdline_user_args()
	for a in _args:
		if a.begins_with("--capture") or a.begins_with("--test") \
				or a.begins_with("--evolution") or a.begins_with("--bench") \
				or a == "--smoke-start":
			_dev_mode = true
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
	var explicit_stage := false
	for a in _args:
		if a.begins_with("--stage="):
			explicit_stage = true
	if not explicit_stage:
		if "--capture-boss" in _args or "--capture-final" in _args:
			Game.stage_id = "ship"
		elif "--capture-queen" in _args:
			Game.stage_id = "hive"
		elif "--capture-hive" in _args:
			Game.stage_id = "hive"
		elif "--capture-ship" in _args:
			Game.stage_id = "ship"
	if "--test-checkpoint-resume" in _args:
		Game.prepare_resume_checkpoint()
	if "--endless" in _args:
		Game.mode = "endless"
	elif "--daily" in _args:
		Game.prepare_daily()
		Game.mode = "daily"
		Game.stage_id = String(Game.daily_info.get("stage", "forest"))
		Game.difficulty_id = String(Game.daily_info.get("diff", "normal"))
		Game._apply_run_mods(Game.daily_info.get("modifier", {}))
	var run_snapshot: Dictionary = Game.consume_run_snapshot()
	Game.begin_run()
	if run_snapshot.is_empty():
		Game.levelup_open = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_build_world()
	_build_player()
	if not run_snapshot.is_empty():
		_restore_run(run_snapshot)
	manager.spawn_stage_obstacles()
	_build_camera()
	_build_post()
	_build_ui()
	_build_touch()
	_build_fade()
	Game.run_ended.connect(_on_run_ended)
	Game.level_up_requested.connect(_on_level_up_requested)
	Game.warning.connect(hud.show_warning)
	if not run_snapshot.is_empty():
		_finish_restore()
	elif not _dev_mode:
		Game.save_run_checkpoint(player)
	for t in RELIC_TIMES:
		if Game.time >= float(t):
			_relic_index += 1
	var stage := Game.stage_data()
	Game.warning.emit("%s · %s — %s" % [String(stage["name"]), String(stage["short"]), String(stage["subtitle"])], 4.5)
	Audio.set_music_volume(-16.0, 2.0)
	Audio.set_music_pitch(float(stage.get("music_pitch", 1.0)))
	if "--test-checkpoint-write" in _args:
		_test_checkpoint_write()
	elif "--test-checkpoint-resume" in _args or "--test-title-resume" in _args:
		_test_checkpoint_resume()
	elif "--capture-game" in _args:
		_capture_game()
	elif "--capture-endless" in _args:
		_capture_endless()
	elif "--capture-daily" in _args:
		_capture_daily()
	elif "--capture-endless-end" in _args:
		_capture_endless_end()
	elif "--capture-base" in _args:
		_capture_base()
	elif "--capture-lighting" in _args:
		_capture_lighting()
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
	elif "--capture-combo" in _args:
		_capture_combo()
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
	elif "--test-modes" in _args:
		_test_modes()
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
	elif "--capture-new-skills" in _args:
		_capture_new_skills()
	elif "--test-new-skills" in _args:
		_test_new_skills()
	elif "--test-evolutions" in _args:
		_test_evolutions()
	elif "--test-relics" in _args:
		_test_relics()
	elif "--capture-relics" in _args:
		_capture_relics()
	elif "--test-balance" in _args:
		_test_balance()
	elif "--bench-enemies" in _args or _has_bench_arg():
		_bench_enemies()
	elif "--test-late-balance" in _args:
		_test_late_balance()
	elif "--test-world-expansion" in _args:
		_test_world_expansion()
	elif "--test-progression" in _args:
		_test_progression()
	elif "--capture-world-expansion" in _args:
		_capture_world_expansion()
	elif "--capture-crit" in _args:
		_capture_crit()
	elif "--test-enemy-projectile" in _args:
		_test_enemy_projectile()
	elif "--test-background-pause" in _args:
		_test_background_pause()
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

	canvas_mod = LightRig.create_ambient(self, _ambient_color(0.0))
	if LightRig.lit_enabled():
		# A faint cool moon fill keeps silhouettes readable while the moving
		# point lights do the dramatic work.
		var moon := LitDirectionalLight2D.new()
		moon.color = Color(0.38, 0.48, 0.82)
		moon.energy = 0.24
		moon.height = 80.0
		add_child(moon)


func _build_player() -> void:
	player = PLAYER_SCENE.instantiate()
	world.actors.add_child(player)
	player.global_position = Vector2.ZERO
	manager.setup(player, world.actors, world.projectiles, world.pickups, world.obstacles)
	player.setup(manager)
	world.target = player


func _restore_run(snapshot: Dictionary) -> void:
	var player_data = snapshot.get("player", {})
	if player_data is Dictionary:
		player.restore_run_state(player_data)
	var boss_data = snapshot.get("boss", {})
	if boss_data is Dictionary and not boss_data.is_empty():
		var kind := String(boss_data.get("kind", ""))
		var pos = boss_data.get("position", player.global_position + Vector2(260, 0))
		if not pos is Vector2:
			pos = player.global_position + Vector2(260, 0)
		var ratio := float(boss_data.get("hp_ratio", 1.0))
		manager.restore_boss(kind, pos, ratio)
	manager.mark_passed_minibosses(Game.time)
	var mini_data = snapshot.get("miniboss", {})
	if mini_data is Dictionary and not mini_data.is_empty():
		var mini_kind := String(mini_data.get("kind", ""))
		var mini_pos = mini_data.get("position", player.global_position + Vector2(260, 0))
		if not mini_pos is Vector2:
			mini_pos = player.global_position + Vector2(260, 0)
		manager.restore_miniboss(mini_kind, mini_pos, float(mini_data.get("hp_ratio", 1.0)))
	_checkpoint_timer = 8.0


func _finish_restore() -> void:
	Game.warning.emit("저장된 전선에서 복귀했습니다", 3.0)
	if Game.pending_levelups <= 0:
		return
	Game.levelup_open = true
	get_tree().paused = true
	Audio.duck_music(true)
	overlay.show_levelup(player.get_upgrade_choices(3))


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
	# Phones skip the 16-tap bloom ring; the rest of the grade stays.
	if OS.has_feature("mobile"):
		post_mat.set_shader_parameter("bloom_quality", 0.0)
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
	_set_master_muted(false)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_on_app_background()
		NOTIFICATION_APPLICATION_RESUMED:
			_on_app_foreground()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if OS.has_feature("mobile"):
				_on_app_background()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if OS.has_feature("mobile"):
				_on_app_foreground()


func _on_app_background() -> void:
	if _backgrounded:
		return
	_backgrounded = true
	_set_master_muted(true)
	if not Game.running or player == null:
		return
	if not _dev_mode:
		Game.save_run_checkpoint(player)
	if overlay == null:
		return
	if _levelup_pending or _end_shown or overlay.is_blocking():
		return
	if get_tree().paused:
		return
	# Cancel hitstop/boss slow-motion before freezing so a resumed app never
	# comes back at a reduced time scale.
	Engine.time_scale = 1.0
	if touch_controls != null and is_instance_valid(touch_controls):
		touch_controls._reset()
		touch_controls.visible = false
	overlay.toggle_pause()


func _on_app_foreground() -> void:
	if not _backgrounded:
		return
	_backgrounded = false
	_set_master_muted(false)
	if not Game.running or overlay == null:
		return
	# Returning from the home screen must not spend the player's pause buffer
	# or auto-run the fight. Keep the pause menu up until they choose continue.
	if overlay.is_blocking() or get_tree().paused:
		if overlay._pause_visible:
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _set_master_muted(muted: bool) -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_mute(bus, muted)


func _ambient_color(progress: float) -> Color:
	var base: Color = Game.stage_data()["tint"]
	if LightRig.lit_enabled():
		var night := Color(0.20, 0.23, 0.32)
		var dawn := Color(0.58, 0.49, 0.39)
		var amb := night.lerp(dawn, pow(clampf(progress, 0.0, 1.0), 2.8))
		return Color(amb.r * base.r, amb.g * base.g, amb.b * base.b, 1.0)
	# Native GL fallback needs a little more ambient because its point lights
	# are additive and capped, but still keeps the lantern-lit night mood.
	var native_night := Color(0.10, 0.13, 0.20)
	var native_dawn := Color(0.58, 0.50, 0.40)
	var native_amb := native_night.lerp(native_dawn, pow(clampf(progress, 0.0, 1.0), 2.8))
	return Color(native_amb.r * base.r, native_amb.g * base.g, native_amb.b * base.b, 1.0)


func _process(delta: float) -> void:
	if player != null and is_instance_valid(player):
		var st := Game.stage_data()
		var p := clampf(Game.time / float(st["duration"]), 0.0, 1.0)
		canvas_mod.color = _ambient_color(p)
		if hud != null and hud.has_method("tick"):
			hud.tick(delta)
		if Game.running and not _dev_mode and not get_tree().paused:
			_checkpoint_timer -= delta
			if _checkpoint_timer <= 0.0:
				_checkpoint_timer = 8.0
				Game.save_run_checkpoint(player)
			_check_relics()


func _check_relics() -> void:
	if overlay == null or overlay.is_blocking() or player == null:
		return
	if _relic_index >= RELIC_TIMES.size():
		return
	if Game.time < float(RELIC_TIMES[_relic_index]):
		return
	var choices: Array = RelicData.random_choices(3, player.relics)
	_relic_index += 1
	if not choices.is_empty():
		overlay.show_relics(choices)


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


func _prepare_new_skills(level: int = 4) -> void:
	for id in ["meteor", "chain", "singularity", "blades"]:
		if not player.weapon_levels.has(id):
			player.add_weapon(id)
		while int(player.weapon_levels.get(id, 0)) < level:
			player.upgrade_weapon(id)
	player.recalc_stats()


func _test_new_skills() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	manager.spawn_timer = 999.0
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	player.invuln = 999.0
	var kills_before := Game.kills
	_prepare_new_skills(4)
	var kinds := ["blob", "grey", "jelly", "drone", "mech"]
	for i in 30:
		var a := TAU * float(i) / 30.0 + 0.17
		var d := 145.0 + float(i % 5) * 30.0
		manager.spawn_enemy(kinds[i % kinds.size()], player.global_position + Vector2.from_angle(a) * d, false)
	await get_tree().create_timer(4.2, true, false, true).timeout
	var new_weapons_ok := true
	for id in ["meteor", "chain", "singularity", "blades"]:
		if int(player.weapon_levels.get(id, 0)) < 4:
			new_weapons_ok = false
	var slots_ok: bool = hud != null and hud._weapon_slots.size() == 8
	var kills_gained := Game.kills - kills_before
	print("NEW SKILLS TEST weapons=%s slots=%s kills=%d enemies=%d levels=%s" % [
		new_weapons_ok, slots_ok, kills_gained, manager.enemies.size(), player.weapon_levels,
	])
	if not new_weapons_ok or not slots_ok or kills_gained < 5:
		push_error("NEW SKILLS TEST FAILED")
		get_tree().quit(1)
		return
	print("NEW SKILLS TEST OK")
	get_tree().quit()


func _test_balance() -> void:
	var reqs: Array = []
	for lv in [1, 2, 5, 10, 20, 30]:
		reqs.append(GameData.xp_requirement(int(lv)))
	var spawn_at_60 := GameData.spawn_interval("forest", 60.0, "normal")
	print("BALANCE TEST xp=%s spawn60=%.3f" % [reqs, spawn_at_60])
	if int(reqs[3]) < 150 or int(reqs[4]) < 350 or spawn_at_60 > 0.65:
		push_error("BALANCE TEST FAILED")
		get_tree().quit(1)
		return
	print("BALANCE TEST OK")
	get_tree().quit()


func _test_late_balance() -> void:
	# Benchmarks the late campaign: a fully built bear against end-of-stage
	# enemies, so the 6-15 HP curve stays in line with player power.
	await get_tree().create_timer(0.8, true, false, true).timeout
	Game.time = 216.0
	manager.spawn_timer = 999.0
	manager.boss_spawned = true
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	player.invuln = 999.0
	for id in ["core", "star", "coolant", "armor", "heart"]:
		player.passive_levels[id] = 5
	for id in ["moon_shot", "satellite", "pulse", "laser", "meteor", "chain",
			"singularity", "blades"]:
		if not player.weapon_levels.has(id):
			player.add_weapon(id)
		while int(player.weapon_levels.get(id, 0)) < 6:
			player.upgrade_weapon(id)
	player.recalc_stats()
	for id in ["moon_shot", "satellite", "pulse", "laser"]:
		player.evolve_weapon(id)
	var pair: Array = GameData.NEW_STAGE_ENEMIES.get(Game.stage_id, ["dune_stalker", "sand_spitter"])
	var start_hp := 0.0
	for i in 64:
		var a := TAU * float(i) / 64.0
		manager.spawn_enemy(String(pair[i % 2]),
			player.global_position + Vector2.from_angle(a) * (230.0 + float(i % 4) * 45.0), false)
	for e in manager.enemies:
		if is_instance_valid(e):
			start_hp += e.max_hp
	var kills_before := Game.kills
	await get_tree().create_timer(8.0, true, false, true).timeout
	var alive := 0
	var alive_hp := 0.0
	for e in manager.enemies:
		if is_instance_valid(e) and not e.dead:
			alive += 1
			alive_hp += e.hp
	var hp_scale := GameData.enemy_hp_mult(Game.stage_id, Game.time, Game.difficulty_id)
	var kills := Game.kills - kills_before
	print("LATE BALANCE TEST stage=%s scale=%.2f kills=%d alive=%d dealt=%.0f dps=%.0f" % [
		Game.stage_id, hp_scale, kills, alive,
		start_hp - alive_hp, (start_hp - alive_hp) / 8.0,
	])
	if kills < 16:
		push_error("LATE BALANCE TEST FAILED")
		get_tree().quit(1)
		return
	print("LATE BALANCE TEST OK")
	get_tree().quit()


func _has_bench_arg() -> bool:
	for a in _args:
		if a.begins_with("--bench-enemies="):
			return true
	return false


func _bench_enemies() -> void:
	var count := 200
	for a in _args:
		if a.begins_with("--bench-enemies="):
			count = maxi(1, int(a.substr(16)))
	await get_tree().create_timer(0.8, true, false, true).timeout
	if "--bench-no-bloom" in _args:
		Settings.bloom = false
	Game.time = 200.0
	manager.spawn_timer = 99999.0
	manager.boss_spawned = true
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	player.invuln = 999.0
	var idle := "--bench-idle" in _args
	if not idle:
		for id in ["core", "star", "coolant", "armor", "heart"]:
			player.passive_levels[id] = 5
		for id in ["moon_shot", "satellite", "pulse", "laser", "meteor", "chain",
				"singularity", "blades"]:
			if not player.weapon_levels.has(id):
				player.add_weapon(id)
			while int(player.weapon_levels.get(id, 0)) < 6:
				player.upgrade_weapon(id)
		player.recalc_stats()
		for id in ["moon_shot", "satellite", "pulse", "laser"]:
			player.evolve_weapon(id)
	var pair: Array = GameData.NEW_STAGE_ENEMIES.get(Game.stage_id, ["blob", "drone"])
	for i in count:
		var a := TAU * float(i) / float(count)
		var d := 120.0 + float(i % 9) * 110.0
		manager.spawn_enemy(String(pair[i % 2]),
			player.global_position + Vector2.from_angle(a) * d, false)
	await get_tree().create_timer(2.0, true, false, true).timeout
	var frames := 0
	var process_time := 0.0
	var alive_sum := 0
	var start := Time.get_ticks_usec()
	while Time.get_ticks_usec() - start < 6_000_000:
		await get_tree().process_frame
		frames += 1
		process_time += Performance.get_monitor(Performance.TIME_PROCESS)
		var missing: int = count - manager.enemies.size()
		for i in mini(missing, 12):
			var a := randf() * TAU
			manager.spawn_enemy(String(pair[i % 2]),
				player.global_position + Vector2.from_angle(a) * randf_range(500.0, 900.0), false)
		alive_sum += manager.enemies.size()
	var seconds := maxf(0.001, float(Time.get_ticks_usec() - start) / 1000000.0)
	print("BENCH enemies=%d idle=%s fps=%.1f proc_ms=%.2f alive=%.0f draw=%d objects=%d" % [
		count, idle, float(frames) / seconds, process_time / float(frames) * 1000.0,
		float(alive_sum) / float(maxi(1, frames)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
	])
	get_tree().quit()


func _test_relics() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	var errors: Array = []
	var hp_before: float = player.max_hp
	var damage_before: float = player.damage_mult
	if not player.add_relic("moon_heart"):
		errors.append("moon_heart add failed")
	if player.damage_mult <= damage_before:
		errors.append("moon_heart did not raise damage")
	if player.max_hp >= hp_before:
		errors.append("moon_heart did not lower max hp")
	if not player.add_relic("phoenix_heart"):
		errors.append("phoenix_heart add failed")
	if player.revive_charges != 1:
		errors.append("revive charges=%d" % player.revive_charges)
	if not player.add_relic("moon_lens"):
		errors.append("moon_lens add failed")
	if player.xp_mult <= 1.0:
		errors.append("xp mult=%.2f" % player.xp_mult)
	if player.add_relic("moon_heart"):
		errors.append("duplicate relic accepted")
	player.invuln = 0.0
	player.hp = 1.0
	player.take_damage(999.0)
	if player.dead or player.hp <= 0.0:
		errors.append("revive did not save the bear")
	if player.revive_charges != 0:
		errors.append("revive not consumed")
	var choices: Array = RelicData.random_choices(3, player.relics)
	if choices.size() != 3:
		errors.append("choices=%d" % choices.size())
	else:
		overlay.show_relics(choices)
		await get_tree().process_frame
		if not overlay.is_blocking():
			errors.append("relic overlay not blocking")
		overlay._choose_relic(0)
		await get_tree().process_frame
		if player.relics.size() != 4:
			errors.append("overlay choice not applied")
	_relic_index = 0
	Game.time = 45.1
	var relics_before: int = player.relics.size()
	_check_relics()
	await get_tree().process_frame
	if not overlay.is_blocking():
		errors.append("timed relic trigger did not open")
	else:
		overlay._choose_relic(0)
		await get_tree().process_frame
		if player.relics.size() != relics_before + 1:
			errors.append("timed relic choice not applied")
	print("RELICS TEST relics=%s max_hp=%.0f damage=%.2f xp=%.2f errors=%s" % [
		player.relics, player.max_hp, player.damage_mult, player.xp_mult, errors,
	])
	if not errors.is_empty():
		push_error("RELICS TEST FAILED")
		get_tree().quit(1)
		return
	print("RELICS TEST OK")
	get_tree().quit()


func _capture_relics() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	player.invuln = 999.0
	var choices: Array = RelicData.random_choices(3, [])
	overlay.show_relics(choices)
	await get_tree().create_timer(0.5, true, false, true).timeout
	await _capture("relics")


func _test_world_expansion() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	player.invuln = 999.0
	manager.spawn_timer = 999.0
	var obstacles_ok: bool = manager.obstacle_list.size() >= 10
	var first_obstacle = manager.obstacle_list[0] if obstacles_ok else null
	var obstacle_hp := 0.0
	var obstacle_destroyed := false
	if first_obstacle != null and is_instance_valid(first_obstacle):
		obstacle_hp = first_obstacle.hp
		manager.damage_obstacles_circle(first_obstacle.global_position, 10.0, 999.0)
		await get_tree().create_timer(0.15, true, false, true).timeout
		obstacle_destroyed = not is_instance_valid(first_obstacle) or first_obstacle.dead
	var collision_ok := true
	if not manager.obstacle_list.is_empty():
		var o = manager.obstacle_list[0]
		if is_instance_valid(o):
			var resolved: Vector2 = manager.resolve_obstacles(o.global_position, player.radius)
			collision_ok = resolved.distance_to(o.global_position) >= o.radius + player.radius - 0.5
	for kind in ["thorn", "moth", "larva", "sporeling", "crawler", "nullifier"]:
		manager.spawn_enemy(kind, player.global_position + Vector2(randf_range(-260, 260), randf_range(-200, 200)), true)
	var schedule: Array = Game.stage_data().get("minibosses", [])
	var first_mini := 70.0
	if not schedule.is_empty():
		first_mini = float(schedule[0][0])
	Game.time = first_mini + 0.2
	manager.boss_spawned = true
	await get_tree().create_timer(0.5, true, false, true).timeout
	var mini_ok: bool = Game.miniboss != null and is_instance_valid(Game.miniboss) and Game.miniboss.miniboss
	for mini_kind in ["moon_stalker", "spore_mother", "hive_tyrant", "bulwark", "void_reaver"]:
		manager._spawn_miniboss(mini_kind)
	await get_tree().create_timer(0.8, true, false, true).timeout
	var new_enemies := 0
	for e in manager.enemies:
		if is_instance_valid(e) and String(e.kind) in ["thorn", "moth", "larva", "sporeling", "crawler", "nullifier"]:
			new_enemies += 1
	print("WORLD EXPANSION TEST obstacles=%d hp=%.0f destroyed=%s collision=%s mini=%s new_enemies=%d" % [
		manager.obstacle_list.size(), obstacle_hp, obstacle_destroyed, collision_ok, mini_ok, new_enemies,
	])
	if not obstacles_ok or not obstacle_destroyed or not collision_ok or not mini_ok or new_enemies < 4:
		push_error("WORLD EXPANSION TEST FAILED")
		get_tree().quit(1)
		return
	print("WORLD EXPANSION TEST OK")
	get_tree().quit()


func _capture_world_expansion() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	player.invuln = 999.0
	manager.spawn_timer = 999.0
	for i in 6:
		var a := TAU * float(i) / 6.0 + 0.2
		manager.spawn_enemy(["thorn", "moth", "larva", "sporeling", "crawler", "nullifier"][i],
			player.global_position + Vector2.from_angle(a) * (190.0 + i * 20.0), false)
	Game.time = 70.2
	manager.boss_spawned = true
	await get_tree().create_timer(1.5, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("world_expansion")


func _test_progression() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	Game.stage_records.clear()
	var forest_open := Game.is_stage_unlocked("forest")
	var hive_locked := not Game.is_stage_unlocked("hive")
	Game.record_stage_result("forest", "normal", true, false, 200.0, 10, 100)
	var hive_open := Game.is_stage_unlocked("hive")
	var ship_locked := not Game.is_stage_unlocked("ship")
	Game.record_stage_result("hive", "normal", true, false, 200.0, 12, 120)
	Game.record_stage_result("ship", "normal", true, false, 200.0, 14, 140)
	Game.record_stage_result("crater", "normal", true, false, 200.0, 16, 160)
	var void_open := Game.is_stage_unlocked("void")
	var dunes_locked := not Game.is_stage_unlocked("dunes")
	Game.record_stage_result("void", "normal", true, false, 200.0, 18, 180)
	var dunes_open := Game.is_stage_unlocked("dunes")
	var frost_locked := not Game.is_stage_unlocked("frost")
	# Walk the rest of the chain: clearing each front opens exactly the next one.
	var chain_ok := dunes_open and frost_locked
	for i in range(5, GameData.STAGE_ORDER.size() - 1):
		var cleared_id: String = GameData.STAGE_ORDER[i]
		var next_id: String = GameData.STAGE_ORDER[i + 1]
		Game.record_stage_result(cleared_id, "normal", true, false, 200.0, 20 + i, 200 + i)
		chain_ok = chain_ok and Game.is_stage_unlocked(next_id)
		if i + 2 < GameData.STAGE_ORDER.size():
			chain_ok = chain_ok and not Game.is_stage_unlocked(GameData.STAGE_ORDER[i + 2])
	var sheet: Texture2D = load(CharacterData.sheet(Game.selected_character))
	var diagonal_ok := sheet.get_height() / 36 == 5
	player._update_facing(Vector2(1, 1))
	diagonal_ok = diagonal_ok and player._row == 1
	player._update_facing(Vector2(-1, 1))
	diagonal_ok = diagonal_ok and player._row == 1 and player._flip
	player._update_facing(Vector2(1, -1))
	diagonal_ok = diagonal_ok and player._row == 3
	# Diagonal rows must be their own art, not a copy of front/back.
	var sheet_img := sheet.get_image()
	var front_diag_differs := false
	var back_diag_differs := false
	for x in 32:
		for y in 36:
			if sheet_img.get_pixel(x, 36 + y) != sheet_img.get_pixel(x, y):
				front_diag_differs = true
			if sheet_img.get_pixel(x, 3 * 36 + y) != sheet_img.get_pixel(x, 4 * 36 + y):
				back_diag_differs = true
	diagonal_ok = diagonal_ok and front_diag_differs and back_diag_differs
	var content_ok := GameData.STAGE_ORDER.size() == 15 \
		and GameData.STAGES.size() == 15 \
		and GameData.NEW_STAGE_ENEMIES.size() == 10 \
		and GameData.NEW_STAGE_OBSTACLES.size() == 10
	for id in ["dunes", "frost", "mire", "ruins", "citadel", "trench", "sunspot", "maze", "orbit", "dawn"]:
		var st: Dictionary = GameData.stage(id)
		content_ok = content_ok and GameData.ENEMIES.has(String(st["boss"]))
		content_ok = content_ok and st.has("ground") and st.has("thumb")
		content_ok = content_ok and (st["enemies"] as Array).size() == 2
		for eid in st["enemies"]:
			content_ok = content_ok and GameData.ENEMIES.has(String(eid))
		for eid in st["enemy_icons"]:
			content_ok = content_ok and GameData.ENEMIES.has(String(eid))
		for mini in st["minibosses"]:
			content_ok = content_ok and GameData.ENEMIES.has(String(mini[1]))
		for relic in GameData.NEW_STAGE_OBSTACLES[id]:
			content_ok = content_ok and GameData.DESTRUCTIBLES.has(String(relic))
	for id in ["dune_queen", "frost_colossus", "mire_mother", "iron_executor",
			"citadel_guardian", "trench_devourer", "solar_tyrant", "maze_oracle",
			"orbit_breaker", "dawn_seraph"]:
		content_ok = content_ok and GameData.ENEMIES.has(id)
	print("PROGRESSION TEST stages=%d forest=%s hive_locked=%s hive=%s ship_locked=%s void=%s dunes_locked=%s dunes=%s chain=%s diagonal=%s content=%s" % [
		GameData.STAGE_ORDER.size(), forest_open, hive_locked, hive_open, ship_locked,
		void_open, dunes_locked, dunes_open, chain_ok, diagonal_ok, content_ok,
	])
	if not forest_open or not hive_locked or not hive_open or not ship_locked \
			or not void_open or not dunes_locked or not dunes_open or not chain_ok \
			or not diagonal_ok or not content_ok:
		push_error("PROGRESSION TEST FAILED")
		get_tree().quit(1)
		return
	print("PROGRESSION TEST OK")
	get_tree().quit()


func _capture_crit() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	player.invuln = 999.0
	manager.spawn_timer = 999.0
	manager.spawn_enemy("grey", player.global_position + Vector2(150, -10), false)
	await get_tree().create_timer(0.1, true, false, true).timeout
	if not manager.enemies.is_empty():
		var e = manager.enemies.back()
		if is_instance_valid(e):
			e.take_damage(999.0, true, player.global_position, 10.0)
	await get_tree().create_timer(0.18, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("crit")


func _capture_new_skills() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	manager.spawn_timer = 999.0
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	player.invuln = 999.0
	_prepare_new_skills(5)
	var kinds := ["blob", "grey", "jelly", "drone", "mech"]
	for i in 34:
		var a := TAU * float(i) / 34.0 + 0.11
		var d := 145.0 + float(i % 5) * 28.0
		manager.spawn_enemy(kinds[i % kinds.size()], player.global_position + Vector2.from_angle(a) * d, i % 11 == 0)
	await get_tree().create_timer(1.35, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("new_skills")


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


func _test_evolutions() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	player.invuln = 999.0
	var errors: Array = []
	for base in GameData.EVOLUTIONS.keys():
		var evo: Dictionary = GameData.EVOLUTIONS[base]
		if not player.weapon_levels.has(base):
			player.add_weapon(base)
		while int(player.weapon_levels.get(base, 0)) < 6:
			player.upgrade_weapon(base)
		player.passive_levels[String(evo["passive"])] = 3
		player.evolve_weapon(base)
		if String(player.evolutions.get(base, "")) != String(evo["id"]):
			errors.append("%s:evolve" % base)
			continue
		var weapon = player.weapons.get(base)
		if weapon == null or String(weapon.weapon_id()) != String(evo["id"]):
			errors.append("%s:id" % base)
	for i in 14:
		var a := TAU * float(i) / 14.0
		manager.spawn_enemy("blob", player.global_position + Vector2.from_angle(a) * 170.0, false)
	await get_tree().create_timer(3.0, true, false, true).timeout
	print("EVOLUTIONS TEST evolved=%d/%d errors=%s" % [
		player.evolutions.size(), GameData.EVOLUTIONS.size(), errors,
	])
	if player.evolutions.size() != GameData.EVOLUTIONS.size() or not errors.is_empty():
		push_error("EVOLUTIONS TEST FAILED")
		get_tree().quit(1)
		return
	print("EVOLUTIONS TEST OK")
	get_tree().quit()


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
		"galaxy":
			base = "meteor"
			passive = "magnet"
		"life":
			base = "chain"
			passive = "nano"
		"dash":
			base = "singularity"
			passive = "boots"
		"tempest":
			base = "blades"
			passive = "heart"
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
	if GameData.NEW_STAGE_ENEMIES.has(Game.stage_id):
		var pair: Array = GameData.NEW_STAGE_ENEMIES[Game.stage_id]
		kinds = [String(pair[0]), String(pair[1]), String(pair[0]), String(pair[0]),
			String(pair[1]), String(pair[0]), String(pair[1]), String(pair[0]),
			String(pair[1]), String(pair[0]), String(pair[0]), String(pair[1])]
	elif Game.stage_id == "hive":
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
	if "--capture-diagonal" in _args:
		player._update_facing(Vector2(1, 1))
		await get_tree().create_timer(0.3, true, false, true).timeout
		await _capture("diagonal")
		return
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


func _capture_lighting() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	player.invuln = 999.0
	Game.time = 66.0
	var kinds := ["blob", "drone", "grey", "jelly", "spitter", "bomber"]
	for i in 18:
		var a := TAU * float(i) / 18.0 + 0.13
		var d := 150.0 + float(i % 5) * 42.0
		manager.spawn_enemy(kinds[i % kinds.size()], player.global_position + Vector2.from_angle(a) * d, i % 7 == 0)
	await get_tree().create_timer(1.7, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("lighting")


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
	manager.spawn_enemy(String(Game.stage_data()["boss"]), pos, false)
	await get_tree().create_timer(1.4, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await get_tree().create_timer(1.2, true, false, true).timeout
	var shot := "boss" if Game.stage_id == "ship" else "boss_" + Game.stage_id
	await _capture(shot)


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


func _capture_combo() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	player.invuln = 999.0
	for i in 8:
		var a := TAU * float(i) / 8.0
		manager.spawn_enemy("blob", player.global_position + Vector2.from_angle(a) * 190.0, false)
	Game.kills = 49
	Game.kills_changed.emit(Game.kills)
	await get_tree().create_timer(0.12, true, false, true).timeout
	Game.kills = 50
	Game.kills_changed.emit(Game.kills)
	await get_tree().create_timer(0.15, true, false, true).timeout
	if hud != null:
		hud.warning_panel.visible = false
	await _capture("combo")


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


func _test_enemy_projectile() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	manager.spawn_timer = 999.0
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	await get_tree().create_timer(0.1, true, false, true).timeout
	player.global_position = Vector2.ZERO
	player.invuln = 0.0
	player.hp = player.max_hp
	var before_static: float = player.hp
	manager.spawn_enemy_orb(player.global_position + Vector2(0, -12), Vector2.ZERO, 7.0)
	await get_tree().create_timer(0.25, true, false, true).timeout
	var static_damage: float = before_static - player.hp
	await get_tree().create_timer(0.9, true, false, true).timeout
	player.invuln = 0.0
	player.hp = player.max_hp
	var before_moving: float = player.hp
	manager.spawn_enemy_orb(player.global_position + Vector2(-120, -12), Vector2(205, 0), 7.0)
	await get_tree().create_timer(0.85, true, false, true).timeout
	var moving_damage: float = before_moving - player.hp
	await get_tree().create_timer(0.9, true, false, true).timeout
	player.invuln = 0.0
	player.hp = player.max_hp
	var before_fast: float = player.hp
	manager.spawn_enemy_orb(player.global_position + Vector2(-120, -12), Vector2(4000, 0), 7.0)
	await get_tree().create_timer(0.18, true, false, true).timeout
	var fast_damage: float = before_fast - player.hp
	# A projectile that touches the player during i-frames must not vanish
	# without ever dealing damage.
	await get_tree().create_timer(0.9, true, false, true).timeout
	player.invuln = 999.0
	player.hp = player.max_hp
	var before_blocked: int = manager.projectiles.get_child_count()
	manager.spawn_enemy_orb(player.global_position + Vector2(0, -12), Vector2.ZERO, 7.0)
	await get_tree().create_timer(0.2, true, false, true).timeout
	var blocked_ok: bool = player.hp >= player.max_hp - 0.01 \
		and manager.projectiles.get_child_count() > before_blocked
	for p in manager.projectiles.get_children():
		if is_instance_valid(p) and p.get("friendly") == false:
			p.queue_free()
	player.invuln = 0.0
	for w in player.weapons.values():
		if is_instance_valid(w):
			w.set_process(false)
			w.set_physics_process(false)
	await get_tree().create_timer(0.9, true, false, true).timeout
	player.invuln = 0.0
	player.hp = player.max_hp
	var before_spitter: float = player.hp
	manager.spawn_enemy("spitter", player.global_position + Vector2(260, 0), false)
	await get_tree().create_timer(3.4, true, false, true).timeout
	var spitter_damage: float = before_spitter - player.hp
	print("ENEMY PROJECTILE TEST static=%.1f moving=%.1f fast=%.1f spitter=%.1f blocked=%s hp=%.1f" % [
		static_damage, moving_damage, fast_damage, spitter_damage, blocked_ok, player.hp,
	])
	if static_damage < 1.0 or moving_damage < 1.0 or fast_damage < 1.0 or spitter_damage < 1.0 or not blocked_ok:
		push_error("ENEMY PROJECTILE TEST FAILED")
		get_tree().quit(1)
		return
	print("ENEMY PROJECTILE TEST OK")
	get_tree().quit()


func _test_background_pause() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	manager.spawn_timer = 999.0
	for e in manager.enemies.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	manager.enemies.clear()
	player.invuln = 999.0
	var time_before: float = Game.time
	_dev_mode = false
	_notification(NOTIFICATION_APPLICATION_PAUSED)
	await get_tree().create_timer(0.3, true, false, true).timeout
	_dev_mode = true
	var bus := AudioServer.get_bus_index("Master")
	var paused_after_home: bool = get_tree().paused and overlay._pause_visible
	var muted_in_background: bool = bus >= 0 and AudioServer.is_bus_mute(bus)
	var time_frozen: bool = absf(Game.time - time_before) < 0.05
	var checkpoint_saved: bool = Game.has_run_checkpoint()
	_notification(NOTIFICATION_APPLICATION_RESUMED)
	await get_tree().create_timer(0.15, true, false, true).timeout
	var still_paused_on_return: bool = get_tree().paused and overlay._pause_visible
	var unmuted_on_return: bool = bus < 0 or not AudioServer.is_bus_mute(bus)
	if overlay._pause_visible:
		overlay._resume()
	await get_tree().create_timer(0.15, true, false, true).timeout
	var resumed: bool = not get_tree().paused and not overlay._pause_visible
	Game.clear_run_checkpoint()
	print("BACKGROUND PAUSE TEST pause=%s frozen=%s muted=%s checkpoint=%s return_paused=%s unmuted=%s resume=%s" % [
		paused_after_home, time_frozen, muted_in_background, checkpoint_saved,
		still_paused_on_return, unmuted_on_return, resumed,
	])
	if not paused_after_home or not time_frozen or not muted_in_background \
			or not checkpoint_saved or not still_paused_on_return \
			or not unmuted_on_return or not resumed:
		push_error("BACKGROUND PAUSE TEST FAILED")
		get_tree().quit(1)
		return
	print("BACKGROUND PAUSE TEST OK")
	get_tree().quit()


func _test_checkpoint_write() -> void:
	await get_tree().create_timer(0.5, true, false, true).timeout
	Game.clear_run_checkpoint()
	Game.stage_id = "hive"
	Game.difficulty_id = "dark"
	Game.selected_stage = "hive"
	Game.selected_difficulty = "dark"
	Game.time = 73.0
	Game.level = 6
	Game.xp = 8
	Game.xp_need = 41
	Game.kills = 54
	Game.rerolls = 1
	Game.banishes = 0
	player.invuln = 999.0
	player.passive_levels["core"] = 3
	player.passive_levels["heart"] = 1
	if not player.weapon_levels.has("pulse"):
		player.add_weapon("pulse")
	player.upgrade_weapon("pulse")
	player.weapon_levels["moon_shot"] = 6
	player.evolve_weapon("moon_shot")
	player.banned["boots"] = true
	player.add_relic("moon_heart")
	player.recalc_stats()
	player.hp = player.max_hp * 0.62
	player.global_position = Vector2(123, -77)
	player.ultimate_charge = 63.0
	if "--boss" in _args:
		Game.time = 175.0
		var boss_kind := String(GameData.stage("hive")["boss"])
		manager.spawn_enemy(boss_kind, player.global_position + Vector2(260, 0), false)
		if Game.boss != null and is_instance_valid(Game.boss):
			Game.boss.hp = Game.boss.max_hp * 0.5
		manager._spawn_miniboss("hive_tyrant")
		if Game.miniboss != null and is_instance_valid(Game.miniboss):
			Game.miniboss.hp = Game.miniboss.max_hp * 0.5
	if "--levelup" in _args:
		Game.pending_levelups = 1
		Game.levelup_open = true
	var ok := Game.save_run_checkpoint(player)
	print("CHECKPOINT WRITE %s time=%.1f level=%d kills=%d hp=%.1f weapons=%s" % [
		"OK" if ok else "FAILED", Game.time, Game.level, Game.kills, player.hp,
		player.weapon_levels,
	])
	print("CHECKPOINT PATH ", ProjectSettings.globalize_path(Game.RUN_SAVE_PATH),
		" exists=", FileAccess.file_exists(Game.RUN_SAVE_PATH),
		" size=", FileAccess.get_size(Game.RUN_SAVE_PATH) if FileAccess.file_exists(Game.RUN_SAVE_PATH) else -1,
		" has=", Game.has_run_checkpoint())
	get_tree().quit(0 if ok else 1)


func _test_checkpoint_resume() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	var weapons_ok := int(player.weapon_levels.get("pulse", 0)) >= 2 \
		and String(player.evolutions.get("moon_shot", "")) != ""
	var passives_ok := int(player.passive_levels.get("core", 0)) == 3 \
		and int(player.passive_levels.get("heart", 0)) == 1
	var progress_ok: bool = Game.stage_id == "hive" and Game.difficulty_id == "dark" \
		and Game.time >= 72.9 and Game.level == 6 and Game.kills >= 54 \
		and Game.rerolls == 1 and Game.banishes == 0 and player.banned.has("boots")
	var player_ok: bool = absf(player.global_position.x - 123.0) < 1.0 \
		and absf(player.global_position.y + 77.0) < 1.0 \
		and player.hp > player.max_hp * 0.5 and player.invuln > 1.0 \
		and absf(player.ultimate_charge - 63.0) < 0.5
	var combo_ok: bool = hud != null and hud._combo == 0
	var relics_ok: bool = "moon_heart" in player.relics and player.damage_mult > 1.0
	var overlay_ok: bool = Game.pending_levelups == 0 \
		or (get_tree().paused and overlay != null and overlay._levelup_visible)
	var boss_ok := true
	var mini_ok := true
	if "--boss" in _args:
		boss_ok = Game.boss != null and is_instance_valid(Game.boss) \
			and not bool(Game.boss.get("dead")) \
			and absf(float(Game.boss.get("hp")) / maxf(1.0, float(Game.boss.get("max_hp"))) - 0.5) < 0.05
		mini_ok = Game.miniboss != null and is_instance_valid(Game.miniboss) \
			and bool(Game.miniboss.get("miniboss")) \
			and absf(float(Game.miniboss.get("hp")) / maxf(1.0, float(Game.miniboss.get("max_hp"))) - 0.5) < 0.05
	print("CHECKPOINT RESUME time=%.1f level=%d kills=%d hp=%.1f pos=%s weapons=%s evolutions=%s passives=%s relics=%s combo=%s levelup=%s boss=%s mini=%s" % [
		Game.time, Game.level, Game.kills, player.hp, player.global_position,
		player.weapon_levels, player.evolutions, player.passive_levels, player.relics, combo_ok, overlay_ok, boss_ok, mini_ok,
	])
	Game.clear_run_checkpoint()
	if not weapons_ok or not passives_ok or not progress_ok or not player_ok or not combo_ok or not relics_ok or not overlay_ok or not boss_ok or not mini_ok:
		push_error("CHECKPOINT RESUME TEST FAILED")
		get_tree().quit(1)
		return
	print("CHECKPOINT RESUME TEST OK")
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


func _test_modes() -> void:
	await get_tree().create_timer(0.5, true, false, true).timeout
	var errors: Array = []
	var old_mode := Game.mode
	var old_info: Dictionary = Game.daily_info.duplicate(true)
	var old_hp := Game.run_hp_mult
	var old_damage := Game.run_damage_mult
	var old_speed := Game.run_speed_mult
	var old_spawn := Game.run_spawn_mult
	var old_pickup := Game.run_pickup_bonus
	var old_elite := Game.run_elite_bonus
	var old_stats: Dictionary = Game.stats.duplicate(true)
	var old_endless: Dictionary = Game.endless_records.duplicate(true)
	var old_daily: Dictionary = Game.daily_records.duplicate(true)
	var old_stages: Dictionary = Game.stage_records.duplicate(true)
	var old_ach: Dictionary = Game.achievements.duplicate(true)
	var old_time := Game.time
	var old_wave := Game.endless_boss_wave

	Game.prepare_daily()
	var info: Dictionary = Game.daily_info
	if String(info.get("date", "")) != Game.daily_key():
		errors.append("daily date mismatch")
	if not GameData.STAGES.has(String(info.get("stage", ""))):
		errors.append("daily stage invalid")
	if not GameData.DIFFICULTIES.has(String(info.get("diff", ""))):
		errors.append("daily diff invalid")
	var first_seed := int(info.get("seed", 0))
	Game.prepare_daily()
	if int(Game.daily_info.get("seed", 0)) != first_seed:
		errors.append("daily seed not deterministic")
	var mod: Dictionary = info.get("modifier", {})
	if mod.is_empty() or String(mod.get("name", "")) == "":
		errors.append("daily modifier missing")

	Game.mode = "daily"
	Game.stage_id = String(info.get("stage", "forest"))
	Game.difficulty_id = String(info.get("diff", "normal"))
	Game.record_daily_result(123.0, 7, 45, true)
	var drec: Dictionary = Game.daily_record()
	if int(drec.get("clears", 0)) < 1 or float(drec.get("best_time", 0.0)) < 123.0:
		errors.append("daily record not written")

	Game.mode = "endless"
	Game.stage_id = "forest"
	Game.record_endless_result(321.0, 12, 120)
	var erec: Dictionary = Game.endless_best("forest")
	if float(erec.get("best_time", 0.0)) < 321.0 or int(erec.get("best_kills", 0)) < 120:
		errors.append("endless record not written")

	Game.stage_records["dawn:normal"] = {"clears": 1}
	if not Game.is_endless_unlocked():
		errors.append("endless not unlocked by dawn clear")

	Game.mode = "endless"
	Game.time = 540.0
	Game.run_hp_mult = 1.0
	Game.run_damage_mult = 1.0
	Game.run_speed_mult = 1.0
	var scaled_enemy = load("res://scenes/enemy.tscn").instantiate()
	add_child(scaled_enemy)
	scaled_enemy.setup("blob", manager, false)
	var scaled_hp := float(scaled_enemy.max_hp)
	scaled_enemy.queue_free()
	Game.mode = "campaign"
	Game.time = 0.0
	var base_enemy = load("res://scenes/enemy.tscn").instantiate()
	add_child(base_enemy)
	base_enemy.setup("blob", manager, false)
	var base_hp := float(base_enemy.max_hp)
	base_enemy.queue_free()
	if scaled_hp <= base_hp * 1.1:
		errors.append("endless scaling too weak: %.1f vs %.1f" % [scaled_hp, base_hp])

	Game.mode = "endless"
	Game.time = 170.0
	Game.endless_boss_wave = 0
	Game.running = true
	manager.boss_spawned = true
	manager._next_endless_boss = 170.0
	manager._spawn_boss()
	if Game.endless_boss_wave != 1:
		errors.append("endless boss wave not counted")
	var first_boss = Game.boss
	if first_boss == null:
		errors.append("endless first boss missing")
	else:
		manager.on_boss_died(first_boss)
		if not Game.running:
			errors.append("endless boss death ended the run")
		if first_boss != null and is_instance_valid(first_boss):
			first_boss.queue_free()
	Game.time = 261.0
	manager._process(0.0)
	if Game.boss == null:
		errors.append("endless next boss did not spawn")
	if Game.boss != null and is_instance_valid(Game.boss):
		Game.boss.queue_free()
	Game.boss = null

	Game.mode = old_mode
	Game.daily_info = old_info
	Game.run_hp_mult = old_hp
	Game.run_damage_mult = old_damage
	Game.run_speed_mult = old_speed
	Game.run_spawn_mult = old_spawn
	Game.run_pickup_bonus = old_pickup
	Game.run_elite_bonus = old_elite
	Game.stats = old_stats
	Game.endless_records = old_endless
	Game.daily_records = old_daily
	Game.stage_records = old_stages
	Game.achievements = old_ach
	Game.time = old_time
	Game.endless_boss_wave = old_wave
	Game.save_settings()
	if errors.is_empty():
		print("MODES TEST PASS: daily=%s/%s/%s endless_best=%.0f" % [
			String(info.get("stage", "")), String(info.get("diff", "")),
			String(mod.get("name", "")), float(erec.get("best_time", 0.0)),
		])
		print("TEST PASS")
	else:
		print("MODES TEST FAIL")
		for e in errors:
			print("  ", e)
		print("TEST FAIL")
	get_tree().quit()


func _capture_endless() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	Game.mode = "endless"
	Game.time = 312.0
	Game.kills = 530
	Game.level = 22
	Game.kills_changed.emit(Game.kills)
	var kinds := ["blob", "drone", "grey", "jelly", "spitter", "bomber", "brute", "sentinel"]
	for i in 14:
		var a := TAU * float(i) / 14.0 + 0.2
		var d := 220.0 + (i % 5) * 42.0
		manager.spawn_enemy(kinds[i % kinds.size()], player.global_position + Vector2.from_angle(a) * d, i % 6 == 0)
	manager.boss_spawned = true
	await get_tree().create_timer(1.6, true, false, true).timeout
	await _capture("endless")


func _capture_daily() -> void:
	await get_tree().create_timer(0.6, true, false, true).timeout
	if not Game.is_daily():
		Game.prepare_daily()
		Game.mode = "daily"
		Game.stage_id = String(Game.daily_info.get("stage", "forest"))
		Game.difficulty_id = String(Game.daily_info.get("diff", "normal"))
		Game._apply_run_mods(Game.daily_info.get("modifier", {}))
	Game.time = 96.0
	Game.kills = 148
	Game.level = 11
	Game.kills_changed.emit(Game.kills)
	var kinds := ["blob", "drone", "grey", "jelly", "mech"]
	for i in 10:
		var a := TAU * float(i) / 10.0 + 0.1
		manager.spawn_enemy(kinds[i % kinds.size()], player.global_position + Vector2.from_angle(a) * (220.0 + (i % 4) * 40.0), i == 8)
	await get_tree().create_timer(1.4, true, false, true).timeout
	await _capture("daily")


func _capture_endless_end() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	Game.mode = "endless"
	Game.time = 487.0
	Game.level = 19
	Game.kills = 642
	Game.record_endless_result(487.0, 19, 642)
	Game.last_rewards = {}
	overlay.show_end(false, false)
	await get_tree().create_timer(0.8, true, false, true).timeout
	await _capture("endless_end")


func _capture(name: String) -> void:
	# Avoid frame_post_draw: it can stall when the window is occluded.
	await get_tree().process_frame
	var view := get_viewport_rect().size
	if view.y > view.x:
		name += "_portrait"
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/" + name + ".png")
	print("CAPTURED: ", dir + "/" + name + ".png")
	get_tree().quit()
