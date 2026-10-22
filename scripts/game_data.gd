class_name GameData
extends RefCounted

## All balance data in one place. Pure static data, no nodes.

const ARENA_HALF := 1700.0
const DEFAULT_DURATION := 240.0
const STAGE_ORDER := ["forest", "hive", "ship"]

const WEAPONS := {
	"moon_shot": {
		"name": "달빛 탄환",
		"tag": "MOON SHOT",
		"desc": "가장 가까운 외계인을 향해 달빛 탄환을 발사합니다.",
		"icon": "res://assets/art/ui/icon_moon_shot.png",
		"scene": "res://scripts/weapons/moon_shot_weapon.gd",
		"max_level": 6,
		"color": Color(1.0, 0.816, 0.424),
	},
	"satellite": {
		"name": "위성 드론",
		"tag": "ORBIT DRONE",
		"desc": "달빛 위성이 곰 주위를 돌며 접근하는 적을 베어냅니다.",
		"icon": "res://assets/art/ui/icon_satellite.png",
		"scene": "res://scripts/weapons/satellite_weapon.gd",
		"max_level": 6,
		"color": Color(0.549, 0.886, 0.729),
	},
	"pulse": {
		"name": "문 펄스",
		"tag": "MOON PULSE",
		"desc": "달빛 충격파를 방출해 주변의 적을 밀쳐내고 피해를 줍니다.",
		"icon": "res://assets/art/ui/icon_pulse.png",
		"scene": "res://scripts/weapons/pulse_weapon.gd",
		"max_level": 6,
		"color": Color(0.6, 0.93, 0.95),
	},
	"laser": {
		"name": "성광 레이저",
		"tag": "STAR LASER",
		"desc": "가장 가까운 적을 향해 관통하는 별빛 레이저를 발사합니다.",
		"icon": "res://assets/art/ui/icon_laser.png",
		"scene": "res://scripts/weapons/laser_weapon.gd",
		"max_level": 6,
		"color": Color(0.75, 0.95, 0.85),
	},
	"meteor": {
		"name": "유성 낙하",
		"tag": "METEOR FALL",
		"desc": "하늘에서 달빛 유성을 소환해 적 밀집 지역을 폭격합니다.",
		"icon": "res://assets/art/ui/icon_meteor.png",
		"scene": "res://scripts/weapons/meteor_weapon.gd",
		"max_level": 6,
		"color": Color(1.0, 0.58, 0.25),
	},
	"chain": {
		"name": "성운 연쇄",
		"tag": "NEBULA CHAIN",
		"desc": "성운 전류가 적들 사이를 연쇄로 튕기며 감전시킵니다.",
		"icon": "res://assets/art/ui/icon_chain.png",
		"scene": "res://scripts/weapons/chain_weapon.gd",
		"max_level": 6,
		"color": Color(0.55, 0.92, 1.0),
	},
	"singularity": {
		"name": "월식 특이점",
		"tag": "ECLIPSE SINGULARITY",
		"desc": "작은 월식을 소환해 적을 끌어당기고 붕괴시킵니다.",
		"icon": "res://assets/art/ui/icon_singularity.png",
		"scene": "res://scripts/weapons/singularity_weapon.gd",
		"max_level": 6,
		"color": Color(0.78, 0.45, 1.0),
	},
	"blades": {
		"name": "월광 칼날",
		"tag": "MOONLIT BLADES",
		"desc": "달빛 칼날이 곰 주위를 회전하며 적을 베고 참격파를 방출합니다.",
		"icon": "res://assets/art/ui/icon_blades.png",
		"scene": "res://scripts/weapons/blades_weapon.gd",
		"max_level": 6,
		"color": Color(1.0, 0.82, 0.42),
	},
}

