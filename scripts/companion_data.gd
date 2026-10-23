class_name CompanionData
extends RefCounted

## Moon companions unlocked by the altar's companion level.

const LIST := [
	{
		"id": "star", "name": "별이", "title": "MOON BOLT",
		"desc": "가장 가까운 적에게 달빛 광선을 쏩니다.",
		"element": "frost", "kind": "bolt", "unlock": 1,
		"damage": 1.0, "interval": 1.0,
		"icon": "res://assets/art/ui/icon_star.png",
		"sheet": "res://assets/art/char/friend_star.png",
		"color": Color(0.72, 0.9, 1.0),
	},
	{
		"id": "frost", "name": "서리", "title": "FROST SHARD",
		"desc": "서로 다른 두 적을 얼려 이동을 늦춥니다.",
		"element": "frost", "kind": "double", "unlock": 2,
		"damage": 0.72, "interval": 1.1,
		"icon": "res://assets/art/ui/icon_coolant.png",
		"sheet": "res://assets/art/char/friend_frost.png",
		"color": Color(0.6, 0.86, 1.0),
	},
	{
		"id": "ember", "name": "잿불", "title": "EMBER ORB",
		"desc": "작은 불꽃 폭발로 주변을 태웁니다.",
		"element": "fire", "kind": "aoe", "unlock": 3,
		"damage": 0.9, "interval": 1.25,
		"icon": "res://assets/art/ui/icon_meteor.png",
		"sheet": "res://assets/art/char/friend_ember.png",
		"color": Color(1.0, 0.62, 0.3),
	},
	{
		"id": "shade", "name": "그림자", "title": "VOID DAGGER",
		"desc": "공허 단검으로 강한 치명타를 노립니다.",
		"element": "void", "kind": "crit", "unlock": 4,
		"damage": 1.2, "interval": 1.15,
		"icon": "res://assets/art/ui/icon_singularity.png",
		"sheet": "res://assets/art/char/friend_shade.png",
		"color": Color(0.8, 0.58, 1.0),
	},
	{
		"id": "dal", "name": "달", "title": "MOON WARD",
		"desc": "주기적으로 체력을 회복하고 약한 빛을 쏩니다.",
		"element": "shock", "kind": "heal", "unlock": 5,
		"damage": 0.55, "interval": 1.35,
		"icon": "res://assets/art/ui/icon_moon.png",
		"sheet": "res://assets/art/char/player_sheet.png",
		"color": Color(1.0, 0.86, 0.48),
	},
]


static func all() -> Array:
	return LIST


static func get_companion(id: String) -> Dictionary:
	for companion in LIST:
		if String(companion["id"]) == id:
			return companion
	return LIST[0]


static func ids() -> Array:
	var out: Array = []
	for companion in LIST:
		out.append(String(companion["id"]))
	return out
