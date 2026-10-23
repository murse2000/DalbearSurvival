class_name EquipmentData
extends RefCounted

## Static equipment definitions, rarity rules, stat rolls and enhancement math.

const SLOT_ORDER := [
	"helmet", "gloves", "chest", "pants", "boots", "cape",
	"main", "secondary", "ring1", "ring2", "necklace",
]
const ARMOR_ORDER := ["helmet", "gloves", "chest", "pants", "boots", "cape"]
const WEAPON_SLOTS := ["main", "secondary"]
const RING_SLOTS := ["ring1", "ring2"]
const ACCESSORY_SLOTS := ["ring1", "ring2", "necklace"]

const SLOT_LABELS := {
	"helmet": "헬멧",
	"gloves": "장갑",
	"chest": "흉갑",
	"pants": "각반",
	"boots": "부츠",
	"cape": "망토",
	"main": "주 무기",
	"secondary": "보조 무기",
	"ring1": "반지 I",
	"ring2": "반지 II",
	"necklace": "목걸이",
}

const ITEM_SLOT_LABELS := {
	"helmet": "헬멧",
	"gloves": "장갑",
	"chest": "흉갑",
	"pants": "각반",
	"boots": "부츠",
	"cape": "망토",
	"weapon": "무기",
	"ring": "반지",
	"necklace": "목걸이",
}

const RARITY_ORDER := ["common", "rare", "epic", "legendary"]
const RARITIES := {
	"common": {
		"name": "일반", "tag": "COMMON", "mult": 1.0, "max_level": 5,
		"shard_mult": 1.0, "color": Color(0.68, 0.73, 0.8),
		"prefix": "낡은", "weight": 60.0,
	},
	"rare": {
		"name": "희귀", "tag": "RARE", "mult": 1.32, "max_level": 10,
		"shard_mult": 1.45, "color": Color(0.38, 0.72, 1.0),
		"prefix": "빛나는", "weight": 27.0,
	},
	"epic": {
		"name": "에픽", "tag": "EPIC", "mult": 1.72, "max_level": 15,
		"shard_mult": 2.1, "color": Color(0.74, 0.46, 1.0),
		"prefix": "월광의", "weight": 10.0,
	},
	"legendary": {
		"name": "전설", "tag": "LEGENDARY", "mult": 2.25, "max_level": 20,
		"shard_mult": 3.0, "color": Color(1.0, 0.76, 0.28),
		"prefix": "달을 삼킨", "weight": 3.0,
	},
}

const BASE_NAMES := {
	"helmet": "투구",
	"gloves": "장갑",
	"chest": "흉갑",
	"pants": "각반",
	"boots": "부츠",
	"cape": "망토",
	"ring": "반지",
	"necklace": "목걸이",
}

const BASE_STATS := {
	"helmet": {"max_hp": 8.0, "armor": 0.4, "crit": 0.005},
	"gloves": {"damage_pct": 0.04, "cooldown_pct": 0.02, "crit": 0.008},
	"chest": {"max_hp": 16.0, "armor": 0.8},
	"pants": {"max_hp": 10.0, "speed_pct": 0.02, "pickup": 4.0},
	"boots": {"speed_pct": 0.05, "pickup": 8.0},
	"cape": {"armor": 0.5, "regen": 0.15, "cooldown_pct": 0.015},
	"weapon": {"damage_pct": 0.06, "cooldown_pct": 0.02},
	"ring": {"crit": 0.015, "damage_pct": 0.02, "pickup": 6.0},
	"necklace": {"max_hp": 6.0, "crit": 0.01, "regen": 0.2},
}

const STAT_ORDER := [
	"max_hp", "armor", "damage_pct", "cooldown_pct",
	"speed_pct", "crit", "pickup", "regen",
]

## One-character type tags so every icon can be told apart at a glance.
const ITEM_SHORT := {
	"helmet": "헬", "gloves": "장", "chest": "흉", "pants": "각",
	"boots": "부", "cape": "망", "weapon": "무", "ring": "반", "necklace": "목",
}

const TYPE_COLORS := {
	"helmet": Color(0.55, 0.74, 0.98), "gloves": Color(0.5, 0.88, 0.95),
	"chest": Color(0.46, 0.66, 0.98), "pants": Color(0.62, 0.72, 0.92),
	"boots": Color(0.56, 0.85, 0.7), "cape": Color(0.76, 0.6, 0.98),
	"weapon": Color(1.0, 0.68, 0.32), "ring": Color(1.0, 0.86, 0.45),
	"necklace": Color(0.5, 0.95, 0.72),
}

