extends Node

## Android-only Google Play Games Services bridge.
##
## The native plugin is optional: on desktop, in the editor, or when Google
## Play Games is unavailable the game stays in guest mode and every call is a
## safe no-op. Local achievements and leaderboard scores are queued until a
## player signs in.

signal status_changed
signal sign_in_changed(signed_in: bool, player_name: String)
signal cloud_saved(ok: bool, message: String)
signal cloud_loaded(ok: bool, message: String)
signal achievements_synced(count: int)
signal leaderboard_submitted(key: String, ok: bool)

const PENDING_PATH := "user://dalbear_play_games_pending.cfg"
const LOCAL_SAVE_PATH := "user://dalbear_save.cfg"
const RUN_SAVE_PATH := "user://dalbear_run.cfg"
const CLOUD_BUNDLE_VERSION := 1
const CLOUD_AUTOSAVE_DELAY := 30.0
const CLOUD_AUTOSAVE_MIN_INTERVAL := 180.0

var available := false
var signed_in := false
var player_name := ""
var player_id := ""
var last_error := ""
var _pending_achievements: Array[String] = []
var _pending_scores := {}
var _sign_in: PlayGamesSignInClient
var _players: PlayGamesPlayersClient
var _achievements: PlayGamesAchievementsClient
var _leaderboards: PlayGamesLeaderboardsClient
var _snapshots: PlayGamesSnapshotsClient
var _cloud_save_pending := false
var _cloud_load_pending := false
var _cloud_dirty := false
var _cloud_save_automatic := false
var _last_cloud_save_msec := 0
var _cloud_autosave_timer: Timer
var _returned_from_play_games := false
var _startup_auth_check := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_pending()
	if not Engine.has_singleton("GodotPlayGameServices"):
		available = false
		status_changed.emit()
		return
	if GodotPlayGameServices.initialize() != GodotPlayGameServices.PlayGamesPluginError.OK:
		available = false
		last_error = "Google Play Games 플러그인을 초기화하지 못했습니다."
		status_changed.emit()
		return
	available = true
	_create_clients()
	Game.achievement_unlocked.connect(_on_local_achievement)
	Game.run_ended.connect(_on_run_ended)
	Game.settings_saved.connect(_on_local_save)
	Game.run_checkpoint_saved.connect(_on_local_save)
	status_changed.emit()


func _create_clients() -> void:
	_sign_in = PlayGamesSignInClient.new()
	add_child(_sign_in)
	_sign_in.user_authenticated.connect(_on_authenticated)

	_players = PlayGamesPlayersClient.new()
	add_child(_players)
	_players.current_player_loaded.connect(_on_current_player_loaded)

	_achievements = PlayGamesAchievementsClient.new()
	add_child(_achievements)

	_leaderboards = PlayGamesLeaderboardsClient.new()
	add_child(_leaderboards)
	_leaderboards.score_submitted.connect(_on_score_submitted)

	_snapshots = PlayGamesSnapshotsClient.new()
	add_child(_snapshots)
	_snapshots.game_saved.connect(_on_cloud_saved)
	_snapshots.game_loaded.connect(_on_cloud_loaded)
	_snapshots.conflict_emitted.connect(_on_cloud_conflict)

	_cloud_autosave_timer = Timer.new()
	_cloud_autosave_timer.one_shot = true
	_cloud_autosave_timer.wait_time = CLOUD_AUTOSAVE_DELAY
	_cloud_autosave_timer.timeout.connect(_on_cloud_autosave_timeout)
	add_child(_cloud_autosave_timer)
	call_deferred("_check_startup_auth")


func _check_startup_auth() -> void:
	if _sign_in != null:
		_sign_in.is_authenticated()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		_returned_from_play_games = false
		refresh_account()
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if signed_in and _cloud_dirty:
			save_cloud(true)


func refresh_account() -> void:
	if available and _sign_in != null:
		_sign_in.is_authenticated()


func is_available() -> bool:
	return available


func is_signed_in() -> bool:
	return signed_in