const WEAPON_STATS := {
	"moon_shot": [
		{"cooldown": 0.78, "damage": 10.0, "count": 1, "speed": 430.0, "pierce": 0},
		{"cooldown": 0.71, "damage": 13.0, "count": 1, "speed": 445.0, "pierce": 0},
		{"cooldown": 0.64, "damage": 17.0, "count": 2, "speed": 460.0, "pierce": 0},
		{"cooldown": 0.57, "damage": 22.0, "count": 2, "speed": 480.0, "pierce": 1},
		{"cooldown": 0.50, "damage": 28.0, "count": 3, "speed": 500.0, "pierce": 1},
		{"cooldown": 0.43, "damage": 36.0, "count": 3, "speed": 530.0, "pierce": 2},
	],
	"satellite": [
		{"damage": 8.0, "count": 1, "radius": 48.0, "spin": 2.1, "hit_cd": 0.50},
		{"damage": 10.0, "count": 1, "radius": 52.0, "spin": 2.3, "hit_cd": 0.46},
		{"damage": 13.0, "count": 2, "radius": 56.0, "spin": 2.5, "hit_cd": 0.43},
		{"damage": 17.0, "count": 2, "radius": 60.0, "spin": 2.7, "hit_cd": 0.40},
		{"damage": 22.0, "count": 3, "radius": 65.0, "spin": 3.0, "hit_cd": 0.36},
		{"damage": 29.0, "count": 3, "radius": 72.0, "spin": 3.3, "hit_cd": 0.32},
	],
	"pulse": [
		{"cooldown": 3.0, "damage": 16.0, "radius": 96.0, "knock": 130.0},
		{"cooldown": 2.8, "damage": 22.0, "radius": 110.0, "knock": 150.0},
		{"cooldown": 2.55, "damage": 29.0, "radius": 126.0, "knock": 170.0},
		{"cooldown": 2.3, "damage": 38.0, "radius": 142.0, "knock": 200.0},
		{"cooldown": 2.0, "damage": 49.0, "radius": 160.0, "knock": 230.0},
		{"cooldown": 1.7, "damage": 64.0, "radius": 182.0, "knock": 270.0},
	],
	"laser": [
		{"cooldown": 2.4, "damage": 34.0, "width": 20.0, "length": 430.0},
		{"cooldown": 2.2, "damage": 44.0, "width": 22.0, "length": 460.0},
		{"cooldown": 2.0, "damage": 57.0, "width": 24.0, "length": 490.0},
		{"cooldown": 1.8, "damage": 72.0, "width": 27.0, "length": 530.0},
		{"cooldown": 1.55, "damage": 92.0, "width": 31.0, "length": 580.0},
		{"cooldown": 1.3, "damage": 118.0, "width": 38.0, "length": 650.0},
	],
	"meteor": [
		{"cooldown": 3.0, "damage": 38.0, "radius": 62.0, "strikes": 1, "burn_damage": 0.0},
		{"cooldown": 2.8, "damage": 50.0, "radius": 68.0, "strikes": 1, "burn_damage": 6.0},
		{"cooldown": 2.55, "damage": 64.0, "radius": 74.0, "strikes": 2, "burn_damage": 9.0},
		{"cooldown": 2.3, "damage": 82.0, "radius": 80.0, "strikes": 2, "burn_damage": 13.0},
		{"cooldown": 2.05, "damage": 104.0, "radius": 88.0, "strikes": 3, "burn_damage": 18.0},
		{"cooldown": 1.8, "damage": 132.0, "radius": 96.0, "strikes": 3, "burn_damage": 24.0},
	],
	"chain": [
		{"cooldown": 2.6, "damage": 30.0, "chains": 1, "jumps": 4, "range": 180.0},
		{"cooldown": 2.4, "damage": 38.0, "chains": 1, "jumps": 5, "range": 190.0},
		{"cooldown": 2.2, "damage": 48.0, "chains": 2, "jumps": 5, "range": 205.0},
		{"cooldown": 1.95, "damage": 60.0, "chains": 2, "jumps": 6, "range": 220.0},
		{"cooldown": 1.7, "damage": 76.0, "chains": 3, "jumps": 7, "range": 235.0},
		{"cooldown": 1.45, "damage": 96.0, "chains": 3, "jumps": 8, "range": 255.0},
	],
	"singularity": [
		{"cooldown": 5.6, "damage": 90.0, "radius": 105.0, "pull_radius": 230.0, "pull_time": 0.75, "pull_speed": 180.0, "tick_damage": 4.0, "tick_interval": 0.25},
		{"cooldown": 5.2, "damage": 112.0, "radius": 116.0, "pull_radius": 250.0, "pull_time": 0.82, "pull_speed": 200.0, "tick_damage": 6.0, "tick_interval": 0.23},
		{"cooldown": 4.8, "damage": 138.0, "radius": 128.0, "pull_radius": 275.0, "pull_time": 0.9, "pull_speed": 220.0, "tick_damage": 8.0, "tick_interval": 0.21},
		{"cooldown": 4.4, "damage": 168.0, "radius": 140.0, "pull_radius": 300.0, "pull_time": 0.98, "pull_speed": 245.0, "tick_damage": 11.0, "tick_interval": 0.19},
		{"cooldown": 3.9, "damage": 204.0, "radius": 155.0, "pull_radius": 328.0, "pull_time": 1.05, "pull_speed": 272.0, "tick_damage": 14.0, "tick_interval": 0.17},
		{"cooldown": 3.3, "damage": 248.0, "radius": 172.0, "pull_radius": 360.0, "pull_time": 1.15, "pull_speed": 300.0, "tick_damage": 18.0, "tick_interval": 0.15},
	],
	"blades": [
		{"damage": 12.0, "count": 2, "radius": 58.0, "spin": 3.0, "hit_cd": 0.42, "wave_cd": 4.5, "wave_damage": 22.0},
		{"damage": 16.0, "count": 2, "radius": 63.0, "spin": 3.3, "hit_cd": 0.38, "wave_cd": 4.2, "wave_damage": 30.0},
		{"damage": 21.0, "count": 3, "radius": 69.0, "spin": 3.6, "hit_cd": 0.34, "wave_cd": 3.8, "wave_damage": 40.0},
		{"damage": 27.0, "count": 3, "radius": 76.0, "spin": 4.0, "hit_cd": 0.30, "wave_cd": 3.4, "wave_damage": 54.0},
		{"damage": 35.0, "count": 4, "radius": 84.0, "spin": 4.4, "hit_cd": 0.26, "wave_cd": 3.0, "wave_damage": 72.0},
		{"damage": 45.0, "count": 5, "radius": 92.0, "spin": 4.8, "hit_cd": 0.22, "wave_cd": 2.5, "wave_damage": 96.0},
	],
	"moon_barrage": [
		{"cooldown": 2.8, "damage": 58.0, "strikes": 3, "radius": 68.0},
	],
	"orbit_constellation": [
		{"damage": 20.0, "count": 6, "radius": 82.0, "spin": 3.6, "hit_cd": 0.24,
			"chain_cd": 2.4, "chain_damage": 34.0, "chain_range": 150.0, "chain_count": 5},
	],
	"gravity_collapse": [
		{"cooldown": 4.6, "damage": 95.0, "radius": 205.0, "pull_radius": 300.0,
			"pull_time": 0.8, "pull_speed": 220.0, "knock": 320.0},
	],
	"nebula_slash": [
		{"cooldown": 1.7, "damage": 52.0, "width": 26.0, "length": 700.0, "beams": 3},
	],
}

