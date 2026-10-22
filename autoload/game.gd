extends Node

## Global run state: chosen stage / difficulty, clock, XP, records.

signal xp_changed(xp: int, need: int, level: int)
signal level_up_requested
signal kills_changed(kills: int)
signal run_ended(victory: bool, boss_killed: bool)
signal warning(text: String, duration: float)
signal equipment_changed
signal character_changed

const SAVE_PATH := "user://dalbear_save.cfg"
const RUN_SAVE_PATH := "user://dalbear_run.cfg"
const RUN_SAVE_TMP := "user://dalbear_run.tmp"
const RUN_SAVE_VERSION := 1
const MAIN_SCENE := "res://scenes/main.tscn"
const TITLE_SCENE := "res://scenes/title.tscn"
const STAGE_SELECT_SCENE := "res://scenes/stage_select.tscn"
const EQUIPMENT_SCENE := "res://scenes/equipment.tscn"
const CHARACTER_SCENE := "res://scenes/characters.tscn"
const REROLL_MAX := 2
const BANISH_MAX := 1
const STARTER_SHARDS := 150

var running := false
var time := 0.0
var level := 1
var xp := 0
var xp_need := 12
var kills := 0
var pending_levelups := 0
var levelup_open := false
var rerolls := 2
var banishes := 1
var boss: Node = null
var miniboss: Node = null
var last_boss_killed := false

var stage_id := "forest"
var difficulty_id := "normal"
var selected_stage := "forest"
var selected_difficulty := "normal"

var record := {"best_time": 0.0, "best_level": 0, "best_kills": 0, "victory": false}
var stage_records := {}
var _warned := {}
var _pending_run_snapshot: Dictionary = {}

# ---------------------------------------------------------------- equipment
var inventory: Array = []
var equipped := {}
var shards := 0
var next_item_uid := 1
var equipment_initialized := false
var last_rewards := {}
var inventory_return := "title"
var selected_character := "dal"
var character_return := "title"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	load_record()
	ensure_equipment()


func _process(delta: float) -> void:
	if not running:
		return
	time += delta
	_check_warnings()
	if time >= stage_duration():
		end_run(true, false)


func stage_data() -> Dictionary:
	return GameData.stage(stage_id)


func difficulty_data() -> Dictionary:
	return GameData.difficulty(difficulty_id)


func stage_duration() -> float:
	return GameData.stage_duration(stage_id)


func stage_boss_time() -> float:
	return GameData.stage_boss_time(stage_id)


func time_left() -> float:
	return maxf(0.0, stage_duration() - time)


func _check_warnings() -> void:
	var beats: Array = stage_data().get("warnings", [])
	for entry in beats:
		var t: float = entry[0]
		var key := "%s:%.0f" % [stage_id, t]
		if time >= t and not _warned.has(key):
			_warned[key] = true
			warning.emit(String(entry[1]), 3.2)


func new_run(stage: String = "", diff: String = "") -> void:
	clear_run_checkpoint()
	if stage != "" and GameData.STAGES.has(stage):
		stage_id = stage
	if diff != "" and GameData.DIFFICULTIES.has(diff):
		difficulty_id = diff
	selected_stage = stage_id
	selected_difficulty = difficulty_id
	_reset()
	running = true
	save_settings()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_SCENE)


func begin_run() -> void:
	if not running:
		_reset()
		running = true


func start_stage(stage: String, diff: String) -> void:
	new_run(stage, diff)


func select_stage(stage: String, diff: String) -> void:
	if GameData.STAGES.has(stage):
		selected_stage = stage
		stage_id = stage
	if GameData.DIFFICULTIES.has(diff):
		selected_difficulty = diff
		difficulty_id = diff
	save_settings()


func retry_stage() -> void:
	new_run(stage_id, difficulty_id)


func _reset() -> void:
	time = 0.0
	level = 1
	xp = 0
	xp_need = GameData.xp_requirement(1)
	kills = 0
	pending_levelups = 0
	levelup_open = false
	rerolls = REROLL_MAX
	banishes = BANISH_MAX
	boss = null
	miniboss = null
	last_boss_killed = false
	_warned.clear()
	Engine.time_scale = 1.0


