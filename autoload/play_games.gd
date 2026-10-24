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


func is_available() -> bool:
	return available


func is_signed_in() -> bool:
	return signed_in


func status_text() -> String:
	if not available:
		return "Google Play Games · Android에서만 사용 가능"
	if not signed_in:
		return "Google Play Games · 로그인 필요"
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


func save_cloud() -> void:
	if not signed_in or _snapshots == null:
		cloud_saved.emit(false, "Google Play Games 로그인이 필요합니다.")
		return
	if _cloud_save_pending:
		return
	var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
	if file == null:
		cloud_saved.emit(false, "로컬 세이브 파일을 읽지 못했습니다.")
		return
	var data := file.get_buffer(file.get_length())
	file.close()
	_cloud_save_pending = true
	_snapshots.save_game(
		PlayGamesConfig.CLOUD_SAVE_NAME,
		"DALBEAR: Earth Defense save",
		data,
		int(Game.time * 1000.0),
		int(Game.level),
	)


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
	signed_in = is_authenticated
	if signed_in:
		player_name = ""
		_players.load_current_player(true)
		status_changed.emit()
		sign_in_changed.emit(true, player_name)
		sync_pending()
	else:
		last_error = "Google Play Games 로그인이 취소되었거나 실패했습니다."
		sign_in_changed.emit(false, "")
		status_changed.emit()


func _on_current_player_loaded(current: PlayGamesPlayer) -> void:
	if current == null:
		return
	player_name = current.display_name
	player_id = current.player_id
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
	save_cloud()


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
	cloud_saved.emit(ok, "클라우드에 저장했습니다." if ok else "클라우드 저장에 실패했습니다.")


func _on_cloud_conflict(conflict: PlayGamesSnapshotConflict) -> void:
	_cloud_save_pending = false
	_cloud_load_pending = false
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
	var backup := FileAccess.open(LOCAL_SAVE_PATH + ".cloud_backup", FileAccess.WRITE)
	if backup != null:
		var old := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
		if old != null:
			backup.store_buffer(old.get_buffer(old.get_length()))
			old.close()
		backup.close()
	var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		cloud_loaded.emit(false, "로컬 세이브 파일을 쓰지 못했습니다.")
		return
	file.store_buffer(snapshot.content)
	file.close()
	Game.load_record()
	cloud_loaded.emit(true, "클라우드 세이브를 불러왔습니다. 타이틀로 돌아가면 적용됩니다.")


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