func status_text() -> String:
	if not available:
		return "Google Play Games · Android에서만 사용 가능"
	if not signed_in:
		return "Google Play Games · 로그인 실패" if not last_error.is_empty() else "Google Play Games · 로그인 필요"
	if player_name.is_empty():
		return "Google Play Games · 로그인됨"
	return "Google Play Games · %s" % player_name


func sign_in() -> void:
	if not available or _sign_in == null:
		last_error = "Google Play Games를 사용할 수 없는 환경입니다."
		status_changed.emit()
		return
	last_error = ""
	_sign_in.sign_in()


## Play Games Services v2 always uses the profile selected in the Play Games
## app. The SDK deliberately has no account-picker API. Open the Play Games app
## so the player can switch the profile, then relaunch DALBEAR.
func open_play_games_app() -> bool:
	if OS.get_name() != "Android":
		return false
	_returned_from_play_games = true
	var runtime = Engine.get_singleton("AndroidRuntime")
	if runtime == null:
		OS.shell_open("https://play.google.com/games")
		return true
	var activity = runtime.getActivity()
	if activity == null:
		OS.shell_open("https://play.google.com/games")
		return true
	var package_manager = activity.getPackageManager()
	if package_manager == null:
		OS.shell_open("https://play.google.com/games")
		return true
	var launch = package_manager.getLaunchIntentForPackage("com.google.android.play.games")
	if launch == null:
		OS.shell_open("https://play.google.com/store/apps/details?id=com.google.android.play.games")
		return true
	activity.startActivity(launch)
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		push_warning("Could not open Play Games app: %s" % exception)
		OS.shell_open("https://play.google.com/games")
	return true


func sync_pending() -> void:
	if not signed_in:
		return
	var synced := 0
	for local_id in _pending_achievements.duplicate():
		var play_id := String(PlayGamesConfig.ACHIEVEMENT_IDS.get(local_id, ""))
		if play_id.is_empty():
			continue
		_achievements.unlock_achievement(play_id)
		_pending_achievements.erase(local_id)
		synced += 1
	for key in _pending_scores.keys():
		var play_id := String(PlayGamesConfig.LEADERBOARD_IDS.get(key, ""))
		if play_id.is_empty():
			continue
		_leaderboards.submit_score(play_id, int(_pending_scores[key]))
		_pending_scores.erase(key)
	_save_pending()
	achievements_synced.emit(synced)


func save_cloud(automatic: bool = false) -> void:
	_cloud_save_automatic = automatic
	if not signed_in or _snapshots == null:
		_cloud_save_automatic = false
		cloud_saved.emit(false, "Google Play Games 로그인이 필요합니다.")
		return
	if _cloud_save_pending:
		return
	var data := _make_cloud_payload()
	if data.is_empty():
		_cloud_save_automatic = false
		cloud_saved.emit(false, "로컬 세이브 파일을 읽지 못했습니다.")
		return
	_cloud_dirty = false
	_cloud_save_pending = true
	_snapshots.save_game(
		PlayGamesConfig.CLOUD_SAVE_NAME,
		"DALBEAR: Earth Defense save",
		data,
		int(Game.time * 1000.0),
		int(Game.level),
	)


func _make_cloud_payload() -> PackedByteArray:
	var save_data := _read_file_bytes(LOCAL_SAVE_PATH)
	if save_data.is_empty():
		return PackedByteArray()
	var payload := {
		"format": "dalbear-cloud",
		"version": CLOUD_BUNDLE_VERSION,
		"save": Marshalls.raw_to_base64(save_data),
	}
	var run_data := _read_file_bytes(RUN_SAVE_PATH)
	if not run_data.is_empty():
		payload["run"] = Marshalls.raw_to_base64(run_data)
	return JSON.stringify(payload).to_utf8_buffer()


func _read_file_bytes(path: String) -> PackedByteArray:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return PackedByteArray()
	var data := file.get_buffer(file.get_length())
	file.close()
	return data


func _write_file_bytes(path: String, data: PackedByteArray) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(data)
	file.close()
	return true