# ---------------------------------------------------------------- run checkpoint
func save_run_checkpoint(p) -> bool:
	if not running or p == null or not is_instance_valid(p) or bool(p.get("dead")):
		return false
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", RUN_SAVE_VERSION)
	cfg.set_value("meta", "stage", stage_id)
	cfg.set_value("meta", "difficulty", difficulty_id)
	cfg.set_value("meta", "selected_character", selected_character)
	cfg.set_value("meta", "time", time)
	cfg.set_value("meta", "level", level)
	cfg.set_value("meta", "xp", xp)
	cfg.set_value("meta", "xp_need", xp_need)
	cfg.set_value("meta", "kills", kills)
	cfg.set_value("meta", "pending_levelups", pending_levelups)
	cfg.set_value("meta", "levelup_open", levelup_open)
	cfg.set_value("meta", "rerolls", rerolls)
	cfg.set_value("meta", "banishes", banishes)
	cfg.set_value("meta", "warned", _warned.duplicate(true))
	cfg.set_value("player", "hp", float(p.hp))
	cfg.set_value("player", "position", p.global_position)
	var weapon_levels: Dictionary = p.weapon_levels
	var passive_levels: Dictionary = p.passive_levels
	var evolutions: Dictionary = p.evolutions
	var banned: Dictionary = p.banned
	cfg.set_value("player", "ultimate_charge", float(p.ultimate_charge))
	cfg.set_value("player", "weapon_levels", weapon_levels.duplicate(true))
	cfg.set_value("player", "passive_levels", passive_levels.duplicate(true))
	cfg.set_value("player", "evolutions", evolutions.duplicate(true))
	cfg.set_value("player", "banned", banned.duplicate(true))
	var boss_data := {}
	if boss != null and is_instance_valid(boss) and not bool(boss.get("dead")):
		boss_data = {
			"kind": String(boss.get("kind")),
			"position": boss.global_position,
			"hp_ratio": clampf(float(boss.get("hp")) / maxf(1.0, float(boss.get("max_hp"))), 0.01, 1.0),
		}
	cfg.set_value("boss", "data", boss_data)
	var mini_data := {}
	if miniboss != null and is_instance_valid(miniboss) and not bool(miniboss.get("dead")):
		mini_data = {
			"kind": String(miniboss.get("kind")),
			"position": miniboss.global_position,
			"hp_ratio": clampf(float(miniboss.get("hp")) / maxf(1.0, float(miniboss.get("max_hp"))), 0.01, 1.0),
		}
	cfg.set_value("miniboss", "data", mini_data)
	var err := cfg.save(RUN_SAVE_TMP)
	if err != OK:
		return false
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	if dir.file_exists("dalbear_run.cfg"):
		dir.remove("dalbear_run.cfg")
	if dir.rename("dalbear_run.tmp", "dalbear_run.cfg") == OK:
		return true
	# Fallback for platforms that cannot atomically replace the checkpoint.
	return cfg.save(RUN_SAVE_PATH) == OK


func load_run_checkpoint() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(RUN_SAVE_PATH) != OK:
		return {}
	if int(cfg.get_value("meta", "version", 0)) != RUN_SAVE_VERSION:
		return {}
	var stage := String(cfg.get_value("meta", "stage", ""))
	var diff := String(cfg.get_value("meta", "difficulty", ""))
	if not GameData.STAGES.has(stage) or not GameData.DIFFICULTIES.has(diff):
		return {}
	var checkpoint_time := float(cfg.get_value("meta", "time", -1.0))
	if checkpoint_time < 0.0:
		return {}
	var weapon_levels = cfg.get_value("player", "weapon_levels", {})
	var passive_levels = cfg.get_value("player", "passive_levels", {})
	var evolutions = cfg.get_value("player", "evolutions", {})
	var banned = cfg.get_value("player", "banned", {})
	if not weapon_levels is Dictionary or not passive_levels is Dictionary \
			or not evolutions is Dictionary or not banned is Dictionary:
		return {}
	var char_id := String(cfg.get_value("meta", "selected_character", selected_character))
	if not CharacterData.CHARACTERS.has(char_id):
		char_id = selected_character
	var boss_data = cfg.get_value("boss", "data", {})
	if not boss_data is Dictionary:
		boss_data = {}
	var mini_data = cfg.get_value("miniboss", "data", {})
	if not mini_data is Dictionary:
		mini_data = {}
	return {
		"meta": {
			"stage": stage,
			"difficulty": diff,
			"selected_character": char_id,
			"time": checkpoint_time,
			"level": maxi(1, int(cfg.get_value("meta", "level", 1))),
			"xp": maxi(0, int(cfg.get_value("meta", "xp", 0))),
			"xp_need": maxi(1, int(cfg.get_value("meta", "xp_need", 12))),
			"kills": maxi(0, int(cfg.get_value("meta", "kills", 0))),
			"pending_levelups": maxi(0, int(cfg.get_value("meta", "pending_levelups", 0))),
			"levelup_open": bool(cfg.get_value("meta", "levelup_open", false)),
			"rerolls": maxi(0, int(cfg.get_value("meta", "rerolls", REROLL_MAX))),
			"banishes": maxi(0, int(cfg.get_value("meta", "banishes", BANISH_MAX))),
			"warned": cfg.get_value("meta", "warned", {}),
		},
		"player": {
			"hp": maxf(1.0, float(cfg.get_value("player", "hp", 100.0))),
			"position": cfg.get_value("player", "position", Vector2.ZERO),
			"ultimate_charge": maxf(0.0, float(cfg.get_value("player", "ultimate_charge", 0.0))),
			"weapon_levels": weapon_levels,
			"passive_levels": passive_levels,
			"evolutions": evolutions,
			"banned": banned,
		},
		"boss": boss_data,
		"miniboss": mini_data,
	}