const PASSIVES := {
	"boots": {
		"name": "제트 부츠",
		"tag": "JET BOOTS",
		"desc": "이동 속도 +8%",
		"icon": "res://assets/art/ui/icon_boots.png",
		"max_level": 5,
		"color": Color(0.9, 0.78, 0.56),
	},
	"core": {
		"name": "에너지 코어",
		"tag": "POWER CORE",
		"desc": "공격 피해 +12%",
		"icon": "res://assets/art/ui/icon_core.png",
		"max_level": 5,
		"color": Color(1.0, 0.816, 0.424),
	},
	"coolant": {
		"name": "냉각 장치",
		"tag": "COOLANT",
		"desc": "공격 대기시간 -7%",
		"icon": "res://assets/art/ui/icon_coolant.png",
		"max_level": 5,
		"color": Color(0.72, 0.9, 1.0),
	},
	"heart": {
		"name": "곰의 심장",
		"tag": "BEAR HEART",
		"desc": "최대 체력 +20, 즉시 회복",
		"icon": "res://assets/art/ui/icon_heart.png",
		"max_level": 5,
		"color": Color(0.92, 0.42, 0.4),
	},
	"magnet": {
		"name": "자력 코일",
		"tag": "MAGNET COIL",
		"desc": "경험치 획득 범위 +28",
		"icon": "res://assets/art/ui/icon_magnet.png",
		"max_level": 5,
		"color": Color(0.85, 0.86, 0.9),
	},
	"star": {
		"name": "행운의 별",
		"tag": "LUCKY STAR",
		"desc": "치명타 확률 +5%",
		"icon": "res://assets/art/ui/icon_star.png",
		"max_level": 5,
		"color": Color(1.0, 0.88, 0.5),
	},
	"armor": {
		"name": "합금 외피",
		"tag": "ALLOY SKIN",
		"desc": "받는 피해 -1",
		"icon": "res://assets/art/ui/icon_armor.png",
		"max_level": 5,
		"color": Color(0.8, 0.84, 0.9),
	},
	"nano": {
		"name": "나노 재생",
		"tag": "NANO REGEN",
		"desc": "초당 체력 +0.5 회복",
		"icon": "res://assets/art/ui/icon_nano.png",
		"max_level": 5,
		"color": Color(0.55, 0.886, 0.729),
	},
}