func _backup_file(path: String) -> void:
	var data := _read_file_bytes(path)
	if data.is_empty():
		return
	_write_file_bytes(path + ".cloud_backup", data)


func _on_local_save() -> void:
	if not signed_in:
		return
	_cloud_dirty = true
	_schedule_cloud_autosave()


func _schedule_cloud_autosave() -> void:
	if not signed_in or not _cloud_dirty or _cloud_save_pending or _cloud_autosave_timer == null:
		return
	if not _cloud_autosave_timer.is_stopped():
		return
	var delay := CLOUD_AUTOSAVE_DELAY
	var elapsed := Time.get_ticks_msec() - _last_cloud_save_msec
	if _last_cloud_save_msec > 0 and elapsed < int(CLOUD_AUTOSAVE_MIN_INTERVAL * 1000.0):
		delay = maxf(CLOUD_AUTOSAVE_DELAY,
			(CLOUD_AUTOSAVE_MIN_INTERVAL * 1000.0 - float(elapsed)) / 1000.0)
	_cloud_autosave_timer.start(delay)


func _on_cloud_autosave_timeout() -> void:
	if signed_in and _cloud_dirty and not _cloud_save_pending:
		save_cloud(true)


func load_cloud() -> void:
	if not signed_in or _snapshots == null:
		cloud_loaded.emit(false, "Google Play Games 로그인이 필요합니다.")
		return
	if Game.running:
		cloud_loaded.emit(false, "실행 중에는 클라우드 세이브를 불러올 수 없습니다.")
		return
	if _cloud_load_pending:
		return
	_cloud_load_pending = true
	_snapshots.load_game(PlayGamesConfig.CLOUD_SAVE_NAME)


func _on_authenticated(is_authenticated: bool) -> void:
	print("PLAY GAMES AUTH RESULT: ", is_authenticated)
	signed_in = is_authenticated
	if signed_in:
		player_name = ""
		last_error = ""
		_cloud_dirty = false
		_last_cloud_save_msec = 0
		_players.load_current_player(true)
		status_changed.emit()
		sign_in_changed.emit(true, player_name)
		sync_pending()
	else:
		if _startup_auth_check:
			last_error = ""
		else:
			last_error = "로그인에 실패했습니다. Play Console의 OAuth 자격 증명·앱 서명 SHA-1·테스터 등록을 확인하세요."
		_startup_auth_check = false
		if _cloud_autosave_timer != null:
			_cloud_autosave_timer.stop()
		sign_in_changed.emit(false, "")
		status_changed.emit()
	_startup_auth_check = false


func _on_current_player_loaded(current: PlayGamesPlayer) -> void:
	if current == null:
		return
	player_name = current.display_name
	player_id = current.player_id
	last_error = ""
	status_changed.emit()
	sign_in_changed.emit(true, player_name)


func _on_local_achievement(id: String) -> void:
	var play_id := String(PlayGamesConfig.ACHIEVEMENT_IDS.get(id, ""))
	if signed_in and not play_id.is_empty() and _achievements != null:
		_achievements.unlock_achievement(play_id)
		return
	if not _pending_achievements.has(id):
		_pending_achievements.append(id)
		_save_pending()


func _on_score_submitted(ok: bool, leaderboard_id: String) -> void:
	for key in PlayGamesConfig.LEADERBOARD_IDS.keys():
		if String(PlayGamesConfig.LEADERBOARD_IDS[key]) == leaderboard_id:
			leaderboard_submitted.emit(String(key), ok)
			return


func _on_run_ended(_victory: bool, _boss_killed: bool) -> void:
	if not signed_in:
		return
	if Game.mode == "endless":
		_submit_score("endless_time", int(Game.time * 1000.0))
		_submit_score("endless_kills", Game.kills)
	elif Game.mode == "daily":
		_submit_score("daily_time", int(Game.time * 1000.0))
	else:
		_submit_score("weekly_time", int(Game.time * 1000.0))
	save_cloud(true)