func has_run_checkpoint() -> bool:
	var snap := load_run_checkpoint()
	if not snap.is_empty():
		return true
	if FileAccess.file_exists(RUN_SAVE_PATH):
		clear_run_checkpoint()
	return false


func run_checkpoint_summary() -> String:
	var snap := load_run_checkpoint()
	if snap.is_empty():
		return ""
	var meta: Dictionary = snap.get("meta", {})
	var stage := GameData.stage(String(meta.get("stage", stage_id)))
	var diff := GameData.difficulty(String(meta.get("difficulty", difficulty_id)))
	return "%s · %s · %s · Lv.%d" % [
		String(stage.get("short", "")), String(diff.get("name", "")),
		GameData.format_time(float(meta.get("time", 0.0))), int(meta.get("level", 1)),
	]


func prepare_resume_checkpoint() -> bool:
	var snap := load_run_checkpoint()
	if snap.is_empty():
		clear_run_checkpoint()
		return false
	_apply_run_meta(snap.get("meta", {}))
	_pending_run_snapshot = snap
	running = true
	get_tree().paused = false
	Engine.time_scale = 1.0
	return true


func resume_run_checkpoint() -> bool:
	if not prepare_resume_checkpoint():
		return false
	Audio.duck_music(false)
	get_tree().change_scene_to_file(MAIN_SCENE)
	return true


func consume_run_snapshot() -> Dictionary:
	var snap := _pending_run_snapshot
	_pending_run_snapshot = {}
	return snap


func clear_run_checkpoint() -> void:
	_pending_run_snapshot.clear()
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	if dir.file_exists("dalbear_run.cfg"):
		dir.remove("dalbear_run.cfg")
	if dir.file_exists("dalbear_run.tmp"):
		dir.remove("dalbear_run.tmp")


func _apply_run_meta(meta: Dictionary) -> void:
	stage_id = String(meta.get("stage", stage_id))
	difficulty_id = String(meta.get("difficulty", difficulty_id))
	if not GameData.STAGES.has(stage_id):
		stage_id = "forest"
	if not GameData.DIFFICULTIES.has(difficulty_id):
		difficulty_id = "normal"
	selected_stage = stage_id
	selected_difficulty = difficulty_id
	var char_id := String(meta.get("selected_character", selected_character))
	if CharacterData.CHARACTERS.has(char_id):
		selected_character = char_id
	time = maxf(0.0, float(meta.get("time", 0.0)))
	level = maxi(1, int(meta.get("level", 1)))
	xp = maxi(0, int(meta.get("xp", 0)))
	xp_need = GameData.xp_requirement(level)
	kills = maxi(0, int(meta.get("kills", 0)))
	pending_levelups = maxi(0, int(meta.get("pending_levelups", 0)))
	levelup_open = pending_levelups > 0
	rerolls = clampi(int(meta.get("rerolls", REROLL_MAX)), 0, REROLL_MAX)
	banishes = clampi(int(meta.get("banishes", BANISH_MAX)), 0, BANISH_MAX)
	last_boss_killed = false
	boss = null
	miniboss = null
	var warned = meta.get("warned", {})
	_warned = warned if warned is Dictionary else {}


func add_xp(amount: int) -> void:
	if not running:
		return
	xp += amount
	while xp >= xp_need:
		xp -= xp_need
		level += 1
		xp_need = GameData.xp_requirement(level)
		pending_levelups += 1
	xp_changed.emit(xp, xp_need, level)
	if pending_levelups > 0 and not levelup_open:
		levelup_open = true
		level_up_requested.emit()


func finish_levelup() -> bool:
	pending_levelups = maxi(0, pending_levelups - 1)
	if pending_levelups <= 0:
		levelup_open = false
		return true
	return false


func use_reroll() -> bool:
	if rerolls <= 0:
		return false
	rerolls -= 1
	return true


func use_banish() -> bool:
	if banishes <= 0:
		return false
	banishes -= 1
	return true