const ENEMIES := {
	"blob": {
		"name": "젤리 침입자",
		"hp": 14.0,
		"speed": 42.0,
		"damage": 4.0,
		"xp": 1,
		"radius": 10.0,
		"texture": "res://assets/art/char/enemy_slime.png",
		"height": 26.0,
		"color": Color(0.55, 0.85, 0.55),
		"flying": false,
	},
	"drone": {
		"name": "정찰 드론",
		"hp": 10.0,
		"speed": 82.0,
		"damage": 4.0,
		"xp": 2,
		"radius": 12.0,
		"texture": "res://assets/art/char/enemy_bat_0.png",
		"height": 26.0,
		"color": Color(0.72, 0.68, 0.95),
		"flying": true,
	},
	"grey": {
		"name": "회색 침략자",
		"hp": 30.0,
		"speed": 54.0,
		"damage": 7.0,
		"xp": 3,
		"radius": 10.0,
		"texture": "res://assets/art/char/enemy_skeleton.png",
		"height": 38.0,
		"color": Color(0.75, 0.85, 0.8),
		"flying": false,
	},
	"jelly": {
		"name": "플라즈마 해파리",
		"hp": 24.0,
		"speed": 62.0,
		"damage": 6.0,
		"xp": 4,
		"radius": 12.0,
		"texture": "res://assets/art/char/enemy_ghost.png",
		"height": 36.0,
		"color": Color(0.7, 0.55, 0.95),
		"flying": true,
	},
	"mech": {
		"name": "전투 로봇",
		"hp": 120.0,
		"speed": 36.0,
		"damage": 11.0,
		"xp": 12,
		"radius": 18.0,
		"texture": "res://assets/art/char/enemy_stump.png",
		"height": 48.0,
		"color": Color(0.72, 0.78, 0.84),
		"flying": false,
	},
	"spitter": {
		"name": "산성 사수",
		"hp": 24.0,
		"speed": 46.0,
		"damage": 6.0,
		"xp": 3,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_spitter.png",
		"height": 36.0,
		"color": Color(0.58, 0.94, 0.6),
		"flying": false,
		"behavior": "spitter",
	},
	"bomber": {
		"name": "자폭 벌레",
		"hp": 20.0,
		"speed": 72.0,
		"damage": 13.0,
		"xp": 3,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_bomber.png",
		"height": 30.0,
		"color": Color(1.0, 0.6, 0.28),
		"flying": false,
		"behavior": "bomber",
	},
	"burrower": {
		"name": "땅굴 포식자",
		"hp": 36.0,
		"speed": 62.0,
		"damage": 9.0,
		"xp": 4,
		"radius": 12.0,
		"texture": "res://assets/art/char/enemy_burrower.png",
		"height": 32.0,
		"color": Color(0.66, 0.42, 0.8),
		"flying": false,
		"behavior": "burrower",
	},
	"brute": {
		"name": "군체 약탈자",
		"hp": 160.0,
		"speed": 30.0,
		"damage": 16.0,
		"xp": 16,
		"radius": 21.0,
		"texture": "res://assets/art/char/enemy_brute.png",
		"height": 58.0,
		"color": Color(0.72, 0.42, 0.6),
		"flying": false,
		"behavior": "brute",
	},
	"sentinel": {
		"name": "격벽 포탑",
		"hp": 90.0,
		"speed": 18.0,
		"damage": 11.0,
		"xp": 9,
		"radius": 17.0,
		"texture": "res://assets/art/char/enemy_sentinel.png",
		"height": 48.0,
		"color": Color(0.4, 0.9, 0.85),
		"flying": true,
		"behavior": "sentinel",
	},
	"phase": {
		"name": "위상 사냥꾼",
		"hp": 32.0,
		"speed": 74.0,
		"damage": 9.0,
		"xp": 5,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 40.0,
		"color": Color(0.72, 0.52, 0.95),
		"flying": false,
		"behavior": "phase",
	},
	"splitter": {
		"name": "분열체",
		"hp": 46.0,
		"speed": 42.0,
		"damage": 6.0,
		"xp": 4,
		"radius": 13.0,
		"texture": "res://assets/art/char/enemy_splitter.png",
		"height": 34.0,
		"color": Color(0.8, 0.45, 0.9),
		"flying": false,
		"behavior": "splitter",
	},
	"blobling": {
		"name": "분열 조각",
		"hp": 8.0,
		"speed": 64.0,
		"damage": 3.0,
		"xp": 1,
		"radius": 7.0,
		"texture": "res://assets/art/char/enemy_slime.png",
		"height": 18.0,
		"color": Color(0.55, 0.85, 0.55),
		"flying": false,
		"behavior": "blobling",
	},
	"boss_scout": {
		"name": "정찰 모선",
		"hp": 900.0,
		"speed": 30.0,
		"damage": 16.0,
		"xp": 45,
		"radius": 48.0,
		"texture": "res://assets/art/char/enemy_boss.png",
		"height": 112.0,
		"color": Color(0.6, 0.5, 0.9),
		"flying": true,
		"boss": true,
		"style": "scout",
		"scale": 0.62,
	},
	"boss_queen": {
		"name": "군체 여왕",
		"hp": 1600.0,
		"speed": 24.0,
		"damage": 18.0,
		"xp": 70,
		"radius": 52.0,
		"texture": "res://assets/art/char/enemy_queen.png",
		"height": 116.0,
		"color": Color(0.76, 0.5, 0.86),
		"flying": false,
		"boss": true,
		"style": "queen",
		"scale": 1.0,
	},
	"boss_final": {
		"name": "모선 '달을 삼킨 자'",
		"hp": 2600.0,
		"speed": 26.0,
		"damage": 22.0,
		"xp": 90,
		"radius": 62.0,
		"texture": "res://assets/art/char/enemy_boss.png",
		"height": 112.0,
		"color": Color(0.8, 0.4, 0.75),
		"flying": true,
		"boss": true,
		"style": "ship",
		"scale": 1.0,
	},
}