const ICON_PATHS := {
	"helmet": "res://assets/art/ui/icon_equip_helmet.png",
	"gloves": "res://assets/art/ui/icon_equip_gloves.png",
	"chest": "res://assets/art/ui/icon_equip_chest.png",
	"pants": "res://assets/art/ui/icon_equip_pants.png",
	"boots": "res://assets/art/ui/icon_equip_boots.png",
	"cape": "res://assets/art/ui/icon_equip_cape.png",
	"ring": "res://assets/art/ui/icon_equip_ring.png",
	"necklace": "res://assets/art/ui/icon_equip_necklace.png",
}

const SET_BONUSES := {
	"dal": {
		"name": "달빛 수호", "two": {"max_hp": 20.0},
		"three": {"damage_pct": 0.08},
	},
	"star": {
		"name": "별빛 추적", "two": {"cooldown_pct": 0.06},
		"three": {"crit": 0.08},
	},
	"frost": {
		"name": "서리 방벽", "two": {"armor": 2.0},
		"three": {"max_hp": 30.0},
	},
	"ember": {
		"name": "잿불 사냥", "two": {"damage_pct": 0.08},
		"three": {"cooldown_pct": 0.06},
	},
	"shade": {
		"name": "그림자 춤", "two": {"speed_pct": 0.05},
		"three": {"crit": 0.10},
	},
}

const SIGNATURE_SETS := {
	"dal": [
		{
			"sig_id": "dal_blade", "slot": "weapon", "weapon_id": "moon_shot",
			"name": "달빛 성검", "rarity": "epic",
			"icon_override": "res://assets/art/ui/icon_moon_shot.png",
			"bonus": {"damage_pct": 0.08, "crit": 0.02},
		},
		{
			"sig_id": "dal_plate", "slot": "chest", "name": "달빛 수호 갑주",
			"rarity": "epic", "bonus": {"max_hp": 20.0, "armor": 1.2},
		},
		{
			"sig_id": "dal_pendant", "slot": "necklace", "name": "달빛 성흔",
			"rarity": "epic", "bonus": {"max_hp": 10.0, "regen": 0.5},
		},
	],
	"star": [
		{
			"sig_id": "star_wand", "slot": "weapon", "weapon_id": "laser",
			"name": "별의 지팡이", "rarity": "epic",
			"icon_override": "res://assets/art/ui/icon_laser.png",
			"bonus": {"damage_pct": 0.08, "cooldown_pct": 0.06, "crit": 0.02},
		},
		{
			"sig_id": "star_robe", "slot": "cape", "name": "별빛 로브",
			"rarity": "epic", "bonus": {"cooldown_pct": 0.05, "regen": 0.4, "speed_pct": 0.03},
		},
		{
			"sig_id": "star_ring", "slot": "ring", "name": "별의 반지",
			"rarity": "epic", "bonus": {"crit": 0.03, "damage_pct": 0.04},
		},
	],
	"frost": [
		{
			"sig_id": "frost_axe", "slot": "weapon", "weapon_id": "pulse",
			"name": "서리 도끼", "rarity": "epic",
			"icon_override": "res://assets/art/ui/icon_pulse.png",
			"bonus": {"damage_pct": 0.05, "armor": 1.0},
		},
		{
			"sig_id": "frost_armor", "slot": "chest", "name": "빙하 갑주",
			"rarity": "epic", "bonus": {"max_hp": 30.0, "armor": 2.0},
		},
		{
			"sig_id": "frost_amulet", "slot": "necklace", "name": "서리 심장",
			"rarity": "epic", "bonus": {"max_hp": 12.0, "regen": 0.8},
		},
	],
	"ember": [
		{
			"sig_id": "ember_spear", "slot": "weapon", "weapon_id": "moon_shot",
			"name": "화염 창", "rarity": "epic",
			"icon_override": "res://assets/art/ui/icon_moon_shot.png",
			"bonus": {"damage_pct": 0.12, "cooldown_pct": 0.02},
		},
		{
			"sig_id": "ember_gloves", "slot": "gloves", "name": "불꽃 장갑",
			"rarity": "epic", "bonus": {"damage_pct": 0.08, "crit": 0.02},
		},
		{
			"sig_id": "ember_ring", "slot": "ring", "name": "잿불 반지",
			"rarity": "epic", "bonus": {"damage_pct": 0.05, "speed_pct": 0.03},
		},
	],
	"shade": [
		{
			"sig_id": "shade_dagger", "slot": "weapon", "weapon_id": "satellite",
			"name": "그림자 단검", "rarity": "epic",
			"icon_override": "res://assets/art/ui/icon_satellite.png",
			"bonus": {"crit": 0.04, "speed_pct": 0.04},
		},
		{
			"sig_id": "shade_cloak", "slot": "cape", "name": "밤그늘 망토",
			"rarity": "epic", "bonus": {"speed_pct": 0.06, "cooldown_pct": 0.04},
		},
		{
			"sig_id": "shade_ring", "slot": "ring", "name": "달그림자 반지",
			"rarity": "epic", "bonus": {"crit": 0.04, "pickup": 10.0},
		},
	],
}