# ------------------------------------------------------------------ equipment
func ensure_equipment() -> void:
	var seen := {}
	var clean_inv: Array = []
	var serial := maxi(1, next_item_uid)
	for raw in inventory:
		if not raw is Dictionary:
			continue
		var item: Dictionary = (raw as Dictionary).duplicate(true)
		var slot := String(item.get("slot", ""))
		if not EquipmentData.ITEM_SLOT_LABELS.has(slot):
			continue
		var rarity_id := String(item.get("rarity", "common"))
		if not EquipmentData.RARITIES.has(rarity_id):
			rarity_id = "common"
		item["rarity"] = rarity_id
		item["level"] = clampi(int(item.get("level", 1)), 1,
			int(EquipmentData.RARITIES[rarity_id]["max_level"]))
		if slot == "weapon":
			var wid := String(item.get("weapon_id", ""))
			if not GameData.WEAPONS.has(wid):
				wid = "moon_shot"
			item["weapon_id"] = wid
		else:
			item["weapon_id"] = ""
		var uid := String(item.get("uid", ""))
		if uid == "" or seen.has(uid):
			while true:
				uid = "eq_%d" % serial
				serial += 1
				if not seen.has(uid):
					break
			item["uid"] = uid
		seen[uid] = true
		clean_inv.append(item)
	inventory = clean_inv
	next_item_uid = maxi(serial, next_item_uid)

	var clean_eq := {}
	var used := {}
	for slot in EquipmentData.SLOT_ORDER:
		var uid := String(equipped.get(slot, ""))
		if uid == "" or used.has(uid):
			continue
		var item: Dictionary = item_by_uid(uid)
		if item.is_empty():
			continue
		if not EquipmentData.slot_accepts(String(item.get("slot", "")), slot):
			continue
		clean_eq[slot] = uid
		used[uid] = true
	equipped = clean_eq

	if not equipment_initialized and inventory.is_empty():
		_grant_starter_equipment()
	else:
		equipment_initialized = true
	_clear_incompatible_character_gear()
	var sig_added := ensure_character_signature(selected_character, false)
	if sig_added:
		_auto_equip_signature_items(_character_signature_items(selected_character))
	save_settings()
	equipment_changed.emit()


func _grant_starter_equipment() -> void:
	equipment_initialized = true
	shards = maxi(shards, STARTER_SHARDS)
	for slot in EquipmentData.ARMOR_ORDER:
		var item := add_item(EquipmentData.make_item(slot, "common", 1), false)
		equipped[slot] = String(item["uid"])
	var main_item := add_item(EquipmentData.make_item("weapon", "common", 1, "moon_shot"), false)
	equipped["main"] = String(main_item["uid"])
	var second_item := add_item(EquipmentData.make_item("weapon", "common", 1, "satellite"), false)
	equipped["secondary"] = String(second_item["uid"])
	for slot in EquipmentData.RING_SLOTS:
		var ring := add_item(EquipmentData.make_item("ring", "common", 1), false)
		equipped[slot] = String(ring["uid"])
	var necklace := add_item(EquipmentData.make_item("necklace", "common", 1), false)
	equipped["necklace"] = String(necklace["uid"])
	equipment_changed.emit()


func _new_uid() -> String:
	next_item_uid = maxi(1, next_item_uid)
	while true:
		var uid := "eq_%d" % next_item_uid
		next_item_uid += 1
		if not _uid_in_use(uid):
			return uid
	return "eq_1"


func _uid_in_use(uid: String) -> bool:
	for item in inventory:
		if item is Dictionary and String(item.get("uid", "")) == uid:
			return true
	for slot in equipped.keys():
		if String(equipped[slot]) == uid:
			return true
	return false


func add_item(item: Dictionary, save_now: bool = false) -> Dictionary:
	var copy: Dictionary = item.duplicate(true)
	if String(copy.get("uid", "")) == "":
		copy["uid"] = _new_uid()
	inventory.append(copy)
	equipment_initialized = true
	equipment_changed.emit()
	if save_now:
		save_settings()
	return copy


func new_random_item(rarity_id: String = "", level: int = 1, slot: String = "") -> Dictionary:
	var item_slot := slot
	if item_slot == "":
		item_slot = EquipmentData.roll_drop_slot()
	if rarity_id == "":
		rarity_id = EquipmentData.roll_rarity(0.0)
	var item := EquipmentData.make_item(item_slot, rarity_id, level)
	return add_item(item, false)


func item_by_uid(uid: String) -> Dictionary:
	for item in inventory:
		if item is Dictionary and String(item.get("uid", "")) == uid:
			return item
	return {}


func equipped_item(slot: String) -> Dictionary:
	var uid := String(equipped.get(slot, ""))
	if uid == "":
		return {}
	return item_by_uid(uid)


func is_item_equipped(uid: String) -> bool:
	for slot in equipped.keys():
		if String(equipped[slot]) == uid:
			return true
	return false


func equipped_slot_of(uid: String) -> String:
	for slot in EquipmentData.SLOT_ORDER:
		if String(equipped.get(slot, "")) == uid:
			return slot
	return ""