func _submit_score(key: String, score: int) -> void:
	var play_id := String(PlayGamesConfig.LEADERBOARD_IDS.get(key, ""))
	if play_id.is_empty():
		if not _pending_scores.has(key) or int(_pending_scores[key]) < score:
			_pending_scores[key] = score
			_save_pending()
		return
	if _leaderboards != null:
		_leaderboards.submit_score(play_id, score)


func _on_cloud_saved(ok: bool, _name: String, _description: String) -> void:
	_cloud_save_pending = false
	_last_cloud_save_msec = Time.get_ticks_msec()
	if not ok:
		_cloud_dirty = true
	var automatic := _cloud_save_automatic
	_cloud_save_automatic = false
	cloud_saved.emit(ok, "자동으로 클라우드에 저장했습니다." if automatic and ok else
		("클라우드에 저장했습니다." if ok else "클라우드 저장에 실패했습니다."))
	if _cloud_dirty:
		_schedule_cloud_autosave()


func _on_cloud_conflict(conflict: PlayGamesSnapshotConflict) -> void:
	_cloud_save_pending = false
	_cloud_load_pending = false
	_cloud_save_automatic = false
	if Game.running:
		_cloud_dirty = false
		cloud_saved.emit(false, "클라우드 저장 충돌이 발생했습니다. 런을 종료한 뒤 다시 저장해 주세요.")
		return
	var snapshot: PlayGamesSnapshot = conflict.server_snapshot
	if snapshot == null:
		snapshot = conflict.conflicting_snapshot
	if snapshot != null and not snapshot.content.is_empty():
		_on_cloud_loaded(snapshot)
	else:
		cloud_loaded.emit(false, "클라우드 세이브 충돌을 해결하지 못했습니다.")


func _on_cloud_loaded(snapshot: PlayGamesSnapshot) -> void:
	_cloud_load_pending = false
	if snapshot == null or snapshot.content.is_empty():
		cloud_loaded.emit(false, "클라우드 세이브를 찾지 못했습니다.")
		return
	_backup_file(LOCAL_SAVE_PATH)
	_backup_file(RUN_SAVE_PATH)
	var parsed = JSON.parse_string(snapshot.content.get_string_from_utf8())
	var is_bundle := parsed is Dictionary and String(parsed.get("format", "")) == "dalbear-cloud"
	var save_data: PackedByteArray
	var run_data := PackedByteArray()
	if is_bundle:
		save_data = Marshalls.base64_to_raw(String(parsed.get("save", "")))
		run_data = Marshalls.base64_to_raw(String(parsed.get("run", "")))
	else:
		save_data = snapshot.content
	if save_data.is_empty() or not _write_file_bytes(LOCAL_SAVE_PATH, save_data):
		cloud_loaded.emit(false, "로컬 세이브 파일을 쓰지 못했습니다.")
		return
	if is_bundle:
		if run_data.is_empty():
			Game.clear_run_checkpoint()
		elif not _write_file_bytes(RUN_SAVE_PATH, run_data):
			cloud_loaded.emit(false, "런 체크포인트를 쓰지 못했습니다.")
			return
	Game.load_record()
	if is_bundle and not run_data.is_empty():
		Game.prepare_resume_checkpoint()
	_cloud_dirty = false
	_last_cloud_save_msec = 0
	if _cloud_autosave_timer != null:
		_cloud_autosave_timer.stop()
	var message := "클라우드 세이브를 불러왔습니다."
	if is_bundle and not run_data.is_empty():
		message = "클라우드 세이브와 진행 중인 런을 불러왔습니다. 타이틀에서 이어할 수 있습니다."
	cloud_loaded.emit(true, message)


func _save_pending() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("pending", "achievements", _pending_achievements)
	cfg.set_value("pending", "scores", _pending_scores)
	cfg.save(PENDING_PATH)


func _load_pending() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PENDING_PATH) != OK:
		return
	var achievements = cfg.get_value("pending", "achievements", [])
	if achievements is Array:
		for id in achievements:
			_pending_achievements.append(String(id))
	var scores = cfg.get_value("pending", "scores", {})
	if scores is Dictionary:
		_pending_scores = scores.duplicate(true)