static func signature_set(character_id: String) -> Array:
	return SIGNATURE_SETS.get(character_id, [])


static func set_name(character_id: String) -> String:
	return String(SET_BONUSES.get(character_id, {}).get("name", ""))


static func set_bonus_for(character_id: String, count: int) -> Dictionary:
	var info: Dictionary = SET_BONUSES.get(character_id, {})
	if info.is_empty():
		return {}
	var out := {}
	if count >= 2:
		for key in info.get("two", {}):
			out[key] = float(out.get(key, 0.0)) + float(info["two"][key])
	if count >= 3:
		for key in info.get("three", {}):
			out[key] = float(out.get(key, 0.0)) + float(info["three"][key])
	return out


static func set_bonus_text(character_id: String, count: int) -> String:
	var info: Dictionary = SET_BONUSES.get(character_id, {})
	if info.is_empty():
		return ""
	var two: Dictionary = info.get("two", {})
	var three: Dictionary = info.get("three", {})
	var parts: Array = []
	if not two.is_empty():
		parts.append(("2세트 " + stat_summary_from(two)) if count >= 2 else ("2세트 " + stat_summary_from(two)))
	if not three.is_empty():
		parts.append(("3세트 " + stat_summary_from(three)))
	return "%s %d/3 · %s" % [String(info["name"]), count, " / ".join(parts)]


static func stat_summary_from(stats: Dictionary) -> String:
	var parts: Array = []
	for key in STAT_ORDER:
		if stats.has(key):
			parts.append(stat_line(key, float(stats[key])))
	return " · ".join(parts)


static func is_signature(item: Dictionary) -> bool:
	return String(item.get("character", "")) != ""


static func item_character(item: Dictionary) -> String:
	return String(item.get("character", ""))


static func affinity_label(item: Dictionary) -> String:
	var cid := item_character(item)
	if cid == "":
		return ""
	return "%s 전용" % CharacterData.display_name(cid)


static func display_color(item: Dictionary) -> Color:
	if is_signature(item):
		return CharacterData.color(item_character(item))
	return rarity_color(String(item.get("rarity", "common")))


static func make_signature_item(character_id: String, template: Dictionary,
		level: int = 1) -> Dictionary:
	var item := make_item(String(template.get("slot", "weapon")),
		String(template.get("rarity", "epic")), level,
		String(template.get("weapon_id", "")))
	item["character"] = character_id
	item["signature"] = true
	item["sig_id"] = String(template.get("sig_id", ""))
	item["name"] = String(template.get("name", item_name(item)))
	item["bonus"] = (template.get("bonus", {}) as Dictionary).duplicate(true)
	var icon := String(template.get("icon_override", ""))
	if icon != "":
		item["icon_override"] = icon
	return item


static func rarity(id: String) -> Dictionary:
	return RARITIES.get(id, RARITIES["common"])


static func rarity_name(id: String) -> String:
	return String(rarity(id)["name"])


static func rarity_color(id: String) -> Color:
	return rarity(id)["color"]


static func item_short(item: Dictionary) -> String:
	return String(ITEM_SHORT.get(String(item.get("slot", "")), "장"))


static func slot_short(slot: String) -> String:
	if slot in WEAPON_SLOTS:
		return "무"
	if slot in RING_SLOTS:
		return "반"
	return String(ITEM_SHORT.get(slot, "장"))


