class_name AltarData
extends RefCounted

## Permanent, shard-funded upgrades bought at the moon altar.

const LIST := [
	{
		"id": "vitality", "name": "달빛 생명", "desc": "최대 체력을 영구히 증가시킵니다.",
		"stat": "max_hp", "per": 6.0, "max": 10, "base_cost": 40, "growth": 1.45,
		"icon": "res://assets/art/ui/icon_heart.png",
	},
	{
		"id": "power", "name": "달빛 분노", "desc": "모든 무기 피해를 영구히 증가시킵니다.",
		"stat": "damage_pct", "per": 0.03, "max": 10, "base_cost": 55, "growth": 1.5,
		"icon": "res://assets/art/ui/icon_blades.png",
	},
	{
		"id": "swiftness", "name": "달빛 걸음", "desc": "이동 속도를 영구히 증가시킵니다.",
		"stat": "speed_pct", "per": 0.02, "max": 8, "base_cost": 45, "growth": 1.45,
		"icon": "res://assets/art/ui/icon_boots.png",
	},
	{
		"id": "magnet", "name": "달빛 자력", "desc": "자력 범위를 영구히 증가시킵니다.",
		"stat": "pickup", "per": 8.0, "max": 8, "base_cost": 35, "growth": 1.4,
		"icon": "res://assets/art/ui/icon_magnet.png",
	},
	{
		"id": "wisdom", "name": "달빛 지혜", "desc": "획득 경험치를 영구히 증가시킵니다.",
		"stat": "xp_pct", "per": 0.03, "max": 8, "base_cost": 50, "growth": 1.5,
		"icon": "res://assets/art/ui/icon_coolant.png",
	},
	{
		"id": "fortune", "name": "달빛 행운", "desc": "치명타 확률을 영구히 증가시킵니다.",
		"stat": "crit", "per": 0.01, "max": 8, "base_cost": 60, "growth": 1.55,
		"icon": "res://assets/art/ui/icon_star.png",
	},
	{
		"id": "companion", "name": "달빛 동료", "desc": "동료 해금 · 공격력/속도 증가",
		"stat": "companion", "per": 1.0, "max": 5, "base_cost": 120, "growth": 1.9,
		"icon": "res://assets/art/ui/icon_ultimate.png",
	},
]


static func all() -> Array:
	return LIST


static func get_upgrade(id: String) -> Dictionary:
	for upgrade in LIST:
		if String(upgrade["id"]) == id:
			return upgrade
	return {}


static func cost(id: String, level: int) -> int:
	var upgrade := get_upgrade(id)
	if upgrade.is_empty():
		return 0
	return int(round(float(upgrade["base_cost"]) * pow(float(upgrade["growth"]), maxi(0, level))))


static func effect_text(upgrade: Dictionary, level: int) -> String:
	var stat := String(upgrade.get("stat", ""))
	var value := float(upgrade.get("per", 0.0)) * float(level)
	match stat:
		"max_hp":
			return "체력 +%d" % int(round(value))
		"pickup":
			return "자력 +%d" % int(round(value))
		"damage_pct", "speed_pct", "xp_pct", "crit":
			return "%s +%.0f%%" % [
				{"damage_pct": "피해", "speed_pct": "이동", "xp_pct": "경험치", "crit": "치명타"}[stat],
				value * 100.0,
			]
		"companion":
			if level <= 0:
				return "미해금"
			var names := ["별이", "서리", "잿불", "그림자", "달"]
			return "Lv.%d · %s" % [level, names[clampi(level - 1, 0, names.size() - 1)]]
	return String(upgrade.get("desc", ""))
