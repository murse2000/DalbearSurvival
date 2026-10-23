class_name AchievementData
extends RefCounted

## Local achievements. Progress is derived from Game.stats and stage records,
## so old saves start earning them immediately.

const LIST := [
	{
		"id": "first_clear", "name": "첫 새벽", "stat": "first_clear", "target": 1,
		"desc": "첫 전선을 클리어했다",
		"icon": "res://assets/art/ui/icon_star.png",
	},
	{
		"id": "final_clear", "name": "지구 방위", "stat": "final_clear", "target": 1,
		"desc": "20전선을 모두 클리어했다",
		"icon": "res://assets/art/ui/icon_trophy.png",
	},
	{
		"id": "kills_1000", "name": "사냥꾼", "stat": "total_kills", "target": 1000,
		"desc": "누적 1,000마리를 처치했다",
		"icon": "res://assets/art/ui/icon_blades.png",
	},
	{
		"id": "kills_10000", "name": "학살자", "stat": "total_kills", "target": 10000,
		"desc": "누적 10,000마리를 처치했다",
		"icon": "res://assets/art/ui/icon_meteor.png",
	},
	{
		"id": "boss_10", "name": "보스 헌터", "stat": "boss_kills", "target": 10,
		"desc": "보스를 10회 격추했다",
		"icon": "res://assets/art/ui/icon_ultimate.png",
	},
	{
		"id": "level_30", "name": "한계 돌파", "stat": "max_level", "target": 30,
		"desc": "한 번의 런에서 Lv.30을 달성했다",
		"icon": "res://assets/art/ui/icon_core.png",
	},
	{
		"id": "evo_8", "name": "완전체", "stat": "max_evolutions", "target": 8,
		"desc": "한 번의 런에서 무기 8개를 진화시켰다",
		"icon": "res://assets/art/ui/icon_evo_galaxy.png",
	},
	{
		"id": "relic_3", "name": "유물 수집가", "stat": "max_relics", "target": 3,
		"desc": "한 번의 런에서 유물 3개를 모았다",
		"icon": "res://assets/art/ui/icon_singularity.png",
	},
	{
		"id": "legendary", "name": "전설의 장비", "stat": "legendary", "target": 1,
		"desc": "전설 등급 장비를 장착했다",
		"icon": "res://assets/art/ui/icon_equip_chest.png",
	},
	{
		"id": "endless_600", "name": "무한의 끝", "stat": "endless_best", "target": 600,
		"desc": "무한 모드에서 10분을 버텼다",
		"icon": "res://assets/art/ui/icon_clock.png",
	},
	{
		"id": "daily_1", "name": "오늘의 영웅", "stat": "daily_clears", "target": 1,
		"desc": "일일 챌린지를 클리어했다",
		"icon": "res://assets/art/ui/icon_moon.png",
	},
	{
		"id": "enhance_5", "name": "단련", "stat": "max_enhance", "target": 5,
		"desc": "장비를 Lv.5까지 강화했다",
		"icon": "res://assets/art/ui/icon_armor.png",
	},
]


static func all() -> Array:
	return LIST


static func get_achievement(id: String) -> Dictionary:
	for a in LIST:
		if String(a["id"]) == id:
			return a
	return {}


static func value(a: Dictionary) -> float:
	var stat := String(a.get("stat", ""))
	match stat:
		"first_clear":
			return 1.0 if Game.has_cleared(GameData.STAGE_ORDER[0]) else 0.0
		"final_clear":
			return 1.0 if Game.has_cleared(GameData.STAGE_ORDER[GameData.STAGE_ORDER.size() - 1]) else 0.0
		"legendary":
			return 1.0 if bool(Game.stats.get("legendary_equipped", false)) else 0.0
		"endless_best":
			return float(Game.stats.get("endless_best", 0.0))
		_:
			return float(Game.stats.get(stat, 0))


static func is_complete(a: Dictionary) -> bool:
	return value(a) >= float(a.get("target", 1))


static func progress_text(a: Dictionary) -> String:
	var stat := String(a.get("stat", ""))
	var have := value(a)
	var target := float(a.get("target", 1))
	if have >= target:
		return "달성"
	if stat == "endless_best":
		return "%s / %s" % [GameData.format_time(have), GameData.format_time(target)]
	if stat == "first_clear" or stat == "final_clear" or stat == "legendary":
		return "미달성"
	if stat == "max_level":
		return "Lv.%d / %d" % [int(have), int(target)]
	return "%d / %d" % [int(have), int(target)]