const BASE_STATS := {
	"max_hp": 100.0,
	"speed": 122.0,
	"damage_mult": 1.0,
	"cooldown_mult": 1.0,
	"pickup_radius": 48.0,
	"armor": 0.0,
	"crit": 0.05,
	"crit_mult": 1.75,
	"regen": 0.0,
}

## Weapon evolutions: base weapon at level 6 + its partner passive at level 3.
const EVOLUTIONS := {
	"moon_shot": {
		"id": "moon_barrage",
		"name": "월광 포격",
		"tag": "MOON BARRAGE",
		"passive": "core",
		"passive_level": 3,
		"desc": "가장 가까운 무리에 유성 달빛 3발을 소환해 폭격합니다.",
		"icon": "res://assets/art/ui/icon_evo_barrage.png",
		"color": Color(1.0, 0.86, 0.42),
		"scene": "res://scripts/weapons/moon_barrage_weapon.gd",
	},
	"satellite": {
		"id": "orbit_constellation",
		"name": "궤도 위성군",
		"tag": "ORBITAL CONSTELLATION",
		"passive": "coolant",
		"passive_level": 3,
		"desc": "위성 6기가 궤도를 채우고, 주기적으로 적들을 감전시킵니다.",
		"icon": "res://assets/art/ui/icon_evo_orbit.png",
		"color": Color(0.55, 1.0, 0.8),
		"scene": "res://scripts/weapons/orbit_constellation_weapon.gd",
	},
	"pulse": {
		"id": "gravity_collapse",
		"name": "중력 붕괴",
		"tag": "GRAVITY COLLAPSE",
		"passive": "armor",
		"passive_level": 3,
		"desc": "중력장으로 적을 끌어당긴 뒤 거대한 폭발을 일으킵니다.",
		"icon": "res://assets/art/ui/icon_evo_gravity.png",
		"color": Color(0.78, 0.48, 1.0),
		"scene": "res://scripts/weapons/gravity_collapse_weapon.gd",
	},
	"laser": {
		"id": "nebula_slash",
		"name": "성운 절단",
		"tag": "NEBULA SLASH",
		"passive": "star",
		"passive_level": 3,
		"desc": "세 갈래 성운 빔이 화면을 가로지르며 모든 적을 관통합니다.",
		"icon": "res://assets/art/ui/icon_evo_nebula.png",
		"color": Color(0.62, 0.95, 0.95),
		"scene": "res://scripts/weapons/nebula_slash_weapon.gd",
	},
}


