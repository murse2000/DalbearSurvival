class_name RelicData
extends RefCounted

## In-run relics: offered three at a time at 45s / 100s / 155s. Most are
## stat trades; a few carry a special flag (revive, extra XP).

const RELICS := {
	"moon_heart": {
		"name": "달의 심장", "tag": "MOON HEART",
		"desc": "피해 +25% · 최대 체력 -20",
		"color": Color(1.0, 0.55, 0.45), "icon": "res://assets/art/ui/icon_heart.png",
		"mods": {"damage_pct": 0.25, "max_hp": -20.0},
	},
	"frost_seed": {
		"name": "서리 씨앗", "tag": "FROST SEED",
		"desc": "치명타 +8% · 최대 체력 -10",
		"color": Color(0.6, 0.88, 1.0), "icon": "res://assets/art/ui/icon_coolant.png",
		"mods": {"crit": 0.08, "max_hp": -10.0},
	},
	"greed_magnet": {
		"name": "탐욕의 자석", "tag": "GREED MAGNET",
		"desc": "자력 범위 +60 · 피해 -5%",
		"color": Color(0.85, 0.85, 0.95), "icon": "res://assets/art/ui/icon_magnet.png",
		"mods": {"pickup": 60.0, "damage_pct": -0.05},
	},
	"ember_trail": {
		"name": "잔불", "tag": "EMBER TRAIL",
		"desc": "피해 +12% · 최대 체력 -10",
		"color": Color(1.0, 0.62, 0.28), "icon": "res://assets/art/ui/icon_meteor.png",
		"mods": {"damage_pct": 0.12, "max_hp": -10.0},
	},
	"night_cloak": {
		"name": "밤의 장막", "tag": "NIGHT CLOAK",
		"desc": "방어 +3 · 이동 속도 -8%",
		"color": Color(0.66, 0.58, 0.9), "icon": "res://assets/art/ui/icon_armor.png",
		"mods": {"armor": 3.0, "speed_pct": -0.08},
	},
	"star_shard": {
		"name": "별의 파편", "tag": "STAR SHARD",
		"desc": "치명타 +10% · 최대 체력 -20",
		"color": Color(1.0, 0.86, 0.5), "icon": "res://assets/art/ui/icon_star.png",
		"mods": {"crit": 0.10, "max_hp": -20.0},
	},
	"swift_anklet": {
		"name": "질풍 발찌", "tag": "SWIFT ANKLET",
		"desc": "이동 속도 +12% · 방어 -1",
		"color": Color(0.55, 0.95, 0.8), "icon": "res://assets/art/ui/icon_boots.png",
		"mods": {"speed_pct": 0.12, "armor": -1.0},
	},
	"bear_patience": {
		"name": "곰의 인내", "tag": "BEAR PATIENCE",
		"desc": "최대 체력 +30 · 이동 속도 -5%",
		"color": Color(0.92, 0.78, 0.58), "icon": "res://assets/art/ui/icon_heart.png",
		"mods": {"max_hp": 30.0, "speed_pct": -0.05},
	},
	"hunter_eye": {
		"name": "사냥꾼의 눈", "tag": "HUNTER EYE",
		"desc": "치명타 +6% · 자력 범위 -20",
		"color": Color(0.72, 0.9, 1.0), "icon": "res://assets/art/ui/icon_laser.png",
		"mods": {"crit": 0.06, "pickup": -20.0},
	},
	"time_sand": {
		"name": "시간의 모래", "tag": "TIME SAND",
		"desc": "공격 대기 -8% · 이동 속도 -6%",
		"color": Color(0.9, 0.82, 0.55), "icon": "res://assets/art/ui/icon_clock.png",
		"mods": {"cooldown_pct": 0.08, "speed_pct": -0.06},
	},
	"life_loop": {
		"name": "생명의 순환", "tag": "LIFE LOOP",
		"desc": "초당 재생 +1.2 · 최대 체력 -15",
		"color": Color(0.6, 1.0, 0.72), "icon": "res://assets/art/ui/icon_nano.png",
		"mods": {"regen": 1.2, "max_hp": -15.0},
	},
	"war_drum": {
		"name": "전쟁의 북", "tag": "WAR DRUM",
		"desc": "피해 +18% · 방어 -2",
		"color": Color(1.0, 0.48, 0.4), "icon": "res://assets/art/ui/icon_core.png",
		"mods": {"damage_pct": 0.18, "armor": -2.0},
	},
	"phoenix_heart": {
		"name": "불굴의 심장", "tag": "UNDYING HEART",
		"desc": "치명적 피해 1회 무효 · 최대 체력 -20",
		"color": Color(1.0, 0.72, 0.35), "icon": "res://assets/art/ui/icon_ultimate.png",
		"mods": {"revive": 1, "max_hp": -20.0},
	},
	"moon_lens": {
		"name": "달빛 렌즈", "tag": "MOON LENS",
		"desc": "경험치 +20% · 자력 범위 -20",
		"color": Color(0.75, 0.86, 1.0), "icon": "res://assets/art/ui/icon_moon.png",
		"mods": {"xp_mult": 0.20, "pickup": -20.0},
	},
	"bulwark": {
		"name": "성벽의 맹세", "tag": "BULWARK OATH",
		"desc": "방어 +2.5 · 이동 속도 -6%",
		"color": Color(0.72, 0.78, 0.88), "icon": "res://assets/art/ui/icon_equip_chest.png",
		"mods": {"armor": 2.5, "speed_pct": -0.06},
	},
}


static func get_relic(id: String) -> Dictionary:
	return RELICS.get(id, {})


static func all_ids() -> Array:
	return RELICS.keys()


static func random_choices(count: int, owned: Array) -> Array:
	var pool: Array = []
	for id in RELICS.keys():
		if not (id in owned):
			pool.append(id)
	pool.shuffle()
	var out: Array = []
	for i in mini(count, pool.size()):
		var id := String(pool[i])
		var info: Dictionary = RELICS[id]
		var entry: Dictionary = info.duplicate(true)
		entry["id"] = id
		out.append(entry)
	return out