static func type_color(item: Dictionary) -> Color:
	return TYPE_COLORS.get(String(item.get("slot", "")), Color(0.7, 0.74, 0.82))


static func is_legendary(item: Dictionary) -> bool:
	return String(item.get("rarity", "common")) == "legendary"


## Per-stat comparison between `item` and the currently equipped `current`.
## `lower_better` marks stats where a negative delta is an upgrade.
static func stat_compare(item: Dictionary, current: Dictionary) -> Array:
	var a := stats_for(item)
	var b := {} if current.is_empty() else stats_for(current)
	var out: Array = []
	for key in STAT_ORDER:
		if not a.has(key) and not b.has(key):
			continue
		var value := float(a.get(key, 0.0))
		var before := float(b.get(key, 0.0))
		out.append({
			"key": key,
			"value": value,
			"current": before,
			"delta": value - before,
			"lower_better": key == "cooldown_pct",
		})
	return out


static func max_level(item: Dictionary) -> int:
	return int(rarity(String(item.get("rarity", "common")))["max_level"])


static func level_scale(level: int) -> float:
	return 1.0 + float(maxi(0, level - 1)) * 0.085


static func item_name(item: Dictionary) -> String:
	var custom := String(item.get("name", ""))
	if custom != "":
		return custom
	var prefix := String(rarity(String(item.get("rarity", "common")))["prefix"])
	var slot := String(item.get("slot", "helmet"))
	if slot == "weapon":
		var wid := String(item.get("weapon_id", "moon_shot"))
		var info: Dictionary = GameData.WEAPONS.get(wid, GameData.WEAPONS["moon_shot"])
		return "%s %s" % [prefix, String(info["name"])]
	return "%s %s" % [prefix, String(BASE_NAMES.get(slot, "장비"))]


static func item_icon(item: Dictionary) -> String:
	var override := String(item.get("icon_override", ""))
	if override != "":
		return override
	var slot := String(item.get("slot", "helmet"))
	if slot == "weapon":
		var wid := String(item.get("weapon_id", "moon_shot"))
		var info: Dictionary = GameData.WEAPONS.get(wid, GameData.WEAPONS["moon_shot"])
		return String(info["icon"])
	return String(ICON_PATHS.get(slot, ICON_PATHS["helmet"]))


static func type_label(item: Dictionary) -> String:
	if is_signature(item):
		match String(item.get("slot", "")):
			"weapon":
				return "전용 무기"
			"ring", "necklace":
				return "전용 악세서리"
			_:
				return "전용 방어구"
	var slot := String(item.get("slot", "helmet"))
	if slot == "weapon":
		var wid := String(item.get("weapon_id", "moon_shot"))
		var info: Dictionary = GameData.WEAPONS.get(wid, GameData.WEAPONS["moon_shot"])
		return String(info["name"])
	return String(ITEM_SLOT_LABELS.get(slot, "장비"))


static func target_slots(item_slot: String) -> Array:
	if item_slot == "weapon":
		return WEAPON_SLOTS.duplicate()
	if item_slot == "ring":
		return RING_SLOTS.duplicate()
	return [item_slot]


static func slot_accepts(item_slot: String, target_slot: String) -> bool:
	return target_slot in target_slots(item_slot)


static func group_of(item_slot: String) -> String:
	if item_slot == "weapon":
		return "weapon"
	if item_slot in ["ring", "necklace"]:
		return "accessory"
	return "armor"


static func group_name(group: String) -> String:
	match group:
		"armor":
			return "방어구"
		"weapon":
			return "무기"
		"accessory":
			return "악세서리"
	return "전체"


static func stats_for(item: Dictionary) -> Dictionary:
	var slot := String(item.get("slot", "helmet"))
	var base: Dictionary = BASE_STATS.get(slot, BASE_STATS["helmet"])
	var mult := float(rarity(String(item.get("rarity", "common")))["mult"])
	mult *= level_scale(int(item.get("level", 1)))
	var out := {}
	for key in base.keys():
		var value := float(base[key]) * mult
		if key in ["max_hp", "pickup"]:
			out[key] = maxf(1.0, roundf(value))
		elif key in ["armor", "regen"]:
			out[key] = snappedf(maxf(0.1, value), 0.1)
		else:
			out[key] = value
	var bonus: Dictionary = item.get("bonus", {})
	for key in bonus.keys():
		var value := float(bonus[key]) * mult
		out[key] = float(out.get(key, 0.0)) + value
	return out