func equip_item(uid: String, target_slot: String = "") -> Dictionary:
	var item: Dictionary = item_by_uid(uid)
	if item.is_empty():
		return {"ok": false, "message": "장비를 찾을 수 없습니다."}
	var item_character := EquipmentData.item_character(item)
	if item_character != "" and item_character != selected_character:
		return {"ok": false, "message": "%s 전용 장비입니다." % CharacterData.display_name(item_character)}
	var item_slot := String(item.get("slot", ""))
	var targets := EquipmentData.target_slots(item_slot)
	var slot := target_slot
	if slot == "":
		slot = String(targets[0])
		for candidate in targets:
			if String(equipped.get(candidate, "")) == "":
				slot = String(candidate)
				break
	if not (slot in targets):
		return {"ok": false, "message": "이 장비를 장착할 수 없는 슬롯입니다."}
	if String(equipped.get(slot, "")) == uid:
		return {"ok": false, "message": "이미 장착 중입니다."}
	if item_slot == "weapon":
		for other in EquipmentData.WEAPON_SLOTS:
			if other == slot:
				continue
			var other_item := equipped_item(other)
			if not other_item.is_empty() and String(other_item.get("uid", "")) != uid:
				if String(other_item.get("weapon_id", "")) == String(item.get("weapon_id", "")):
					return {"ok": false, "message": "같은 무기는 주/보조에 동시 장착할 수 없습니다."}
	for other in targets:
		if other != slot and String(equipped.get(other, "")) == uid:
			equipped.erase(other)
	equipped[slot] = uid
	equipment_initialized = true
	save_settings()
	equipment_changed.emit()
	return {"ok": true, "slot": slot, "message": "장착했습니다."}


func unequip_slot(slot: String) -> bool:
	if not equipped.has(slot):
		return false
	equipped.erase(slot)
	save_settings()
	equipment_changed.emit()
	return true


func enhance_item(uid: String) -> Dictionary:
	var item: Dictionary = item_by_uid(uid)
	if item.is_empty():
		return {"ok": false, "message": "장비를 찾을 수 없습니다."}
	var cap := EquipmentData.max_level(item)
	var lv := int(item.get("level", 1))
	if lv >= cap:
		return {"ok": false, "message": "이미 최대 레벨입니다."}
	var cost := EquipmentData.enhance_cost(item)
	if shards < cost:
		return {"ok": false, "message": "달빛 조각이 부족합니다."}
	shards -= cost
	item["level"] = lv + 1
	equipment_initialized = true
	save_settings()
	equipment_changed.emit()
	return {"ok": true, "message": "강화 완료! Lv.%d" % (lv + 1), "cost": cost}


func dismantle_item(uid: String) -> Dictionary:
	if is_item_equipped(uid):
		return {"ok": false, "message": "장착 중인 장비는 분해할 수 없습니다."}
	var found: Dictionary = item_by_uid(uid)
	if not found.is_empty() and EquipmentData.is_signature(found):
		return {"ok": false, "message": "전용 장비는 분해할 수 없습니다."}
	for i in inventory.size():
		var item: Dictionary = inventory[i]
		if String(item.get("uid", "")) != uid:
			continue
		var value := EquipmentData.dismantle_value(item)
		var name := EquipmentData.item_name(item)
		inventory.remove_at(i)
		shards += value
		save_settings()
		equipment_changed.emit()
		return {"ok": true, "message": "%s 분해 · 달빛 조각 +%d" % [name, value], "value": value}
	return {"ok": false, "message": "장비를 찾을 수 없습니다."}


func equipment_bonuses() -> Dictionary:
	var out := {}
	for key in EquipmentData.STAT_ORDER:
		out[key] = 0.0
	for slot in EquipmentData.SLOT_ORDER:
		var item := equipped_item(slot)
		if item.is_empty():
			continue
		var stats := EquipmentData.stats_for(item)
		for key in stats.keys():
			out[key] = float(out.get(key, 0.0)) + float(stats[key])
	return out


func equipped_weapons() -> Array:
	var out: Array = []
	var seen := {}
	for slot in EquipmentData.WEAPON_SLOTS:
		var item := equipped_item(slot)
		if item.is_empty():
			continue
		var wid := String(item.get("weapon_id", ""))
		if not GameData.WEAPONS.has(wid) or seen.has(wid):
			continue
		seen[wid] = true
		out.append({"slot": slot, "item": item})
	return out


func equipment_power() -> int:
	var total := 0.0
	for slot in EquipmentData.SLOT_ORDER:
		var item := equipped_item(slot)
		if not item.is_empty():
			total += EquipmentData.item_power(item)
	return int(round(total))


func equipment_summary() -> String:
	return "전투력 %d · 달빛 조각 %d" % [equipment_power(), shards]