static func evolution_for(base_id: String) -> Dictionary:
	return EVOLUTIONS.get(base_id, {})


const STAGES := {
	"forest": {
		"num": 1,
		"name": "제1전선",
		"short": "달빛 숲",
		"subtitle": "외계 함대 침공",
		"desc": "달빛 숲. 첫 번째 함대를 막아라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_scout",
		"enemies": ["blob", "drone", "jelly", "grey", "mech"],
		"enemy_icons": ["blob", "drone", "jelly"],
		"hp_scale": 1.0,
		"music_pitch": 1.0,
		"tint": Color(0.86, 0.94, 1.06),
		"accent": Color(0.55, 0.886, 0.729),
		"thumb": "res://assets/art/ui/stage_forest.png",
		"goal": "새벽까지",
		"warnings": [[55.0, "외계 증원 부대 접근"], [120.0, "회색 침략자 상륙"]],
	},
	"hive": {
		"num": 2,
		"name": "제2전선",
		"short": "군체 분화구",
		"subtitle": "포자가 바람에 흩날린다",
		"desc": "군체 분화구. 여왕을 깨우지 마라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_queen",
		"enemies": ["spitter", "bomber", "burrower", "brute", "blob"],
		"enemy_icons": ["spitter", "bomber", "brute"],
		"hp_scale": 1.16,
		"music_pitch": 0.9,
		"tint": Color(0.97, 0.84, 1.06),
		"accent": Color(0.78, 0.5, 0.92),
		"thumb": "res://assets/art/ui/stage_hive.png",
		"goal": "군체 붕괴까지",
		"warnings": [[50.0, "포자 폭풍이 몰아친다"], [118.0, "군체가 깨어난다"]],
	},
	"ship": {
		"num": 3,
		"name": "제3전선",
		"short": "모선 심장부",
		"subtitle": "달을 삼킨 자의 배",
		"desc": "모선 심장부. 격벽을 돌파하라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_final",
		"enemies": ["sentinel", "phase", "splitter", "mech", "drone"],
		"enemy_icons": ["sentinel", "phase", "splitter"],
		"hp_scale": 1.32,
		"music_pitch": 1.08,
		"tint": Color(0.84, 0.97, 1.04),
		"accent": Color(0.42, 0.9, 0.86),
		"thumb": "res://assets/art/ui/stage_ship.png",
		"goal": "탈출까지",
		"warnings": [[50.0, "격벽이 닫힌다"], [118.0, "경비 병력이 깨어난다"]],
	},
}