static func stat_line(key: String, value: float) -> String:
	match key:
		"max_hp":
			return "체력 +%d" % int(round(value))
		"armor":
			return "방어 +%.1f" % value
		"damage_pct":
			return "피해 +%.1f%%" % (value * 100.0)
		"cooldown_pct":
			return "공격 대기 -%.1f%%" % (value * 100.0)
		"speed_pct":
			return "이동 속도 +%.1f%%" % (value * 100.0)
		"crit":
			return "치명타 +%.1f%%" % (value * 100.0)
		"pickup":
			return "자력 범위 +%d" % int(round(value))
		"regen":
			return "초당 재생 +%.1f" % value
	return key


static func stat_lines(item: Dictionary) -> Array:
	var stats := stats_for(item)
	var lines: Array = []
	for key in STAT_ORDER:
		if stats.has(key):
			lines.append(stat_line(key, float(stats[key])))
	return lines


static func stat_summary(item: Dictionary) -> String:
	var lines := stat_lines(item)
	if lines.is_empty():
		return ""
	return " · ".join(lines.slice(0, mini(2, lines.size())))


static func item_power(item: Dictionary) -> float:
	var stats := stats_for(item)
	var score := 0.0
	score += float(stats.get("max_hp", 0.0)) * 1.0
	score += float(stats.get("armor", 0.0)) * 18.0
	score += float(stats.get("damage_pct", 0.0)) * 520.0
	score += float(stats.get("cooldown_pct", 0.0)) * 430.0
	score += float(stats.get("speed_pct", 0.0)) * 460.0
	score += float(stats.get("crit", 0.0)) * 720.0
	score += float(stats.get("pickup", 0.0)) * 0.55
	score += float(stats.get("regen", 0.0)) * 34.0
	return score


static func enhance_cost(item: Dictionary) -> int:
	var r := rarity(String(item.get("rarity", "common")))
	var lv := maxi(1, int(item.get("level", 1)))
	return int(round((10.0 + float(lv) * 7.0) * float(r["shard_mult"])))


static func dismantle_value(item: Dictionary) -> int:
	var r := rarity(String(item.get("rarity", "common")))
	var lv := maxi(1, int(item.get("level", 1)))
	return maxi(3, int(round((7.0 + float(lv) * 4.0) * float(r["shard_mult"]) * 0.6)))


static func starting_weapon_level(item: Dictionary) -> int:
	if String(item.get("slot", "")) != "weapon":
		return 0
	var lv := 1 + int((maxi(1, int(item.get("level", 1))) - 1) / 4)
	return clampi(lv, 1, 4)


static func make_item(slot: String, rarity_id: String, level: int = 1,
		weapon_id: String = "") -> Dictionary:
	if not RARITIES.has(rarity_id):
		rarity_id = "common"
	if slot == "weapon":
		if not GameData.WEAPONS.has(weapon_id):
			var keys: Array = GameData.WEAPONS.keys()
			weapon_id = String(keys[randi() % keys.size()])
	else:
		weapon_id = ""
	return {
		"uid": "",
		"slot": slot,
		"rarity": rarity_id,
		"level": clampi(level, 1, int(RARITIES[rarity_id]["max_level"])),
		"weapon_id": weapon_id,
	}


static func roll_rarity(luck: float = 0.0) -> String:
	var weights := {
		"common": maxf(20.0, 60.0 - luck * 8.0),
		"rare": 27.0 + luck * 2.0,
		"epic": 10.0 + luck * 5.0,
		"legendary": 3.0 + luck * 2.2,
	}
	var total := 0.0
	for id in RARITY_ORDER:
		total += float(weights[id])
	var roll := randf() * total
	for id in RARITY_ORDER:
		roll -= float(weights[id])
		if roll <= 0.0:
			return id
	return "common"


static func roll_drop_slot() -> String:
	var r := randf()
	if r < 0.56:
		return String(ARMOR_ORDER[randi() % ARMOR_ORDER.size()])
	if r < 0.76:
		return "weapon"
	if r < 0.92:
		return "ring"
	return "necklace"


static func random_item(rarity_id: String, level: int = 1) -> Dictionary:
	return make_item(roll_drop_slot(), rarity_id, level)