func grant_run_rewards(victory: bool, boss_killed: bool) -> Dictionary:
	var diff_idx := maxi(0, GameData.DIFFICULTY_ORDER.find(difficulty_id))
	var stage_idx := maxi(0, GameData.STAGE_ORDER.find(stage_id))
	var diff_mult := float([0.8, 1.0, 1.25, 1.6][mini(diff_idx, 3)])
	var stage_mult := 1.0 + float(stage_idx) * 0.12
	var gain := 40.0 + float(kills) * 0.16 + time * 0.09
	if victory:
		gain += 55.0
	if boss_killed:
		gain += 45.0
	gain = maxf(5.0, round(gain * diff_mult * stage_mult))
	var luck := float(diff_idx) * 1.1 + float(stage_idx) * 0.8
	if victory:
		luck += 1.6
	if boss_killed:
		luck += 2.0
	var drop_level := 1 + (1 if diff_idx >= 2 else 0) + floori(float(stage_idx) / 5.0)
	var drop_count := 1 + (1 if victory else 0) + (1 if boss_killed else 0)
	var drops: Array = []
	for i in drop_count:
		var rarity_id := EquipmentData.roll_rarity(luck)
		var item := EquipmentData.random_item(rarity_id, drop_level)
		var added := add_item(item, false)
		drops.append(added)
	shards += int(gain)
	last_rewards = {
		"shards": int(gain),
		"items": drops,
		"victory": victory,
		"boss": boss_killed,
	}
	equipment_initialized = true
	save_settings()
	equipment_changed.emit()
	return last_rewards


func last_rewards_text() -> String:
	if last_rewards.is_empty():
		return ""
	var parts: Array = ["달빛 조각 +%d" % int(last_rewards.get("shards", 0))]
	var items: Array = last_rewards.get("items", [])
	for item in items:
		if item is Dictionary:
			parts.append("%s(%s)" % [
				EquipmentData.item_name(item),
				EquipmentData.rarity_name(String(item.get("rarity", "common"))),
			])
	return " · ".join(parts)


func go_equipment(return_to: String = "stage_select") -> void:
	inventory_return = return_to
	save_settings()
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	get_tree().change_scene_to_file(EQUIPMENT_SCENE)


func close_equipment() -> void:
	if inventory_return == "stage_select":
		go_stage_select()
	else:
		go_title()


# ------------------------------------------------------------------ characters
func character_data() -> Dictionary:
	return CharacterData.get_character(selected_character)


func item_by_sig_id(sig_id: String) -> Dictionary:
	for item in inventory:
		if item is Dictionary and String(item.get("sig_id", "")) == sig_id:
			return item
	return {}


func _character_signature_items(character_id: String) -> Array:
	var out: Array = []
	for template in EquipmentData.signature_set(character_id):
		var item := item_by_sig_id(String(template.get("sig_id", "")))
		if not item.is_empty():
			out.append(item)
	return out


func ensure_character_signature(character_id: String, auto_equip: bool = false) -> bool:
	var added := false
	var items: Array = []
	for template in EquipmentData.signature_set(character_id):
		var sig_id := String(template.get("sig_id", ""))
		if sig_id == "":
			continue
		var item := item_by_sig_id(sig_id)
		if item.is_empty():
			item = add_item(EquipmentData.make_signature_item(character_id, template, 1), false)
			added = true
		items.append(item)
	if auto_equip:
		_auto_equip_signature_items(items)
	return added


func _clear_incompatible_character_gear() -> void:
	for slot in equipped.keys():
		var uid := String(equipped[slot])
		var item := item_by_uid(uid)
		if item.is_empty():
			continue
		var owner := EquipmentData.item_character(item)
		if owner != "" and owner != selected_character:
			equipped.erase(slot)


func _slot_power(slot: String) -> float:
	var item := equipped_item(slot)
	if item.is_empty():
		return 0.0
	return EquipmentData.item_power(item)


func _weapon_type_conflict(item: Dictionary, target: String) -> bool:
	var wid := String(item.get("weapon_id", ""))
	for other in EquipmentData.WEAPON_SLOTS:
		if other == target:
			continue
		var other_item := equipped_item(other)
		if other_item.is_empty():
			continue
		if String(other_item.get("uid", "")) == String(item.get("uid", "")):
			continue
		if String(other_item.get("weapon_id", "")) == wid:
			return true
	return false


func _best_weapon_target(item: Dictionary) -> String:
	var candidates: Array = EquipmentData.WEAPON_SLOTS.duplicate()
	candidates.sort_custom(func(a: String, b: String) -> bool:
		return _slot_power(a) < _slot_power(b)
	)
	var power := EquipmentData.item_power(item)
	for target in candidates:
		if _slot_power(String(target)) >= power:
			continue
		if _weapon_type_conflict(item, String(target)):
			continue
		return String(target)
	return ""


func _best_ring_target(item: Dictionary) -> String:
	var candidates: Array = EquipmentData.RING_SLOTS.duplicate()
	candidates.sort_custom(func(a: String, b: String) -> bool:
		return _slot_power(a) < _slot_power(b)
	)
	var power := EquipmentData.item_power(item)
	for target in candidates:
		if _slot_power(String(target)) < power:
			return String(target)
	return ""