const DIFFICULTY_ORDER := ["moon", "normal", "dark", "abyss"]
const DIFFICULTIES := {
	"moon": {
		"name": "달빛",
		"tag": "EASY",
		"desc": "적의 체력과 공격력이 낮고, 경험치를 더 얻습니다.",
		"hp": 0.8,
		"damage": 0.7,
		"spawn": 1.2,
		"speed": 0.95,
		"boss": 0.8,
		"xp": 1.25,
		"elite": 0.015,
		"color": Color(0.72, 0.9, 1.0),
	},
	"normal": {
		"name": "표준",
		"tag": "NORMAL",
		"desc": "의도된 기본 난이도. 달베어의 첫 번째 밤.",
		"hp": 1.0,
		"damage": 1.0,
		"spawn": 1.0,
		"speed": 1.0,
		"boss": 1.0,
		"xp": 1.0,
		"elite": 0.028,
		"color": Color(0.55, 0.886, 0.729),
	},
	"dark": {
		"name": "어둠",
		"tag": "HARD",
		"desc": "적이 강해지고 더 자주 몰려옵니다. 정예 출현 증가.",
		"hp": 1.35,
		"damage": 1.25,
		"spawn": 0.85,
		"speed": 1.08,
		"boss": 1.35,
		"xp": 0.95,
		"elite": 0.045,
		"color": Color(1.0, 0.68, 0.32),
	},
	"abyss": {
		"name": "심연",
		"tag": "NIGHTMARE",
		"desc": "한 대도 아프다. 최소한의 실수만 허용되는 밤.",
		"hp": 1.75,
		"damage": 1.55,
		"spawn": 0.7,
		"speed": 1.16,
		"boss": 1.8,
		"xp": 0.85,
		"elite": 0.07,
		"color": Color(0.9, 0.35, 0.55),
	},
}


static func stage(id: String) -> Dictionary:
	return STAGES.get(id, STAGES["forest"])


static func difficulty(id: String) -> Dictionary:
	return DIFFICULTIES.get(id, DIFFICULTIES["normal"])


static func stage_duration(id: String) -> float:
	return float(stage(id)["duration"])


static func stage_boss_time(id: String) -> float:
	return float(stage(id)["boss_time"])


static func next_stage_id(id: String) -> String:
	var idx := STAGE_ORDER.find(id)
	if idx >= 0 and idx + 1 < STAGE_ORDER.size():
		return STAGE_ORDER[idx + 1]
	return ""


static func enemy_hp_mult(stage_id: String, t: float, diff_id: String) -> float:
	var st := stage(stage_id)
	var d := difficulty(diff_id)
	var p := clampf(t / float(st["duration"]), 0.0, 1.0)
	return (1.0 + p * 1.8) * float(st["hp_scale"]) * float(d["hp"])


static func enemy_damage_mult(stage_id: String, t: float, diff_id: String) -> float:
	var st := stage(stage_id)
	var d := difficulty(diff_id)
	var p := clampf(t / float(st["duration"]), 0.0, 1.0)
	return (1.0 + p * 0.6) * float(d["damage"])


static func spawn_interval(stage_id: String, t: float, diff_id: String) -> float:
	var st := stage(stage_id)
	var d := difficulty(diff_id)
	var p := clampf(t / float(st["duration"]), 0.0, 1.0)
	# 1.5x the original spawn cadence while keeping difficulty multipliers.
	return lerpf(1.05, 0.34, p) * float(d["spawn"]) / 1.5


static func spawn_batch(t: float, duration: float = 240.0) -> int:
	var p := clampf(t / maxf(1.0, duration), 0.0, 1.0)
	return 1 + int(p * 2.2) + (1 if p > 0.72 else 0)


