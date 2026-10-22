class_name GameData
extends RefCounted

## All balance data in one place. Pure static data, no nodes.

const ARENA_HALF := 1700.0
const DEFAULT_DURATION := 240.0
const STAGE_ORDER := ["forest", "hive", "ship", "crater", "void",
	"dunes", "frost", "mire", "ruins", "citadel", "trench", "sunspot", "maze", "orbit", "dawn"]

## Each new front has its own enemy roster; no existing enemy is re-used.
const NEW_STAGE_ENEMIES := {
	"dunes": ["dune_stalker", "sand_spitter"],
	"frost": ["frost_wisp", "ice_crab"],
	"mire": ["mire_lurker", "toxic_moth"],
	"ruins": ["rust_hound", "cog_sentry"],
	"citadel": ["moon_knight", "astral_seer"],
	"trench": ["abyss_jaw", "deep_larva"],
	"sunspot": ["solar_flare", "magma_wing"],
	"maze": ["maze_weaver", "prism_eye"],
	"orbit": ["orbit_drone", "void_cutter"],
	"dawn": ["dawn_herald", "light_eater"],
}

## Each new front also has its own destructible relics, so terrain never
## recycles the forest/hive/ship props from earlier fronts.
const NEW_STAGE_OBSTACLES := {
	"dunes": ["relic_dunes_a", "relic_dunes_b"],
	"frost": ["relic_frost_a", "relic_frost_b"],
	"mire": ["relic_mire_a", "relic_mire_b"],
	"ruins": ["relic_ruins_a", "relic_ruins_b"],
	"citadel": ["relic_citadel_a", "relic_citadel_b"],
	"trench": ["relic_trench_a", "relic_trench_b"],
	"sunspot": ["relic_sunspot_a", "relic_sunspot_b"],
	"maze": ["relic_maze_a", "relic_maze_b"],
	"orbit": ["relic_orbit_a", "relic_orbit_b"],
	"dawn": ["relic_dawn_a", "relic_dawn_b"],
}

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
	"thorn": {
		"name": "가시 덩굴",
		"hp": 46.0,
		"speed": 58.0,
		"damage": 8.0,
		"xp": 4,
		"radius": 12.0,
		"texture": "res://assets/art/char/enemy_burrower.png",
		"height": 38.0,
		"color": Color(0.48, 0.88, 0.48),
		"flying": false,
		"behavior": "brute",
	},
	"moth": {
		"name": "달나방",
		"hp": 16.0,
		"speed": 104.0,
		"damage": 5.0,
		"xp": 2,
		"radius": 9.0,
		"texture": "res://assets/art/char/enemy_bat_0.png",
		"height": 26.0,
		"color": Color(1.0, 0.78, 0.5),
		"flying": true,
		"scale": 0.86,
	},
	"larva": {
		"name": "군체 유충",
		"hp": 9.0,
		"speed": 98.0,
		"damage": 4.0,
		"xp": 1,
		"radius": 7.0,
		"texture": "res://assets/art/char/enemy_slime.png",
		"height": 19.0,
		"color": Color(0.9, 0.95, 0.45),
		"flying": false,
		"scale": 0.72,
	},
	"sporeling": {
		"name": "포자 사수",
		"hp": 27.0,
		"speed": 50.0,
		"damage": 6.0,
		"xp": 3,
		"radius": 10.0,
		"texture": "res://assets/art/char/enemy_ghost.png",
		"height": 29.0,
		"color": Color(0.65, 1.0, 0.55),
		"flying": true,
		"behavior": "spitter",
	},
	"crawler": {
		"name": "격벽 크롤러",
		"hp": 30.0,
		"speed": 90.0,
		"damage": 8.0,
		"xp": 3,
		"radius": 10.0,
		"texture": "res://assets/art/char/enemy_burrower.png",
		"height": 28.0,
		"color": Color(0.45, 0.88, 0.9),
		"flying": false,
		"scale": 0.9,
	},
	"nullifier": {
		"name": "공허 소거자",
		"hp": 34.0,
		"speed": 68.0,
		"damage": 9.0,
		"xp": 5,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 36.0,
		"color": Color(0.68, 0.45, 1.0),
		"flying": false,
		"behavior": "phase",
	},
	"magma": {
		"name": "마그마 포식자",
		"hp": 190.0,
		"speed": 34.0,
		"damage": 18.0,
		"xp": 18,
		"radius": 22.0,
		"texture": "res://assets/art/char/enemy_brute.png",
		"height": 58.0,
		"color": Color(1.0, 0.42, 0.18),
		"flying": false,
		"behavior": "brute",
	},
	"cinder": {
		"name": "잿불 사수",
		"hp": 34.0,
		"speed": 52.0,
		"damage": 8.0,
		"xp": 5,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_spitter.png",
		"height": 36.0,
		"color": Color(1.0, 0.55, 0.24),
		"flying": false,
		"behavior": "spitter",
	},
	"riftling": {
		"name": "균열 망령",
		"hp": 44.0,
		"speed": 78.0,
		"damage": 11.0,
		"xp": 6,
		"radius": 11.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 38.0,
		"color": Color(0.72, 0.38, 1.0),
		"flying": false,
		"behavior": "phase",
	},
	"void_moth": {
		"name": "심연 나방",
		"hp": 20.0,
		"speed": 112.0,
		"damage": 6.0,
		"xp": 3,
		"radius": 9.0,
		"texture": "res://assets/art/char/enemy_bat_0.png",
		"height": 26.0,
		"color": Color(0.75, 0.5, 1.0),
		"flying": true,
		"scale": 0.86,
	},
	"dune_stalker": {
		"name": "사막 추적자", "hp": 58.0, "speed": 62.0, "damage": 11.0, "xp": 18,
		"radius": 14.0, "texture": "res://assets/art/char/new_enemy_dune_stalker.png",
		"height": 38.0, "color": Color(0.82, 0.48, 0.24), "flying": false, "behavior": "brute",
	},
	"sand_spitter": {
		"name": "모래 사수", "hp": 42.0, "speed": 52.0, "damage": 9.0, "xp": 14,
		"radius": 11.0, "texture": "res://assets/art/char/new_enemy_sand_spitter.png",
		"height": 34.0, "color": Color(0.9, 0.68, 0.34), "flying": false, "behavior": "spitter",
	},
	"frost_wisp": {
		"name": "서리 정령", "hp": 44.0, "speed": 74.0, "damage": 9.0, "xp": 16,
		"radius": 10.0, "texture": "res://assets/art/char/new_enemy_frost_wisp.png",
		"height": 32.0, "color": Color(0.55, 0.84, 0.98), "flying": true,
	},
	"ice_crab": {
		"name": "빙갑 게", "hp": 68.0, "speed": 44.0, "damage": 12.0, "xp": 20,
		"radius": 16.0, "texture": "res://assets/art/char/new_enemy_ice_crab.png",
		"height": 32.0, "color": Color(0.48, 0.72, 0.9), "flying": false, "behavior": "brute",
	},
	"mire_lurker": {
		"name": "수렁 잠복자", "hp": 62.0, "speed": 58.0, "damage": 10.0, "xp": 19,
		"radius": 13.0, "texture": "res://assets/art/char/new_enemy_mire_lurker.png",
		"height": 36.0, "color": Color(0.48, 0.6, 0.28), "flying": false, "behavior": "burrower",
	},
	"toxic_moth": {
		"name": "독나방", "hp": 40.0, "speed": 108.0, "damage": 9.0, "xp": 14,
		"radius": 9.0, "texture": "res://assets/art/char/new_enemy_toxic_moth.png",
		"height": 28.0, "color": Color(0.62, 0.78, 0.3), "flying": true, "scale": 0.9,
	},
	"rust_hound": {
		"name": "녹슨 사냥개", "hp": 60.0, "speed": 86.0, "damage": 11.0, "xp": 22,
		"radius": 13.0, "texture": "res://assets/art/char/new_enemy_rust_hound.png",
		"height": 34.0, "color": Color(0.58, 0.42, 0.3), "flying": false, "behavior": "brute",
	},
	"cog_sentry": {
		"name": "톱니 파수꾼", "hp": 74.0, "speed": 38.0, "damage": 10.0, "xp": 24,
		"radius": 15.0, "texture": "res://assets/art/char/new_enemy_cog_sentry.png",
		"height": 36.0, "color": Color(0.56, 0.6, 0.64), "flying": false, "behavior": "sentinel",
	},
	"moon_knight": {
		"name": "월광 기사", "hp": 64.0, "speed": 60.0, "damage": 12.0, "xp": 26,
		"radius": 15.0, "texture": "res://assets/art/char/new_enemy_moon_knight.png",
		"height": 40.0, "color": Color(0.62, 0.56, 0.8), "flying": false, "behavior": "brute",
	},
	"astral_seer": {
		"name": "별안 현자", "hp": 48.0, "speed": 50.0, "damage": 11.0, "xp": 24,
		"radius": 12.0, "texture": "res://assets/art/char/new_enemy_astral_seer.png",
		"height": 34.0, "color": Color(0.48, 0.44, 0.76), "flying": true, "behavior": "spitter",
	},
	"abyss_jaw": {
		"name": "심연 아가리", "hp": 76.0, "speed": 52.0, "damage": 13.0, "xp": 28,
		"radius": 18.0, "texture": "res://assets/art/char/new_enemy_abyss_jaw.png",
		"height": 44.0, "color": Color(0.38, 0.28, 0.56), "flying": false, "behavior": "brute",
	},
	"deep_larva": {
		"name": "심층 유충", "hp": 44.0, "speed": 100.0, "damage": 10.0, "xp": 18,
		"radius": 9.0, "texture": "res://assets/art/char/new_enemy_deep_larva.png",
		"height": 28.0, "color": Color(0.42, 0.34, 0.56), "flying": false, "scale": 0.85,
	},
	"solar_flare": {
		"name": "태양불꽃", "hp": 54.0, "speed": 70.0, "damage": 12.0, "xp": 26,
		"radius": 12.0, "texture": "res://assets/art/char/new_enemy_solar_flare.png",
		"height": 36.0, "color": Color(0.92, 0.48, 0.18), "flying": true,
	},
	"magma_wing": {
		"name": "마그마 날개", "hp": 66.0, "speed": 92.0, "damage": 13.0, "xp": 28,
		"radius": 14.0, "texture": "res://assets/art/char/new_enemy_magma_wing.png",
		"height": 38.0, "color": Color(0.84, 0.3, 0.16), "flying": true,
	},
	"maze_weaver": {
		"name": "미궁 직조자", "hp": 78.0, "speed": 66.0, "damage": 14.0, "xp": 30,
		"radius": 16.0, "texture": "res://assets/art/char/new_enemy_maze_weaver.png",
		"height": 42.0, "color": Color(0.5, 0.42, 0.72), "flying": false, "behavior": "phase",
	},
	"prism_eye": {
		"name": "프리즘 눈", "hp": 56.0, "speed": 45.0, "damage": 12.0, "xp": 30,
		"radius": 15.0, "texture": "res://assets/art/char/new_enemy_prism_eye.png",
		"height": 38.0, "color": Color(0.38, 0.5, 0.72), "flying": true, "behavior": "sentinel",
	},
	"orbit_drone": {
		"name": "궤도 드론", "hp": 52.0, "speed": 100.0, "damage": 13.0, "xp": 28,
		"radius": 12.0, "texture": "res://assets/art/char/new_enemy_orbit_drone.png",
		"height": 34.0, "color": Color(0.36, 0.62, 0.7), "flying": true,
	},
	"void_cutter": {
		"name": "공허 절단자", "hp": 82.0, "speed": 74.0, "damage": 15.0, "xp": 34,
		"radius": 14.0, "texture": "res://assets/art/char/new_enemy_void_cutter.png",
		"height": 40.0, "color": Color(0.4, 0.28, 0.62), "flying": false, "behavior": "phase",
	},
	"dawn_herald": {
		"name": "새벽 전령", "hp": 88.0, "speed": 58.0, "damage": 15.0, "xp": 38,
		"radius": 18.0, "texture": "res://assets/art/char/new_enemy_dawn_herald.png",
		"height": 46.0, "color": Color(0.84, 0.68, 0.36), "flying": false, "behavior": "brute",
	},
	"light_eater": {
		"name": "빛 포식자", "hp": 72.0, "speed": 80.0, "damage": 14.0, "xp": 38,
		"radius": 16.0, "texture": "res://assets/art/char/new_enemy_light_eater.png",
		"height": 42.0, "color": Color(0.74, 0.52, 0.26), "flying": true, "behavior": "sentinel",
	},
	"elder_treant": {
		"name": "고목 수호자",
		"hp": 520.0,
		"speed": 28.0,
		"damage": 14.0,
		"xp": 30,
		"radius": 36.0,
		"texture": "res://assets/art/char/enemy_brute.png",
		"height": 82.0,
		"color": Color(0.45, 0.8, 0.42),
		"flying": false,
		"mini_boss": true,
		"mini_style": "slam",
		"scale": 1.35,
	},
	"moon_stalker": {
		"name": "월식 추적자",
		"hp": 460.0,
		"speed": 62.0,
		"damage": 13.0,
		"xp": 28,
		"radius": 26.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 64.0,
		"color": Color(0.7, 0.48, 1.0),
		"flying": false,
		"mini_boss": true,
		"mini_style": "charger",
		"scale": 1.2,
	},
	"spore_mother": {
		"name": "포자 모체",
		"hp": 560.0,
		"speed": 28.0,
		"damage": 15.0,
		"xp": 32,
		"radius": 36.0,
		"texture": "res://assets/art/char/enemy_queen.png",
		"height": 84.0,
		"color": Color(0.62, 1.0, 0.5),
		"flying": false,
		"mini_boss": true,
		"mini_style": "summon",
		"scale": 0.62,
	},
	"hive_tyrant": {
		"name": "군체 폭군",
		"hp": 700.0,
		"speed": 34.0,
		"damage": 17.0,
		"xp": 36,
		"radius": 40.0,
		"texture": "res://assets/art/char/enemy_brute.png",
		"height": 90.0,
		"color": Color(0.8, 0.4, 0.62),
		"flying": false,
		"mini_boss": true,
		"mini_style": "slam",
		"scale": 1.5,
	},
	"bulwark": {
		"name": "격벽 파괴자",
		"hp": 620.0,
		"speed": 26.0,
		"damage": 15.0,
		"xp": 34,
		"radius": 38.0,
		"texture": "res://assets/art/char/enemy_sentinel.png",
		"height": 80.0,
		"color": Color(0.35, 0.9, 0.9),
		"flying": true,
		"mini_boss": true,
		"mini_style": "beam",
		"scale": 1.35,
	},
	"void_reaver": {
		"name": "공허 사냥꾼",
		"hp": 580.0,
		"speed": 46.0,
		"damage": 16.0,
		"xp": 34,
		"radius": 30.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 70.0,
		"color": Color(0.72, 0.4, 1.0),
		"flying": true,
		"mini_boss": true,
		"mini_style": "caster",
		"scale": 1.25,
	},
	"magma_titan": {
		"name": "용암 거인",
		"hp": 760.0,
		"speed": 30.0,
		"damage": 18.0,
		"xp": 38,
		"radius": 42.0,
		"texture": "res://assets/art/char/enemy_brute.png",
		"height": 94.0,
		"color": Color(1.0, 0.35, 0.14),
		"flying": false,
		"mini_boss": true,
		"mini_style": "slam",
		"scale": 1.55,
	},
	"ash_witch": {
		"name": "잿빛 마녀",
		"hp": 640.0,
		"speed": 34.0,
		"damage": 16.0,
		"xp": 36,
		"radius": 32.0,
		"texture": "res://assets/art/char/enemy_queen.png",
		"height": 76.0,
		"color": Color(1.0, 0.52, 0.28),
		"flying": true,
		"mini_boss": true,
		"mini_style": "caster",
		"scale": 0.58,
	},
	"rift_hunter": {
		"name": "균열 추적자",
		"hp": 690.0,
		"speed": 70.0,
		"damage": 19.0,
		"xp": 38,
		"radius": 30.0,
		"texture": "res://assets/art/char/enemy_phase.png",
		"height": 70.0,
		"color": Color(0.7, 0.35, 1.0),
		"flying": true,
		"mini_boss": true,
		"mini_style": "charger",
		"scale": 1.25,
	},
	"star_eater": {
		"name": "별을 삼키는 자",
		"hp": 860.0,
		"speed": 30.0,
		"damage": 21.0,
		"xp": 42,
		"radius": 40.0,
		"texture": "res://assets/art/char/enemy_boss.png",
		"height": 88.0,
		"color": Color(0.55, 0.25, 0.95),
		"flying": true,
		"mini_boss": true,
		"mini_style": "summon",
		"scale": 0.62,
	},
	"dune_queen": {
		"name": "사막 여왕", "hp": 1000.0, "speed": 34.0, "damage": 24.0, "xp": 45,
		"radius": 42.0, "texture": "res://assets/art/char/new_mini_dune_queen.png",
		"height": 90.0, "color": Color(0.8, 0.45, 0.2), "flying": false,
		"mini_boss": true, "mini_style": "slam", "scale": 1.35,
	},
	"frost_colossus": {
		"name": "서리 거상", "hp": 1150.0, "speed": 28.0, "damage": 25.0, "xp": 48,
		"radius": 46.0, "texture": "res://assets/art/char/new_mini_frost_colossus.png",
		"height": 96.0, "color": Color(0.42, 0.7, 0.92), "flying": false,
		"mini_boss": true, "mini_style": "slam", "scale": 1.45,
	},
	"mire_mother": {
		"name": "수렁 모체", "hp": 1250.0, "speed": 30.0, "damage": 26.0, "xp": 50,
		"radius": 44.0, "texture": "res://assets/art/char/new_mini_mire_mother.png",
		"height": 92.0, "color": Color(0.4, 0.62, 0.26), "flying": false,
		"mini_boss": true, "mini_style": "summon", "scale": 1.35,
	},
	"iron_executor": {
		"name": "강철 집행자", "hp": 1400.0, "speed": 36.0, "damage": 28.0, "xp": 54,
		"radius": 44.0, "texture": "res://assets/art/char/new_mini_iron_executor.png",
		"height": 94.0, "color": Color(0.5, 0.54, 0.6), "flying": false,
		"mini_boss": true, "mini_style": "beam", "scale": 1.4,
	},
	"citadel_guardian": {
		"name": "성채 파수병", "hp": 1550.0, "speed": 32.0, "damage": 30.0, "xp": 58,
		"radius": 48.0, "texture": "res://assets/art/char/new_mini_citadel_guardian.png",
		"height": 100.0, "color": Color(0.55, 0.44, 0.76), "flying": false,
		"mini_boss": true, "mini_style": "caster", "scale": 1.5,
	},
	"trench_devourer": {
		"name": "해구 포식자", "hp": 1700.0, "speed": 38.0, "damage": 32.0, "xp": 62,
		"radius": 48.0, "texture": "res://assets/art/char/new_mini_trench_devourer.png",
		"height": 102.0, "color": Color(0.32, 0.24, 0.48), "flying": false,
		"mini_boss": true, "mini_style": "charger", "scale": 1.5,
	},
	"solar_tyrant": {
		"name": "흑점 폭군", "hp": 1850.0, "speed": 40.0, "damage": 34.0, "xp": 66,
		"radius": 50.0, "texture": "res://assets/art/char/new_mini_solar_tyrant.png",
		"height": 104.0, "color": Color(0.86, 0.4, 0.14), "flying": false,
		"mini_boss": true, "mini_style": "slam", "scale": 1.55,
	},
	"maze_oracle": {
		"name": "미궁 예언자", "hp": 2000.0, "speed": 34.0, "damage": 36.0, "xp": 70,
		"radius": 46.0, "texture": "res://assets/art/char/new_mini_maze_oracle.png",
		"height": 100.0, "color": Color(0.44, 0.36, 0.72), "flying": false,
		"mini_boss": true, "mini_style": "caster", "scale": 1.45,
	},
	"orbit_breaker": {
		"name": "궤도 파괴자", "hp": 2200.0, "speed": 30.0, "damage": 38.0, "xp": 74,
		"radius": 50.0, "texture": "res://assets/art/char/new_mini_orbit_breaker.png",
		"height": 108.0, "color": Color(0.3, 0.58, 0.66), "flying": false,
		"mini_boss": true, "mini_style": "beam", "scale": 1.55,
	},
	"dawn_seraph": {
		"name": "새벽 세라핌", "hp": 2500.0, "speed": 42.0, "damage": 42.0, "xp": 80,
		"radius": 52.0, "texture": "res://assets/art/char/new_mini_dawn_seraph.png",
		"height": 112.0, "color": Color(0.84, 0.66, 0.32), "flying": false,
		"mini_boss": true, "mini_style": "summon", "scale": 1.6,
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
	"boss_leviathan": {
		"name": "재의 레비아탄",
		"hp": 3400.0,
		"speed": 25.0,
		"damage": 25.0,
		"xp": 110,
		"radius": 64.0,
		"texture": "res://assets/art/char/enemy_boss.png",
		"height": 120.0,
		"color": Color(1.0, 0.38, 0.18),
		"flying": true,
		"boss": true,
		"style": "ship",
		"scale": 1.08,
	},
	"boss_eclipse": {
		"name": "월식의 군주",
		"hp": 4400.0,
		"speed": 28.0,
		"damage": 30.0,
		"xp": 135,
		"radius": 70.0,
		"texture": "res://assets/art/char/enemy_boss.png",
		"height": 126.0,
		"color": Color(0.58, 0.24, 1.0),
		"flying": true,
		"boss": true,
		"style": "ship",
		"scale": 1.18,
	},
	"boss_dune": {
		"name": "사막의 스콜피온", "hp": 4800.0, "speed": 30.0, "damage": 28.0, "xp": 130,
		"radius": 64.0, "texture": "res://assets/art/char/new_boss_dune.png", "height": 124.0,
		"color": Color(0.84, 0.36, 0.16), "flying": true, "boss": true, "style": "queen", "scale": 1.10,
	},
	"boss_frost": {
		"name": "서리 거인", "hp": 5400.0, "speed": 28.0, "damage": 30.0, "xp": 140,
		"radius": 68.0, "texture": "res://assets/art/char/new_boss_frost.png", "height": 128.0,
		"color": Color(0.4, 0.68, 0.9), "flying": true, "boss": true, "style": "ship", "scale": 1.15,
	},
	"boss_mire": {
		"name": "독니 여왕", "hp": 6100.0, "speed": 30.0, "damage": 32.0, "xp": 150,
		"radius": 68.0, "texture": "res://assets/art/char/new_boss_mire.png", "height": 130.0,
		"color": Color(0.38, 0.6, 0.24), "flying": true, "boss": true, "style": "queen", "scale": 1.15,
	},
	"boss_ruins": {
		"name": "폐허의 강철신", "hp": 6900.0, "speed": 32.0, "damage": 34.0, "xp": 160,
		"radius": 70.0, "texture": "res://assets/art/char/new_boss_ruins.png", "height": 132.0,
		"color": Color(0.46, 0.5, 0.56), "flying": true, "boss": true, "style": "ship", "scale": 1.20,
	},
	"boss_citadel": {
		"name": "달빛 성채의 군주", "hp": 7800.0, "speed": 30.0, "damage": 36.0, "xp": 170,
		"radius": 72.0, "texture": "res://assets/art/char/new_boss_citadel.png", "height": 136.0,
		"color": Color(0.5, 0.4, 0.74), "flying": true, "boss": true, "style": "queen", "scale": 1.25,
	},
	"boss_trench": {
		"name": "심연 포식자", "hp": 8800.0, "speed": 34.0, "damage": 38.0, "xp": 180,
		"radius": 74.0, "texture": "res://assets/art/char/new_boss_trench.png", "height": 138.0,
		"color": Color(0.28, 0.2, 0.42), "flying": true, "boss": true, "style": "ship", "scale": 1.30,
	},
	"boss_solar": {
		"name": "흑점의 군주", "hp": 9900.0, "speed": 32.0, "damage": 41.0, "xp": 195,
		"radius": 76.0, "texture": "res://assets/art/char/new_boss_solar.png", "height": 140.0,
		"color": Color(0.9, 0.32, 0.1), "flying": true, "boss": true, "style": "queen", "scale": 1.35,
	},
	"boss_maze": {
		"name": "미궁의 현자", "hp": 11200.0, "speed": 36.0, "damage": 44.0, "xp": 210,
		"radius": 78.0, "texture": "res://assets/art/char/new_boss_maze.png", "height": 142.0,
		"color": Color(0.42, 0.3, 0.68), "flying": true, "boss": true, "style": "ship", "scale": 1.40,
	},
	"boss_orbit": {
		"name": "종말의 궤도신", "hp": 12600.0, "speed": 38.0, "damage": 47.0, "xp": 225,
		"radius": 80.0, "texture": "res://assets/art/char/new_boss_orbit.png", "height": 146.0,
		"color": Color(0.26, 0.54, 0.62), "flying": true, "boss": true, "style": "queen", "scale": 1.45,
	},
	"boss_dawn": {
		"name": "새벽을 삼킨 자", "hp": 14500.0, "speed": 40.0, "damage": 52.0, "xp": 250,
		"radius": 84.0, "texture": "res://assets/art/char/new_boss_dawn.png", "height": 150.0,
		"color": Color(0.86, 0.66, 0.28), "flying": true, "boss": true, "style": "ship", "scale": 1.55,
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

## Destructible terrain placed on each battlefield. `burst` is the shatter
## effect family; `drop` is the XP reward for breaking it.
const DESTRUCTIBLES := {
	"forest_tree": {
		"texture": "res://assets/art/world/tree_broad.png", "radius": 30.0,
		"hp": 230.0, "color": Color(0.55, 0.85, 0.55), "drop": 3, "burst": "",
	},
	"forest_rock": {
		"texture": "res://assets/art/world/rock_1.png", "radius": 24.0,
		"hp": 165.0, "color": Color(0.7, 0.72, 0.68), "drop": 2, "burst": "",
	},
	"forest_crystal": {
		"texture": "res://assets/art/world/alien_crystal.png", "radius": 18.0,
		"hp": 90.0, "color": Color(0.4, 0.95, 1.0), "drop": 2, "burst": "shard",
	},
	"hive_egg": {
		"texture": "res://assets/art/world/hive_egg.png", "radius": 22.0,
		"hp": 115.0, "color": Color(0.55, 1.0, 0.55), "drop": 2, "burst": "acid",
	},
	"hive_pod": {
		"texture": "res://assets/art/world/hive_pod.png", "radius": 26.0,
		"hp": 165.0, "color": Color(0.72, 0.45, 1.0), "drop": 3, "burst": "acid",
	},
	"hive_coral": {
		"texture": "res://assets/art/world/hive_coral.png", "radius": 28.0,
		"hp": 235.0, "color": Color(0.82, 0.48, 1.0), "drop": 3, "burst": "",
	},
	"ship_pod": {
		"texture": "res://assets/art/world/ship_pod.png", "radius": 24.0,
		"hp": 180.0, "color": Color(0.35, 0.92, 0.95), "drop": 3, "burst": "shock",
	},
	"ship_console": {
		"texture": "res://assets/art/world/ship_console.png", "radius": 22.0,
		"hp": 135.0, "color": Color(0.4, 0.88, 1.0), "drop": 2, "burst": "shock",
	},
	"ship_wall": {
		"texture": "res://assets/art/world/ship_wall.png", "radius": 34.0,
		"hp": 330.0, "color": Color(0.55, 0.78, 0.82), "drop": 4, "burst": "",
	},
	"relic_dunes_a": {
		"texture": "res://assets/art/world/relic_dunes_a.png", "radius": 28.0,
		"hp": 210.0, "color": Color(0.86, 0.5, 0.24), "drop": 3, "burst": "",
	},
	"relic_dunes_b": {
		"texture": "res://assets/art/world/relic_dunes_b.png", "radius": 24.0,
		"hp": 170.0, "color": Color(0.92, 0.62, 0.3), "drop": 2, "burst": "shard",
	},
	"relic_frost_a": {
		"texture": "res://assets/art/world/relic_frost_a.png", "radius": 30.0,
		"hp": 240.0, "color": Color(0.55, 0.82, 0.96), "drop": 3, "burst": "shard",
	},
	"relic_frost_b": {
		"texture": "res://assets/art/world/relic_frost_b.png", "radius": 26.0,
		"hp": 190.0, "color": Color(0.65, 0.9, 1.0), "drop": 2, "burst": "shard",
	},
	"relic_mire_a": {
		"texture": "res://assets/art/world/relic_mire_a.png", "radius": 26.0,
		"hp": 230.0, "color": Color(0.52, 0.76, 0.3), "drop": 3, "burst": "acid",
	},
	"relic_mire_b": {
		"texture": "res://assets/art/world/relic_mire_b.png", "radius": 30.0,
		"hp": 260.0, "color": Color(0.64, 0.86, 0.36), "drop": 3, "burst": "acid",
	},
	"relic_ruins_a": {
		"texture": "res://assets/art/world/relic_ruins_a.png", "radius": 30.0,
		"hp": 300.0, "color": Color(0.62, 0.64, 0.66), "drop": 4, "burst": "shock",
	},
	"relic_ruins_b": {
		"texture": "res://assets/art/world/relic_ruins_b.png", "radius": 26.0,
		"hp": 240.0, "color": Color(0.76, 0.66, 0.4), "drop": 3, "burst": "shock",
	},
	"relic_citadel_a": {
		"texture": "res://assets/art/world/relic_citadel_a.png", "radius": 30.0,
		"hp": 330.0, "color": Color(0.62, 0.5, 0.86), "drop": 4, "burst": "shard",
	},
	"relic_citadel_b": {
		"texture": "res://assets/art/world/relic_citadel_b.png", "radius": 26.0,
		"hp": 270.0, "color": Color(0.72, 0.58, 0.96), "drop": 3, "burst": "shard",
	},
	"relic_trench_a": {
		"texture": "res://assets/art/world/relic_trench_a.png", "radius": 32.0,
		"hp": 360.0, "color": Color(0.4, 0.28, 0.58), "drop": 4, "burst": "acid",
	},
	"relic_trench_b": {
		"texture": "res://assets/art/world/relic_trench_b.png", "radius": 28.0,
		"hp": 300.0, "color": Color(0.56, 0.34, 0.72), "drop": 3, "burst": "acid",
	},
	"relic_sunspot_a": {
		"texture": "res://assets/art/world/relic_sunspot_a.png", "radius": 30.0,
		"hp": 390.0, "color": Color(0.96, 0.42, 0.14), "drop": 4, "burst": "shard",
	},
	"relic_sunspot_b": {
		"texture": "res://assets/art/world/relic_sunspot_b.png", "radius": 26.0,
		"hp": 320.0, "color": Color(1.0, 0.6, 0.2), "drop": 3, "burst": "shard",
	},
	"relic_maze_a": {
		"texture": "res://assets/art/world/relic_maze_a.png", "radius": 30.0,
		"hp": 420.0, "color": Color(0.5, 0.38, 0.78), "drop": 4, "burst": "shard",
	},
	"relic_maze_b": {
		"texture": "res://assets/art/world/relic_maze_b.png", "radius": 26.0,
		"hp": 350.0, "color": Color(0.64, 0.48, 0.9), "drop": 3, "burst": "shard",
	},
	"relic_orbit_a": {
		"texture": "res://assets/art/world/relic_orbit_a.png", "radius": 32.0,
		"hp": 460.0, "color": Color(0.38, 0.7, 0.76), "drop": 4, "burst": "shock",
	},
	"relic_orbit_b": {
		"texture": "res://assets/art/world/relic_orbit_b.png", "radius": 28.0,
		"hp": 380.0, "color": Color(0.5, 0.86, 0.88), "drop": 3, "burst": "shock",
	},
	"relic_dawn_a": {
		"texture": "res://assets/art/world/relic_dawn_a.png", "radius": 34.0,
		"hp": 520.0, "color": Color(0.92, 0.72, 0.34), "drop": 5, "burst": "shard",
	},
	"relic_dawn_b": {
		"texture": "res://assets/art/world/relic_dawn_b.png", "radius": 30.0,
		"hp": 430.0, "color": Color(1.0, 0.84, 0.48), "drop": 4, "burst": "shard",
	},
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
		"theme": "forest",
		"subtitle": "외계 함대 침공",
		"desc": "달빛 숲. 첫 번째 함대를 막아라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_scout",
		"enemies": ["blob", "drone", "jelly", "grey", "mech", "moth", "thorn"],
		"enemy_icons": ["moth", "blob", "thorn"],
		"minibosses": [[70.0, "elder_treant"], [135.0, "moon_stalker"]],
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
		"theme": "hive",
		"subtitle": "포자가 바람에 흩날린다",
		"desc": "군체 분화구. 여왕을 깨우지 마라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_queen",
		"enemies": ["spitter", "bomber", "burrower", "brute", "blob", "larva", "sporeling"],
		"enemy_icons": ["larva", "sporeling", "spitter"],
		"minibosses": [[70.0, "spore_mother"], [135.0, "hive_tyrant"]],
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
		"theme": "ship",
		"subtitle": "달을 삼킨 자의 배",
		"desc": "모선 심장부. 격벽을 돌파하라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_final",
		"enemies": ["sentinel", "phase", "splitter", "mech", "drone", "crawler", "nullifier"],
		"enemy_icons": ["crawler", "nullifier", "phase"],
		"minibosses": [[70.0, "bulwark"], [135.0, "void_reaver"]],
		"hp_scale": 1.32,
		"music_pitch": 1.08,
		"tint": Color(0.84, 0.97, 1.04),
		"accent": Color(0.42, 0.9, 0.86),
		"thumb": "res://assets/art/ui/stage_ship.png",
		"goal": "탈출까지",
		"warnings": [[50.0, "격벽이 닫힌다"], [118.0, "경비 병력이 깨어난다"]],
	},
	"crater": {
		"num": 4,
		"name": "제4전선",
		"short": "잿빛 균열",
		"theme": "crater",
		"subtitle": "재와 용암이 흐른다",
		"desc": "잿빛 균열. 재의 레비아탄을 막아라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_leviathan",
		"enemies": ["magma", "cinder", "spitter", "brute", "bomber", "sporeling"],
		"enemy_icons": ["magma", "cinder", "brute"],
		"minibosses": [[70.0, "magma_titan"], [135.0, "ash_witch"]],
		"hp_scale": 1.55,
		"damage_scale": 1.20,
		"spawn_scale": 0.94,
		"music_pitch": 0.82,
		"tint": Color(1.12, 0.78, 0.70),
		"accent": Color(1.0, 0.46, 0.24),
		"thumb": "res://assets/art/ui/stage_crater.png",
		"goal": "균열 봉쇄까지",
		"warnings": [[50.0, "용암이 솟구친다"], [118.0, "재의 군단이 깨어난다"]],
	},
	"void": {
		"num": 5,
		"name": "제5전선",
		"short": "달의 뒷면",
		"theme": "void",
		"subtitle": "빛이 닿지 않는 곳",
		"desc": "달의 뒷면. 월식의 군주를 쓰러뜨려라.",
		"duration": 240.0,
		"boss_time": 170.0,
		"boss": "boss_eclipse",
		"enemies": ["riftling", "void_moth", "phase", "nullifier", "sentinel", "splitter"],
		"enemy_icons": ["riftling", "void_moth", "phase"],
		"minibosses": [[70.0, "rift_hunter"], [135.0, "star_eater"]],
		"hp_scale": 1.90,
		"damage_scale": 1.45,
		"spawn_scale": 0.84,
		"music_pitch": 1.18,
		"tint": Color(0.78, 0.72, 1.12),
		"accent": Color(0.62, 0.42, 1.0),
		"thumb": "res://assets/art/ui/stage_void.png",
		"goal": "월식 종결까지",
		"warnings": [[50.0, "달빛이 꺼진다"], [118.0, "공허가 열린다"]],
	},
	"dunes": {
		"num": 6, "name": "제6전선", "short": "붉은 사막", "theme": "crater",
		"subtitle": "모래 아래에서 발톱이 움직인다", "desc": "붉은 사막. 사막의 스콜피온을 처치하라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_dune",
		"enemies": ["dune_stalker", "sand_spitter"],
		"enemy_icons": ["dune_stalker", "sand_spitter"],
		"minibosses": [[105.0, "dune_queen"]],
		"hp_scale": 2.05, "damage_scale": 1.50, "spawn_scale": 0.82, "music_pitch": 0.78,
		"tint": Color(1.16, 0.72, 0.58), "accent": Color(1.0, 0.38, 0.18),
		"thumb": "res://assets/art/ui/stage_dunes.png",
		"ground": "res://assets/art/world/ground_dunes.png",
		"goal": "사막 봉쇄까지",
		"warnings": [[50.0, "모래 폭풍이 몰아친다"], [118.0, "발톱 군단이 솟아난다"]],
	},
	"frost": {
		"num": 7, "name": "제7전선", "short": "얼어붙은 호수", "theme": "void",
		"subtitle": "얼음 아래에서 빛이 숨 쉰다", "desc": "얼어붙은 호수. 서리 거인을 쓰러뜨려라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_frost",
		"enemies": ["frost_wisp", "ice_crab"],
		"enemy_icons": ["frost_wisp", "ice_crab"],
		"minibosses": [[105.0, "frost_colossus"]],
		"hp_scale": 2.22, "damage_scale": 1.56, "spawn_scale": 0.80, "music_pitch": 1.22,
		"tint": Color(0.72, 0.86, 1.18), "accent": Color(0.45, 0.82, 1.0),
		"thumb": "res://assets/art/ui/stage_frost.png",
		"ground": "res://assets/art/world/ground_frost.png",
		"goal": "호수 동결까지",
		"warnings": [[50.0, "호수가 얼어붙는다"], [118.0, "서리 거인이 깨어난다"]],
	},
	"mire": {
		"num": 8, "name": "제8전선", "short": "독성 수렁", "theme": "hive",
		"subtitle": "숨 쉬는 것도 독이 된다", "desc": "독성 수렁. 독니 여왕을 처치하라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_mire",
		"enemies": ["mire_lurker", "toxic_moth"],
		"enemy_icons": ["mire_lurker", "toxic_moth"],
		"minibosses": [[105.0, "mire_mother"]],
		"hp_scale": 2.42, "damage_scale": 1.62, "spawn_scale": 0.78, "music_pitch": 0.86,
		"tint": Color(0.92, 1.12, 0.62), "accent": Color(0.58, 0.94, 0.38),
		"thumb": "res://assets/art/ui/stage_mire.png",
		"ground": "res://assets/art/world/ground_mire.png",
		"goal": "독원 정화까지",
		"warnings": [[50.0, "독안개가 번진다"], [118.0, "둥지가 부풀어 오른다"]],
	},
	"ruins": {
		"num": 9, "name": "제9전선", "short": "강철 폐허", "theme": "ship",
		"subtitle": "무너진 기계가 다시 걷는다", "desc": "강철 폐허. 폐허의 강철신을 파괴하라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_ruins",
		"enemies": ["rust_hound", "cog_sentry"],
		"enemy_icons": ["rust_hound", "cog_sentry"],
		"minibosses": [[105.0, "iron_executor"]],
		"hp_scale": 2.64, "damage_scale": 1.69, "spawn_scale": 0.76, "music_pitch": 1.04,
		"tint": Color(0.72, 0.88, 0.98), "accent": Color(0.52, 0.78, 0.9),
		"thumb": "res://assets/art/ui/stage_ruins.png",
		"ground": "res://assets/art/world/ground_ruins.png",
		"goal": "폐허 정리까지",
		"warnings": [[50.0, "기계 군단이 기동한다"], [118.0, "집행자가 내려온다"]],
	},
	"citadel": {
		"num": 10, "name": "제10전선", "short": "달빛 성채", "theme": "void",
		"subtitle": "달의 성벽이 하늘을 가른다", "desc": "달빛 성채. 달빛 성채의 군주를 넘어라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_citadel",
		"enemies": ["moon_knight", "astral_seer"],
		"enemy_icons": ["moon_knight", "astral_seer"],
		"minibosses": [[105.0, "citadel_guardian"]],
		"hp_scale": 2.88, "damage_scale": 1.76, "spawn_scale": 0.74, "music_pitch": 1.16,
		"tint": Color(0.84, 0.70, 1.16), "accent": Color(0.72, 0.48, 1.0),
		"thumb": "res://assets/art/ui/stage_citadel.png",
		"ground": "res://assets/art/world/ground_citadel.png",
		"goal": "성채 함락까지",
		"warnings": [[50.0, "성벽이 닫힌다"], [118.0, "수호자가 왕좌에서 내려온다"]],
	},
	"trench": {
		"num": 11, "name": "제11전선", "short": "심연 해구", "theme": "hive",
		"subtitle": "아래로 갈수록 빛이 죽는다", "desc": "심연 해구. 심연 포식자를 사냥하라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_trench",
		"enemies": ["abyss_jaw", "deep_larva"],
		"enemy_icons": ["abyss_jaw", "deep_larva"],
		"minibosses": [[105.0, "trench_devourer"]],
		"hp_scale": 3.14, "damage_scale": 1.84, "spawn_scale": 0.72, "music_pitch": 0.74,
		"tint": Color(0.66, 0.50, 0.88), "accent": Color(0.56, 0.32, 0.92),
		"thumb": "res://assets/art/ui/stage_trench.png",
		"ground": "res://assets/art/world/ground_trench.png",
		"goal": "해구 봉인까지",
		"warnings": [[50.0, "해구가 갈라진다"], [118.0, "심연 포식자가 솟아오른다"]],
	},
	"sunspot": {
		"num": 12, "name": "제12전선", "short": "태양 흑점", "theme": "crater",
		"subtitle": "타오르는 흑점이 궤도를 삼킨다", "desc": "태양 흑점. 흑점의 군주를 격추하라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_solar",
		"enemies": ["solar_flare", "magma_wing"],
		"enemy_icons": ["solar_flare", "magma_wing"],
		"minibosses": [[105.0, "solar_tyrant"]],
		"hp_scale": 3.42, "damage_scale": 1.92, "spawn_scale": 0.70, "music_pitch": 0.88,
		"tint": Color(1.20, 0.66, 0.40), "accent": Color(1.0, 0.56, 0.16),
		"thumb": "res://assets/art/ui/stage_sunspot.png",
		"ground": "res://assets/art/world/ground_sunspot.png",
		"goal": "흑점 소멸까지",
		"warnings": [[50.0, "태양풍이 몰아친다"], [118.0, "흑점의 군주가 강림한다"]],
	},
	"maze": {
		"num": 13, "name": "제13전선", "short": "성운 미궁", "theme": "void",
		"subtitle": "별빛이 길을 속이고 다시 접힌다", "desc": "성운 미궁. 미궁의 현자를 찾아내라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_maze",
		"enemies": ["maze_weaver", "prism_eye"],
		"enemy_icons": ["maze_weaver", "prism_eye"],
		"minibosses": [[105.0, "maze_oracle"]],
		"hp_scale": 3.72, "damage_scale": 2.00, "spawn_scale": 0.68, "music_pitch": 1.24,
		"tint": Color(0.68, 0.62, 1.20), "accent": Color(0.56, 0.42, 1.0),
		"thumb": "res://assets/art/ui/stage_maze.png",
		"ground": "res://assets/art/world/ground_maze.png",
		"goal": "미궁 탈출까지",
		"warnings": [[50.0, "별길이 접힌다"], [118.0, "현자가 모습을 드러낸다"]],
	},
	"orbit": {
		"num": 14, "name": "제14전선", "short": "종말 궤도", "theme": "ship",
		"subtitle": "마지막 궤도가 불타고 있다", "desc": "종말 궤도. 종말의 궤도신을 막아라.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_orbit",
		"enemies": ["orbit_drone", "void_cutter"],
		"enemy_icons": ["orbit_drone", "void_cutter"],
		"minibosses": [[105.0, "orbit_breaker"]],
		"hp_scale": 4.04, "damage_scale": 2.08, "spawn_scale": 0.66, "music_pitch": 1.12,
		"tint": Color(0.76, 0.92, 1.10), "accent": Color(0.42, 0.94, 0.94),
		"thumb": "res://assets/art/ui/stage_orbit.png",
		"ground": "res://assets/art/world/ground_orbit.png",
		"goal": "궤도 사수까지",
		"warnings": [[50.0, "궤도가 무너진다"], [118.0, "파괴자가 전면에 선다"]],
	},
	"dawn": {
		"num": 15, "name": "제15전선", "short": "새벽의 문", "theme": "void",
		"subtitle": "모든 밤이 끝나는 문 앞", "desc": "새벽의 문. 새벽을 삼킨 자와 최후의 결전.",
		"duration": 240.0, "boss_time": 170.0, "boss": "boss_dawn",
		"enemies": ["dawn_herald", "light_eater"],
		"enemy_icons": ["dawn_herald", "light_eater"],
		"minibosses": [[105.0, "dawn_seraph"]],
		"hp_scale": 4.40, "damage_scale": 2.18, "spawn_scale": 0.64, "music_pitch": 1.30,
		"tint": Color(1.10, 0.86, 0.54), "accent": Color(1.0, 0.78, 0.34),
		"thumb": "res://assets/art/ui/stage_dawn.png",
		"ground": "res://assets/art/world/ground_dawn.png",
		"goal": "새벽을 맞이하라",
		"warnings": [[50.0, "새벽의 문이 열린다"], [118.0, "모든 밤이 한곳으로 모인다"]],
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
	return (1.0 + p * 0.6) * float(d["damage"]) * float(st.get("damage_scale", 1.0))


static func spawn_interval(stage_id: String, t: float, diff_id: String) -> float:
	var st := stage(stage_id)
	var d := difficulty(diff_id)
	var p := clampf(t / float(st["duration"]), 0.0, 1.0)
	# 1.5x the original spawn cadence while keeping difficulty multipliers.
	return lerpf(1.05, 0.34, p) * float(d["spawn"]) / 1.5 * float(st.get("spawn_scale", 1.0))


static func spawn_batch(t: float, duration: float = 240.0) -> int:
	var p := clampf(t / maxf(1.0, duration), 0.0, 1.0)
	return 1 + int(p * 2.2) + (1 if p > 0.72 else 0)


static func stage_spawn_weights(stage_id: String, t: float) -> Dictionary:
	if NEW_STAGE_ENEMIES.has(stage_id):
		var pair: Array = NEW_STAGE_ENEMIES[stage_id]
		var w := {String(pair[0]): 4.0, String(pair[1]): 3.0}
		if t > 70.0:
			w[String(pair[1])] = 4.5
		if t > 140.0:
			w[String(pair[0])] = 5.0
		return w
	match stage_id:
		"hive":
			var w := {"spitter": 4.2, "blob": maxf(2.0, 8.0 - t / 50.0), "larva": 3.0}
			if t > 35.0:
				w["sporeling"] = 2.4
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
			var w := {"drone": 4.0, "grey": 3.0, "crawler": 3.0}
			if t > 55.0:
				w["nullifier"] = 2.2
			if t > 25.0:
				w["splitter"] = 3.2
			if t > 55.0:
				w["sentinel"] = 2.5
			if t > 85.0:
				w["phase"] = 2.8
			if t > 125.0:
				w["mech"] = 1.6
			return w
		"crater":
			var w := {"magma": 3.0, "cinder": 3.5, "spitter": 2.5, "blob": 3.0}
			if t > 35.0:
				w["bomber"] = 3.0
			if t > 70.0:
				w["brute"] = 2.2
			if t > 105.0:
				w["sporeling"] = 2.6
			if t > 140.0:
				w["mech"] = 1.6
			return w
		"void":
			var w := {"riftling": 3.4, "void_moth": 2.8, "phase": 2.6, "drone": 2.8}
			if t > 35.0:
				w["nullifier"] = 2.8
			if t > 70.0:
				w["sentinel"] = 2.4
			if t > 105.0:
				w["splitter"] = 2.6
			if t > 140.0:
				w["mech"] = 2.0
			return w
		_:
			var w := {"blob": maxf(2.0, 10.0 - t / 40.0), "moth": 2.0}
			if t > 55.0:
				w["thorn"] = 2.2
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