func _auto_equip_signature_items(items: Array) -> void:
	for item in items:
		if not item is Dictionary:
			continue
		var uid := String(item.get("uid", ""))
		if uid == "" or is_item_equipped(uid):
			continue
		var item_slot := String(item.get("slot", ""))
		var target := ""
		if item_slot == "weapon":
			target = _best_weapon_target(item)
		elif item_slot == "ring":
			target = _best_ring_target(item)
		elif item_slot in ["helmet", "gloves", "chest", "pants", "boots", "cape", "necklace"]:
			if _slot_power(item_slot) < EquipmentData.item_power(item):
				target = item_slot
		if target != "":
			equip_item(uid, target)


func _fill_empty_slots_after_character_swap() -> void:
	for slot in EquipmentData.SLOT_ORDER:
		if String(equipped.get(slot, "")) != "":
			continue
		var item_slot: String = "weapon" if slot in EquipmentData.WEAPON_SLOTS else (
			"ring" if slot in EquipmentData.RING_SLOTS else String(slot))
		var best: Dictionary = {}
		var best_power := -1.0
		for item in inventory:
			if not item is Dictionary:
				continue
			var uid := String(item.get("uid", ""))
			if uid == "" or is_item_equipped(uid):
				continue
			if String(item.get("slot", "")) != item_slot:
				continue
			var owner := EquipmentData.item_character(item)
			if owner != "" and owner != selected_character:
				continue
			if item_slot == "weapon" and _weapon_type_conflict(item, String(slot)):
				continue
			var power := EquipmentData.item_power(item)
			if power > best_power:
				best = item
				best_power = power
		if not best.is_empty():
			equip_item(String(best.get("uid", "")), String(slot))


func select_character(character_id: String) -> Dictionary:
	if not CharacterData.CHARACTERS.has(character_id):
		return {"ok": false, "message": "알 수 없는 친구입니다."}
	if character_id == selected_character:
		return {"ok": true, "changed": false, "message": "이미 선택된 친구입니다."}
	if has_run_checkpoint():
		clear_run_checkpoint()
	selected_character = character_id
	_clear_incompatible_character_gear()
	ensure_character_signature(character_id, true)
	_fill_empty_slots_after_character_swap()
	save_settings()
	character_changed.emit()
	equipment_changed.emit()
	return {
		"ok": true, "changed": true,
		"message": "%s가 전선에 합류했습니다." % CharacterData.display_name(character_id),
	}


func go_characters(return_to: String = "stage_select") -> void:
	character_return = return_to
	save_settings()
	get_tree().paused = false
	Engine.time_scale = 1.0
	Audio.duck_music(false)
	get_tree().change_scene_to_file(CHARACTER_SCENE)


func close_characters() -> void:
	match character_return:
		"stage_select":
			go_stage_select()
		"equipment":
			get_tree().paused = false
			Engine.time_scale = 1.0
			Audio.duck_music(false)
			get_tree().change_scene_to_file(EQUIPMENT_SCENE)
		_:
			go_title()



func add_kill() -> void:
	if not running:
		return
	kills += 1
	kills_changed.emit(kills)


func stage_clear(boss_killed: bool = false) -> void:
	end_run(true, boss_killed)


func trigger_victory() -> void:
	stage_clear(true)


func end_run(victory: bool, boss_killed: bool = false) -> void:
	if not running:
		return
	clear_run_checkpoint()
	running = false
	last_boss_killed = boss_killed
	boss = null
	miniboss = null
	var survived := time
	record_stage_result(stage_id, difficulty_id, victory, boss_killed, survived, level, kills)
	if victory:
		record["victory"] = true
	record["best_time"] = maxf(float(record["best_time"]), survived)
	record["best_level"] = maxi(int(record["best_level"]), level)
	record["best_kills"] = maxi(int(record["best_kills"]), kills)
	grant_run_rewards(victory, boss_killed)
	save_settings()
	run_ended.emit(victory, boss_killed)


func record_stage_result(stage: String, diff: String, victory: bool,
		boss_killed: bool, survived: float, lv: int, kill_count: int) -> void:
	var key := "%s:%s" % [stage, diff]
	var rec: Dictionary = stage_records.get(key, {
		"clears": 0, "boss": false, "best_kills": 0, "best_level": 0, "best_time": 0.0,
	})
	if victory:
		rec["clears"] = int(rec["clears"]) + 1
		rec["best_kills"] = maxi(int(rec["best_kills"]), kill_count)
		rec["best_level"] = maxi(int(rec["best_level"]), lv)
		if boss_killed:
			rec["boss"] = true
		var best := float(rec.get("best_time", 0.0))
		if best <= 0.0 or survived < best:
			rec["best_time"] = survived
	stage_records[key] = rec


