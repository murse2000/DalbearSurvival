class_name PlayGamesConfig
extends RefCounted

## Android-only Google Play Games Services configuration.
## Replace the empty achievement/leaderboard values with the IDs created in
## Play Console. Empty IDs are safe: the game keeps working as a guest and queues
## the local achievement until an ID is available.

const GAME_ID := "583342371197"
const OAUTH_CLIENT_ID := "583342371197-6nfgel33vm8arksim93p29bak52sr8cc.apps.googleusercontent.com"
const CLOUD_SAVE_NAME := "dalbear_save_v1"

const ACHIEVEMENT_IDS := {
	"first_clear": "",
	"final_clear": "",
	"kills_1000": "",
	"kills_10000": "",
	"boss_10": "",
	"level_30": "",
	"evo_8": "",
	"relic_3": "",
	"legendary": "",
	"endless_600": "",
	"daily_1": "",
	"enhance_5": "",
}

const LEADERBOARD_IDS := {
	"endless_time": "",
	"endless_kills": "",
	"daily_time": "",
	"weekly_time": "",
}