static func stage_spawn_weights(stage_id: String, t: float) -> Dictionary:
	match stage_id:
		"hive":
			var w := {"spitter": 4.2, "blob": maxf(2.0, 8.0 - t / 50.0)}
			if t > 25.0:
				w["bomber"] = 3.0
			if t > 60.0:
				w["burrower"] = 3.0
			if t > 110.0:
				w["brute"] = 1.8
			if t > 140.0:
				w["drone"] = 1.6
			return w
		"ship":
			var w := {"drone": 4.0, "grey": 3.0}
			if t > 25.0:
				w["splitter"] = 3.2
			if t > 55.0:
				w["sentinel"] = 2.5
			if t > 85.0:
				w["phase"] = 2.8
			if t > 125.0:
				w["mech"] = 1.6
			return w
		_:
			var w := {"blob": maxf(2.0, 10.0 - t / 40.0)}
			if t > 45.0:
				w["drone"] = 3.5
			if t > 80.0:
				w["grey"] = 3.8
			if t > 125.0:
				w["jelly"] = 3.2
			if t > 165.0:
				w["mech"] = 2.2
			return w


static func weapon_stats(id: String, level: int) -> Dictionary:
	var arr: Array = WEAPON_STATS[id]
	var idx: int = clampi(level - 1, 0, arr.size() - 1)
	return arr[idx]


static func weapon_detail(id: String, level: int) -> String:
	var s := weapon_stats(id, level)
	match id:
		"moon_shot":
			return "피해 %d · 탄환 %d발 · %.2f초" % [int(s.damage), int(s.count), s.cooldown]
		"satellite":
			return "피해 %d · 위성 %d개 · 회전 %.1f" % [int(s.damage), int(s.count), s.spin]
		"pulse":
			return "피해 %d · 반경 %d · %.1f초" % [int(s.damage), int(s.radius), s.cooldown]
		"laser":
			return "피해 %d · 관통 · %.1f초" % [int(s.damage), s.cooldown]
		"meteor":
			return "피해 %d · 유성 %d발 · 반경 %d" % [int(s.damage), int(s.strikes), int(s.radius)]
		"chain":
			return "피해 %d · 연쇄 %d회 · 줄기 %d개" % [int(s.damage), int(s.jumps), int(s.chains)]
		"singularity":
			return "피해 %d · 반경 %d · %.1f초" % [int(s.damage), int(s.radius), s.cooldown]
		"blades":
			return "피해 %d · 칼날 %d개 · 참격 %d" % [int(s.damage), int(s.count), int(s.wave_damage)]
	return ""


static func passive_total(id: String, level: int) -> float:
	match id:
		"boots":
			return level * 0.08
		"core":
			return level * 0.12
		"coolant":
			return level * 0.07
		"heart":
			return level * 20.0
		"magnet":
			return level * 28.0
		"star":
			return level * 0.05
		"armor":
			return level * 1.0
		"nano":
			return level * 0.5
	return 0.0


static func passive_detail(id: String, level: int) -> String:
	var total := passive_total(id, level)
	match id:
		"boots":
			return "이동 속도 +%d%% (총 +%d%%)" % [8, int(total * 100)]
		"core":
			return "공격 피해 +%d%% (총 +%d%%)" % [12, int(total * 100)]
		"coolant":
			return "공격 대기시간 -%d%% (총 -%d%%)" % [7, int(total * 100)]
		"heart":
			return "최대 체력 +20 (총 +%d)" % int(total)
		"magnet":
			return "획득 범위 +28 (총 +%d)" % int(total)
		"star":
			return "치명타 +%d%% (총 +%d%%)" % [5, int(total * 100)]
		"armor":
			return "받는 피해 -1 (총 -%d)" % int(total)
		"nano":
			return "초당 회복 +0.5 (총 +%.1f)" % total
	return ""


static func xp_requirement(level: int) -> int:
	var lv := maxi(1, level)
	if lv <= 1:
		return 12
	# Levels 2+ scale much faster than the old linear 6 + level * 5 curve.
	return int(round(10.0 + float(lv) * 5.5 + pow(float(lv), 1.62) * 2.4))


static func format_time(seconds: float) -> String:
	var s := int(maxf(0.0, seconds))
	return "%02d:%02d" % [int(s / 60), s % 60]