func get_stage_record(stage: String, diff: String) -> Dictionary:
	return stage_records.get("%s:%s" % [stage, diff], {})


func stage_record_text(stage: String, diff: String) -> String:
	var rec := get_stage_record(stage, diff)
	if rec.is_empty() or int(rec.get("clears", 0)) <= 0:
		return "미클리어"
	var parts := ["클리어 ×%d" % int(rec["clears"])]
	if bool(rec.get("boss", false)):
		parts.append("보스")
	parts.append("Lv.%d" % int(rec.get("best_level", 0)))
	return " · ".join(parts)


func has_cleared(stage: String) -> bool:
	for diff in GameData.DIFFICULTY_ORDER:
		var rec := get_stage_record(stage, diff)
		if int(rec.get("clears", 0)) > 0:
			return true
	return false


func is_stage_unlocked(stage: String) -> bool:
	var idx := GameData.STAGE_ORDER.find(stage)
	if idx < 0:
		return false
	if idx == 0:
		return true
	return has_cleared(GameData.STAGE_ORDER[idx - 1])


func first_unlocked_stage() -> String:
	for id in GameData.STAGE_ORDER:
		if not is_stage_unlocked(id):
			return GameData.STAGE_ORDER[maxi(0, GameData.STAGE_ORDER.find(id) - 1)]
	return GameData.STAGE_ORDER[GameData.STAGE_ORDER.size() - 1]


func go_title() -> void:
	clear_run_checkpoint()
	running = false
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)


func go_stage_select() -> void:
	clear_run_checkpoint()
	running = false
	get_tree().paused = false
	get_tree().change_scene_to_file(STAGE_SELECT_SCENE)


func restart() -> void:
	retry_stage()


func record_text() -> String:
	if float(record["best_time"]) <= 0.0:
		return "아직 기록이 없습니다 · 첫 전선을 지켜내세요"
	var line := "최고 생존 %s · Lv.%d · %d 킬" % [
		GameData.format_time(float(record["best_time"])),
		int(record["best_level"]),
		int(record["best_kills"]),
	]
	if bool(record["victory"]):
		line = "전선 방어 성공 · " + line
	return line


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("record", "best_time", record["best_time"])
	cfg.set_value("record", "best_level", record["best_level"])
	cfg.set_value("record", "best_kills", record["best_kills"])
	cfg.set_value("record", "victory", record["victory"])
	cfg.set_value("settings", "selected_stage", selected_stage)
	cfg.set_value("settings", "selected_difficulty", selected_difficulty)
	cfg.set_value("records", "stages", stage_records)
	cfg.set_value("equipment", "inventory", inventory)
	cfg.set_value("equipment", "equipped", equipped)
	cfg.set_value("equipment", "shards", shards)
	cfg.set_value("equipment", "next_uid", next_item_uid)
	cfg.set_value("equipment", "initialized", equipment_initialized)
	cfg.set_value("equipment", "last_rewards", last_rewards)
	cfg.set_value("character", "selected", selected_character)
	cfg.save(SAVE_PATH)


func save_record() -> void:
	save_settings()


func load_record() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	record["best_time"] = float(cfg.get_value("record", "best_time", 0.0))
	record["best_level"] = int(cfg.get_value("record", "best_level", 0))
	record["best_kills"] = int(cfg.get_value("record", "best_kills", 0))
	record["victory"] = bool(cfg.get_value("record", "victory", false))
	selected_stage = String(cfg.get_value("settings", "selected_stage", "forest"))
	selected_difficulty = String(cfg.get_value("settings", "selected_difficulty", "normal"))
	if not GameData.STAGES.has(selected_stage):
		selected_stage = "forest"
	if not GameData.DIFFICULTIES.has(selected_difficulty):
		selected_difficulty = "normal"
	stage_id = selected_stage
	difficulty_id = selected_difficulty
	var rec = cfg.get_value("records", "stages", {})
	if rec is Dictionary:
		stage_records = rec
	var inv = cfg.get_value("equipment", "inventory", [])
	if inv is Array:
		inventory = inv
	var eq = cfg.get_value("equipment", "equipped", {})
	if eq is Dictionary:
		equipped = eq
	shards = int(cfg.get_value("equipment", "shards", 0))
	next_item_uid = int(cfg.get_value("equipment", "next_uid", 1))
	equipment_initialized = bool(cfg.get_value("equipment", "initialized", false))
	var rewards = cfg.get_value("equipment", "last_rewards", {})
	if rewards is Dictionary:
		last_rewards = rewards
	var cid := String(cfg.get_value("character", "selected", "dal"))
	if CharacterData.CHARACTERS.has(cid):
		selected_character = cid
	else:
		selected_character = "dal"
