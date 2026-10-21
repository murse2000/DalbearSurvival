class_name CharacterData
extends RefCounted

## Playable Dalbear friends: identity, base stats, traits and signature gear.

const ORDER := ["dal", "star", "frost", "ember", "shade"]

const CHARACTERS := {
	"dal": {
		"name": "달베어",
		"title": "달빛 수호자",
		"tag": "MOON GUARDIAN",
		"desc": "달빛을 먹고 자란 곰. 어떤 장비든 안정적으로 소화하는 올라운더.",
		"trait_name": "달빛의 가호",
		"trait_desc": "방어 +1. 균형 잡힌 체력과 피해로 어떤 빌드든 무난하게 운용합니다.",
		"color": Color(1.0, 0.816, 0.424),
		"sheet": "res://assets/art/char/player_sheet.png",
		"max_hp": 100.0,
		"speed": 122.0,
		"damage": 1.0,
		"cooldown": 1.0,
		"armor": 1.0,
		"crit": 0.05,
		"regen": 0.0,
		"pickup": 48.0,
		"dash_cd": 2.0,
		"fallback_weapon": "moon_shot",
		"signature": ["dal_blade", "dal_plate", "dal_pendant"],
	},
	"star": {
		"name": "별곰",
		"title": "별빛 추적자",
		"tag": "STARGAZER",
		"desc": "별의 궤적을 읽고 가장 먼 적까지 꿰뚫는 사수. 빠른 공격 대신 몸이 가볍습니다.",
		"trait_name": "별빛 집중",
		"trait_desc": "공격 대기 -12%, 피해 +12%, 최대 체력 -14%. 원거리 무기와 궁합이 좋습니다.",
		"color": Color(0.45, 0.72, 1.0),
		"sheet": "res://assets/art/char/friend_star.png",
		"max_hp": 86.0,
		"speed": 126.0,
		"damage": 1.12,
		"cooldown": 0.88,
		"armor": 0.0,
		"crit": 0.08,
		"regen": 0.1,
		"pickup": 54.0,
		"dash_cd": 2.0,
		"fallback_weapon": "laser",
		"signature": ["star_wand", "star_robe", "star_ring"],
	},
	"frost": {
		"name": "서리곰",
		"title": "빙하의 방패",
		"tag": "FROST WARDEN",
		"desc": "차가운 갑주로 전선을 버티는 수호자. 느리지만 좀처럼 쓰러지지 않습니다.",
		"trait_name": "서리 갑주",
		"trait_desc": "방어 +2.5, 최대 체력 +30%, 이동 속도 -8%. 적에게 파고들어 버티는 데 강합니다.",
		"color": Color(0.55, 0.95, 0.96),
		"sheet": "res://assets/art/char/friend_frost.png",
		"max_hp": 130.0,
		"speed": 112.0,
		"damage": 0.94,
		"cooldown": 1.04,
		"armor": 2.5,
		"crit": 0.04,
		"regen": 0.2,
		"pickup": 44.0,
		"dash_cd": 2.2,
		"fallback_weapon": "pulse",
		"signature": ["frost_axe", "frost_armor", "frost_amulet"],
	},
	"ember": {
		"name": "불꽃곰",
		"title": "잿불의 창",
		"tag": "EMBER LANCER",
		"desc": "불씨를 품은 돌격형 곰. 빠르게 파고들어 화력으로 밀어붙입니다.",
		"trait_name": "불씨",
		"trait_desc": "피해 +18%, 이동 속도 +7%, 최대 체력 -8%. 화력과 기동력에 특화되어 있습니다.",
		"color": Color(1.0, 0.52, 0.28),
		"sheet": "res://assets/art/char/friend_ember.png",
		"max_hp": 92.0,
		"speed": 130.0,
		"damage": 1.18,
		"cooldown": 0.96,
		"armor": 0.0,
		"crit": 0.06,
		"regen": 0.0,
		"pickup": 50.0,
		"dash_cd": 1.8,
		"fallback_weapon": "moon_shot",
		"signature": ["ember_spear", "ember_gloves", "ember_ring"],
	},
	"shade": {
		"name": "그림자곰",
		"title": "밤의 발자국",
		"tag": "NIGHT STEPPER",
		"desc": "달빛이 닿지 않는 곳을 걷는 곰. 대시와 치명타로 적의 빈틈을 찌릅니다.",
		"trait_name": "그림자 보법",
		"trait_desc": "대시 쿨다운 -35%, 치명타 +5%, 최대 체력 -16%. 짧은 대시로 계속 회피합니다.",
		"color": Color(0.72, 0.48, 0.95),
		"sheet": "res://assets/art/char/friend_shade.png",
		"max_hp": 84.0,
		"speed": 136.0,
		"damage": 1.02,
		"cooldown": 0.92,
		"armor": 0.5,
		"crit": 0.10,
		"regen": 0.0,
		"pickup": 52.0,
		"dash_cd": 1.3,
		"fallback_weapon": "satellite",
		"signature": ["shade_dagger", "shade_cloak", "shade_ring"],
	},
}


static func get_character(id: String) -> Dictionary:
	return CHARACTERS.get(id, CHARACTERS["dal"])


static func display_name(id: String) -> String:
	return String(get_character(id)["name"])


static func color(id: String) -> Color:
	return get_character(id)["color"]


static func sheet(id: String) -> String:
	return String(get_character(id)["sheet"])
