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
	{
		"id": "wins_25", "name": "달빛 순찰자", "stat": "wins", "target": 25,
		"desc": "전선을 25회 클리어했다",
		"icon": "res://assets/art/ui/icon_star.png",
	},
	{
		"id": "wins_100", "name": "새벽의 수호자", "stat": "wins", "target": 100,
		"desc": "전선을 100회 클리어했다",
		"icon": "res://assets/art/ui/icon_trophy.png",
	},
	{
		"id": "runs_200", "name": "끝없는 도전", "stat": "runs", "target": 200,
		"desc": "총 200번의 런을 시작했다",
		"icon": "res://assets/art/ui/icon_clock.png",
	},
	{
		"id": "hard_10", "name": "가혹한 새벽", "stat": "hard_wins", "target": 10,
		"desc": "어려움 난이도에서 10회 클리어",
		"icon": "res://assets/art/ui/icon_core.png",
	},
	{
		"id": "hard_50", "name": "어둠의 정복자", "stat": "hard_wins", "target": 50,
		"desc": "어려움 난이도에서 50회 클리어",
		"icon": "res://assets/art/ui/icon_ultimate.png",
	},
	{
		"id": "nightmare_1", "name": "악몽 생존자", "stat": "nightmare_wins", "target": 1,
		"desc": "심연 난이도를 클리어했다",
		"icon": "res://assets/art/ui/icon_singularity.png",
	},
	{
		"id": "nightmare_10", "name": "악몽의 군주", "stat": "nightmare_wins", "target": 10,
		"desc": "심연 난이도에서 10회 클리어",
		"icon": "res://assets/art/ui/icon_evo_galaxy.png",
	},
	{
		"id": "flawless_1", "name": "무결점 방어", "stat": "flawless_wins", "target": 1,
		"desc": "피격 없이 전선을 클리어했다",
		"icon": "res://assets/art/ui/icon_armor.png",
	},
	{
		"id": "flawless_10", "name": "완벽한 새벽", "stat": "flawless_wins", "target": 10,
		"desc": "피격 없이 10회 클리어했다",
		"icon": "res://assets/art/ui/icon_star.png",
	},
	{
		"id": "kills_50000", "name": "전장의 폭풍", "stat": "total_kills", "target": 50000,
		"desc": "누적 50,000마리를 처치했다",
		"icon": "res://assets/art/ui/icon_meteor.png",
	},
	{
		"id": "kills_100000", "name": "은하의 재앙", "stat": "total_kills", "target": 100000,
		"desc": "누적 100,000마리를 처치했다",
		"icon": "res://assets/art/ui/icon_blades.png",
	},
	{
		"id": "boss_100", "name": "함대 사냥꾼", "stat": "boss_kills", "target": 100,
		"desc": "보스를 100회 격추했다",
		"icon": "res://assets/art/ui/icon_ultimate.png",
	},
	{
		"id": "boss_500", "name": "보스의 종말", "stat": "boss_kills", "target": 500,
		"desc": "보스를 500회 격추했다",
		"icon": "res://assets/art/ui/icon_trophy.png",
	},
	{
		"id": "level_50", "name": "달빛의 경지", "stat": "max_level", "target": 50,
		"desc": "한 번의 런에서 Lv.50 달성",
		"icon": "res://assets/art/ui/icon_core.png",
	},
	{
		"id": "level_80", "name": "초월자", "stat": "max_level", "target": 80,
		"desc": "한 번의 런에서 Lv.80 달성",
		"icon": "res://assets/art/ui/icon_evo_galaxy.png",
	},
	{
		"id": "endless_1800", "name": "30분의 밤", "stat": "endless_best", "target": 1800,
		"desc": "무한 모드에서 30분 생존",
		"icon": "res://assets/art/ui/icon_clock.png",
	},
	{
		"id": "endless_3600", "name": "한 시간의 새벽", "stat": "endless_best", "target": 3600,
		"desc": "무한 모드에서 60분 생존",
		"icon": "res://assets/art/ui/icon_moon.png",
	},
	{
		"id": "daily_7", "name": "일주일의 영웅", "stat": "daily_clears", "target": 7,
		"desc": "일일 챌린지를 7회 클리어",
		"icon": "res://assets/art/ui/icon_moon.png",
	},
	{
		"id": "daily_30", "name": "한 달의 영웅", "stat": "daily_clears", "target": 30,
		"desc": "일일 챌린지를 30회 클리어",
		"icon": "res://assets/art/ui/icon_trophy.png",
	},
	{
		"id": "enhance_10", "name": "강화의 경지", "stat": "max_enhance", "target": 10,
		"desc": "장비를 Lv.10까지 강화했다",
		"icon": "res://assets/art/ui/icon_armor.png",
	},
	{
		"id": "enhance_15", "name": "전설의 대장장이", "stat": "max_enhance", "target": 15,
		"desc": "장비를 Lv.15까지 강화했다",
		"icon": "res://assets/art/ui/icon_core.png",
	},
	{
		"id": "relic_10", "name": "유물 박물관", "stat": "max_relics", "target": 10,
		"desc": "한 번의 런에서 유물 10개를 모았다",
		"icon": "res://assets/art/ui/icon_singularity.png",
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
