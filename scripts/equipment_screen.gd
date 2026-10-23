extends Control

## Armory hub: character paper-doll, slot grid and inventory.

const SLOT_CARD_SIZE := Vector2(72, 72)
const PAPER_PANEL_POS := Vector2(36, 140)
const PAPER_PANEL_SIZE := Vector2(668, 548)
const INV_PANEL_POS := Vector2(724, 140)
const INV_PANEL_SIZE := Vector2(520, 548)
const INV_CELL := 64.0
const INV_GAP := 6

const DOLL_SLOTS := {
	"helmet": Vector2(28, 60),
	"chest": Vector2(28, 156),
	"pants": Vector2(28, 252),
	"boots": Vector2(28, 348),
	"gloves": Vector2(568, 100),
	"cape": Vector2(568, 206),
	"necklace": Vector2(568, 312),
	"main": Vector2(166, 448),
	"secondary": Vector2(254, 448),
	"ring1": Vector2(342, 448),
	"ring2": Vector2(430, 448),
}

var _args: PackedStringArray
var _slot_cards := {}
var _filter_buttons := {}
var _filter := "all"
var _selected_uid := ""
var _confirm_dismantle_uid := ""
var _confirm_timer := 0.0
var _message_timer := 0.0
var _paper_time := 0.0

var _shards_label: Label
var _inventory_count: Label
var _power_label: Label
var _message: Label
var _scroll: ScrollContainer
var _inv_grid: GridContainer
var _paper_character: TextureRect
var _paper_glow: TextureRect
var _paper_hint: Label
var _detail_panel: Panel
var _detail_icon: TextureRect
var _detail_glow: TextureRect
var _detail_name: Label
var _detail_type: Label
var _detail_stats: RichTextLabel
var _detail_weapon: Label
var _action_row: HBoxContainer
var _legendary_effects: Array = []
var _portrait := false
var _paper_pos := PAPER_PANEL_POS
var _inv_pos := INV_PANEL_POS
var _reloading := false
var _best_btn: Button
var _bulk_btn: Button
var _loadout_btn: Button
var _lock_btn: Button
var _bulk_modal: Control
var _loadout_modal: Control
var _bulk_desc: Label
var _loadout_labels: Array = []
var _bulk_candidates := 0
var _bulk_value := 0
var _paper_frame: Panel
var _drag_layer: CanvasLayer
var _drag_ghost: TextureRect
var _drag_uid := ""
var _drag_start := Vector2.ZERO
var _drag_moved := 0.0
var _drag_hover_slot := ""
var _inv_cells: Array = []
var _press_uid := ""
var _press_pos := Vector2.ZERO
var _press_scroll := 0
var _press_active := false


func _is_portrait() -> bool:
	var size := get_viewport_rect().size
	return size.y > size.x


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	Engine.time_scale = 1.0
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_portrait = _is_portrait()
	if _portrait:
		# Two 1280x720 panels stacked at 1:1 so their text keeps its design size.
		_paper_pos = Vector2(26, 140)
		_inv_pos = Vector2(100, 706)
	_build()
	UIFit.wrap_menu(self, "res://assets/art/ui/menu_backdrop.png",
		UIFit.PORTRAIT if _portrait else UIFit.DESIGN)
	_build_drag_layer()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_refresh_all()
	if "--capture-equipment" in _args:
		_capture()
	if "--capture-equipment-detail" in _args:
		_capture_detail()
	if "--test-equipment" in _args:
		_test_equipment.call_deferred()
	if "--test-drag" in _args:
		_test_drag.call_deferred()
	if "--test-gear-qol" in _args:
		_test_gear_qol.call_deferred()
	if "--capture-bulk" in _args:
		_capture_bulk.call_deferred()
	if "--capture-loadout" in _args:
		_capture_loadout.call_deferred()


func _build_drag_layer() -> void:
	_drag_layer = CanvasLayer.new()
	_drag_layer.layer = 60
	add_child(_drag_layer)
	_drag_ghost = TextureRect.new()
	_drag_ghost.visible = false
	_drag_ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drag_ghost.stretch_mode = TextureRect.STRETCH_SCALE
	_drag_ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_drag_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_layer.add_child(_drag_ghost)


func _on_viewport_resized() -> void:
	if _reloading:
		return
	if _is_portrait() == _portrait:
		return
	_reloading = true
	get_tree().reload_current_scene.call_deferred()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/ui/title_bg.png")
	if _portrait:
		bg.position = Vector2(-180, -14)
		bg.size = Vector2(1080, 1308)
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	else:
		bg.position = Vector2(-26, -14)
		bg.size = Vector2(1332, 748)
		bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.04, 0.8)
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var over := UIKit.label("ARMORY  ·  DALBEAR.COM", 13, UIKit.MINT)
	over.position = Vector2(26, 20) if _portrait else Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("장비 & 인벤토리", 40 if _portrait else 46, UIKit.GOLD, 7)
	title.position = Vector2(24, 34) if _portrait else Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("장비를 장착하고 달빛 조각으로 강화하세요. 다음 밤이 더 길어집니다.", 14 if _portrait else 16, UIKit.CREAM)
	sub.position = Vector2(26, 92) if _portrait else Vector2(56, 98)
	add_child(sub)

	var back := UIKit.button("← 돌아가기", Vector2(164, 42))
	back.position = Vector2(540, 22) if _portrait else Vector2(1074, 30)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_go_back)
	add_child(back)

	var shard_panel := UIKit.panel(Color(0.06, 0.09, 0.13, 0.96), UIKit.GOLD.darkened(0.45), 1)
	if _portrait:
		UIKit.place(shard_panel, 500, 68, 194, 36)
	else:
		UIKit.place(shard_panel, 916, 84, 308, 40)
	add_child(shard_panel)
	var shard_icon := UIKit.icon("res://assets/art/ui/icon_moon.png", 20)
	UIKit.place(shard_icon, 12, 8 if _portrait else 10, 20, 20)
	shard_panel.add_child(shard_icon)
	_shards_label = UIKit.label("", 16, UIKit.GOLD)
	UIKit.place(_shards_label, 38, 6 if _portrait else 8, 150 if _portrait else 258, 24)
	_shards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	shard_panel.add_child(_shards_label)

	var header_line := ColorRect.new()
	header_line.color = Color(0.85, 0.68, 0.35, 0.28)
	header_line.position = Vector2(26, 130) if _portrait else Vector2(36, 126)
	header_line.size = Vector2(668, 1) if _portrait else Vector2(1208, 1)
	header_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header_line)

	_build_equipment_panel()
	_build_inventory_panel()

	_message = UIKit.label("", 14, UIKit.MINT)
	_message.position = Vector2(26, 1262) if _portrait else Vector2(36, 696)
	_message.size = Vector2(668, 18) if _portrait else Vector2(1208, 20)
	_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_message)
	_build_utility_modals()


func _build_equipment_panel() -> void:
	var panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.95), UIKit.BORDER, 2)
	panel.position = _paper_pos
	panel.size = PAPER_PANEL_SIZE
	add_child(panel)

	var title := UIKit.label("장착 장비", 22, UIKit.GOLD, 4)
	title.position = Vector2(16, 8)
	panel.add_child(title)
	var friends_btn := UIKit.button("친구들", Vector2(104, 26))
	friends_btn.position = Vector2(330, 7)
	friends_btn.add_theme_font_size_override("font_size", 12)
	friends_btn.pressed.connect(_open_characters)
	panel.add_child(friends_btn)
	_power_label = UIKit.label("", 12, UIKit.MINT)
	_power_label.position = Vector2(466, 12)
	_power_label.size = Vector2(186, 20)
	_power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_power_label)
	var hairline := ColorRect.new()
	hairline.color = Color(0.85, 0.68, 0.35, 0.2)
	hairline.position = Vector2(16, 34)
	hairline.size = Vector2(636, 1)
	hairline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hairline)

	_build_character_frame(panel)

	for slot in EquipmentData.SLOT_ORDER:
		_make_slot_card(panel, slot, DOLL_SLOTS[slot])


func _build_character_frame(parent: Control) -> void:
	var frame := UIKit.panel(Color(0.032, 0.052, 0.082, 0.98),
		UIKit.GOLD.darkened(0.38), 2)
	UIKit.place(frame, 184, 44, 300, 350)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(frame)
	_paper_frame = frame

	var corner := ColorRect.new()
	corner.color = Color(0.85, 0.68, 0.35, 0.25)
	corner.position = Vector2(2, 2)
	corner.size = Vector2(296, 2)
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(corner)

	_paper_glow = TextureRect.new()
	_paper_glow.texture = load("res://assets/art/fx/glow_gold.png")
	_paper_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_paper_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_paper_glow.position = Vector2(20, 10)
	_paper_glow.size = Vector2(260, 260)
	_paper_glow.modulate = Color(1, 0.86, 0.48, 0.16)
	_paper_glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_paper_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(_paper_glow)

	var shadow := TextureRect.new()
	shadow.texture = load("res://assets/art/char/shadow.png")
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.stretch_mode = TextureRect.STRETCH_SCALE
	shadow.position = Vector2(96, 226)
	shadow.size = Vector2(108, 34)
	shadow.modulate = Color(1, 1, 1, 0.48)
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(shadow)

	var atlas := AtlasTexture.new()
	atlas.atlas = load(CharacterData.sheet(Game.selected_character))
	atlas.region = Rect2(0, 0, 32, 36)
	_paper_character = TextureRect.new()
	_paper_character.texture = atlas
	_paper_character.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_paper_character.stretch_mode = TextureRect.STRETCH_SCALE
	_paper_character.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_paper_character.position = Vector2(54, 18)
	_paper_character.size = Vector2(192, 216)
	_paper_character.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(_paper_character)

	var ch := Game.character_data()
	var name_label := UIKit.label(String(ch.get("name", "달베어")), 22, UIKit.GOLD, 4)
	name_label.position = Vector2(0, 244)
	name_label.size = Vector2(300, 26)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(name_label)
	var sub := UIKit.label("%s · 장비 11슬롯" % String(ch.get("tag", "MOON GUARDIAN")), 10, UIKit.MINT)
	sub.position = Vector2(0, 272)
	sub.size = Vector2(300, 16)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(sub)
	_paper_hint = UIKit.label("장비를 슬롯으로 끌어 장착", 10, UIKit.MUTED)
	_paper_hint.position = Vector2(0, 302)
	_paper_hint.size = Vector2(300, 16)
	_paper_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(_paper_hint)
	var hint2 := UIKit.label("장착한 무기로 다음 런을 시작합니다", 9, Color(0.47, 0.56, 0.64))
	hint2.position = Vector2(0, 320)
	hint2.size = Vector2(300, 14)
	hint2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(hint2)


func _make_slot_card(parent: Control, slot: String, pos: Vector2) -> void:
	var card := UIKit.panel(Color(0.06, 0.095, 0.14, 0.96), UIKit.BORDER, 2)
	card.position = pos
	card.size = SLOT_CARD_SIZE
	card.clip_contents = true
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(card)

	var glow := TextureRect.new()
	glow.texture = load("res://assets/art/fx/glow_gold.png")
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.position = Vector2(-4, -10)
	glow.size = Vector2(80, 80)
	glow.pivot_offset = Vector2(40, 40)
	glow.modulate = Color(1.0, 0.84, 0.42, 0.32)
	var gmat := CanvasItemMaterial.new()
	gmat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = gmat
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.visible = false
	card.add_child(glow)

	var icon := UIKit.icon(_empty_slot_icon(slot), 48)
	UIKit.place(icon, 12, 8, 48, 48)
	card.add_child(icon)

	var level_badge := UIKit.panel(Color(0.02, 0.032, 0.052, 0.96), UIKit.BORDER, 1)
	UIKit.place(level_badge, 39, 47, 29, 17)
	level_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(level_badge)
	var level_label := UIKit.label("", 8, UIKit.GOLD)
	UIKit.place(level_label, 0, 2, 29, 13)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_badge.add_child(level_label)

	var rarity_band := ColorRect.new()
	rarity_band.position = Vector2(0, 68)
	rarity_band.size = Vector2(SLOT_CARD_SIZE.x, 4)
	rarity_band.visible = false
	rarity_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rarity_band)

	var slot_label := UIKit.label(String(EquipmentData.SLOT_LABELS.get(slot, slot)), 10, UIKit.MUTED)
	slot_label.position = Vector2(pos.x, pos.y + 74)
	slot_label.size = Vector2(SLOT_CARD_SIZE.x, 15)
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(slot_label)

	card.gui_input.connect(_on_slot_input.bind(slot))
	card.mouse_entered.connect(_on_slot_hover.bind(slot, true))
	card.mouse_exited.connect(_on_slot_hover.bind(slot, false))
	_slot_cards[slot] = {
		"root": card, "icon": icon, "level_badge": level_badge,
		"level_label": level_label, "slot_label": slot_label,
		"rarity_band": rarity_band, "glow": glow,
	}


func _empty_slot_icon(slot: String) -> String:
	if slot == "secondary":
		return "res://assets/art/ui/icon_satellite.png"
	if slot == "main":
		return "res://assets/art/ui/icon_moon_shot.png"
	if slot in EquipmentData.RING_SLOTS:
		return "res://assets/art/ui/icon_equip_ring.png"
	return String(EquipmentData.ICON_PATHS.get(slot, EquipmentData.ICON_PATHS["helmet"]))


func _build_inventory_panel() -> void:
	var panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.95), UIKit.BORDER, 2)
	panel.position = _inv_pos
	panel.size = INV_PANEL_SIZE
	add_child(panel)

	var title := UIKit.label("인벤토리", 20, UIKit.GOLD, 4)
	title.position = Vector2(16, 8)
	panel.add_child(title)
	_inventory_count = UIKit.label("", 11, UIKit.MUTED)
	_inventory_count.position = Vector2(240, 11)
	_inventory_count.size = Vector2(150, 20)
	_inventory_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_inventory_count)

	_best_btn = UIKit.button("최적 장착", Vector2(104, 26))
	_best_btn.position = Vector2(400, 5)
	_best_btn.add_theme_font_size_override("font_size", 11)
	_best_btn.pressed.connect(_on_best_pressed)
	panel.add_child(_best_btn)

	_bulk_btn = UIKit.button("일괄 분해", Vector2(98, 24))
	_bulk_btn.position = Vector2(16, 66)
	_bulk_btn.add_theme_font_size_override("font_size", 10)
	_bulk_btn.pressed.connect(_open_bulk_modal)
	panel.add_child(_bulk_btn)
	_loadout_btn = UIKit.button("로드아웃", Vector2(98, 24))
	_loadout_btn.position = Vector2(120, 66)
	_loadout_btn.add_theme_font_size_override("font_size", 10)
	_loadout_btn.pressed.connect(_open_loadout_modal)
	panel.add_child(_loadout_btn)

	var filters := HBoxContainer.new()
	filters.position = Vector2(16, 38)
	filters.size = Vector2(360, 24)
	filters.add_theme_constant_override("separation", 6)
	panel.add_child(filters)
	for entry in [["all", "전체"], ["armor", "방어구"], ["weapon", "무기"], ["accessory", "악세서리"]]:
		var key := String(entry[0])
		var b := UIKit.button(String(entry[1]), Vector2(80 if key != "accessory" else 94, 24))
		b.add_theme_font_size_override("font_size", 10)
		b.toggle_mode = true
		b.button_pressed = key == _filter
		b.pressed.connect(_on_filter_pressed.bind(key))
		filters.add_child(b)
		_filter_buttons[key] = b

	var legend := UIKit.label("● 장착 중", 9, UIKit.GOLD)
	legend.position = Vector2(372, 40)
	legend.size = Vector2(116, 20)
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(legend)

	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(20, 96)
	_scroll.size = Vector2(448, 252)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(_scroll)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 11)
	margin.add_theme_constant_override("margin_right", 11)
	margin.add_theme_constant_override("margin_top", 0)
	_scroll.add_child(margin)
	_inv_grid = GridContainer.new()
	_inv_grid.columns = 6
	_inv_grid.add_theme_constant_override("h_separation", INV_GAP)
	_inv_grid.add_theme_constant_override("v_separation", INV_GAP)
	margin.add_child(_inv_grid)

	_detail_panel = UIKit.panel(Color(0.06, 0.095, 0.14, 0.97), UIKit.BORDER, 2)
	UIKit.place(_detail_panel, 16, 360, 488, 172)
	panel.add_child(_detail_panel)

	_detail_glow = TextureRect.new()
	_detail_glow.texture = load("res://assets/art/fx/glow_gold.png")
	_detail_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_detail_glow.position = Vector2(-8, -12)
	_detail_glow.size = Vector2(76, 76)
	_detail_glow.pivot_offset = Vector2(38, 38)
	_detail_glow.modulate = Color(1.0, 0.84, 0.42, 0.34)
	var detail_mat := CanvasItemMaterial.new()
	detail_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_detail_glow.material = detail_mat
	_detail_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail_glow.visible = false
	_detail_panel.add_child(_detail_glow)

	_detail_icon = UIKit.icon("res://assets/art/ui/icon_equip_chest.png", 40)
	UIKit.place(_detail_icon, 8, 8, 40, 40)
	_detail_panel.add_child(_detail_icon)

	_detail_name = UIKit.label("", 17, UIKit.CREAM, 3)
	UIKit.place(_detail_name, 56, 3, 320, 24)
	_detail_panel.add_child(_detail_name)
	_lock_btn = UIKit.button("잠금", Vector2(84, 22))
	UIKit.place(_lock_btn, 386, 4, 84, 22)
	_lock_btn.add_theme_font_size_override("font_size", 10)
	_lock_btn.visible = false
	_lock_btn.pressed.connect(_toggle_lock_selected)
	_detail_panel.add_child(_lock_btn)
	_detail_type = UIKit.label("", 10, UIKit.MUTED)
	UIKit.place(_detail_type, 56, 26, 420, 16)
	_detail_panel.add_child(_detail_type)
	_detail_stats = RichTextLabel.new()
	_detail_stats.bbcode_enabled = true
	_detail_stats.scroll_active = false
	_detail_stats.fit_content = true
	_detail_stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail_stats.add_theme_font_override("normal_font", load("res://assets/fonts/Galmuri11.ttf"))
	_detail_stats.add_theme_font_size_override("normal_font_size", 10)
	_detail_stats.add_theme_constant_override("line_separation", 0)
	UIKit.place(_detail_stats, 56, 42, 420, 62)
	_detail_panel.add_child(_detail_stats)
	_detail_weapon = UIKit.label("", 10, UIKit.GOLD)
	UIKit.place(_detail_weapon, 56, 106, 420, 13)
	_detail_panel.add_child(_detail_weapon)

	_action_row = HBoxContainer.new()
	_action_row.position = Vector2(8, 122)
	_action_row.size = Vector2(472, 32)
	_action_row.add_theme_constant_override("separation", 6)
	_detail_panel.add_child(_action_row)


func _build_utility_modals() -> void:
	_bulk_modal = Control.new()
	_bulk_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bulk_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_bulk_modal.visible = false
	add_child(_bulk_modal)
	var bulk_dim := UIKit.dimmer(0.76)
	_bulk_modal.add_child(bulk_dim)
	var bw := 660.0 if _portrait else 560.0
	var bh := 300.0
	var bp := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99), UIKit.GOLD, 2)
	bp.position = Vector2(30, 400) if _portrait else Vector2(360, 210)
	bp.size = Vector2(bw, bh)
	bp.mouse_filter = Control.MOUSE_FILTER_STOP
	_bulk_modal.add_child(bp)
	var btitle := UIKit.label("일괄 분해", 28 if _portrait else 26, UIKit.GOLD, 5)
	btitle.position = Vector2(24, 18)
	bp.add_child(btitle)
	_bulk_desc = UIKit.label("", 14, UIKit.CREAM)
	_bulk_desc.position = Vector2(26, 64)
	_bulk_desc.size = Vector2(bw - 52, 90 if _portrait else 70)
	_bulk_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bp.add_child(_bulk_desc)
	var confirm_y := 220.0 if _portrait else 210.0
	var confirm := UIKit.button("분해 실행", Vector2(190, 50))
	confirm.position = Vector2(26, confirm_y)
	confirm.add_theme_font_size_override("font_size", 18)
	confirm.pressed.connect(_confirm_bulk)
	bp.add_child(confirm)
	var cancel := UIKit.button("취소", Vector2(140, 50))
	cancel.position = Vector2(230, confirm_y)
	cancel.add_theme_font_size_override("font_size", 17)
	cancel.pressed.connect(func(): _bulk_modal.visible = false)
	bp.add_child(cancel)

	_loadout_modal = Control.new()
	_loadout_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_loadout_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_loadout_modal.visible = false
	add_child(_loadout_modal)
	var load_dim := UIKit.dimmer(0.76)
	_loadout_modal.add_child(load_dim)
	var lw := 660.0 if _portrait else 640.0
	var lh := 520.0 if _portrait else 430.0
	var lp := UIKit.panel(Color(0.047, 0.075, 0.114, 0.99), UIKit.GOLD, 2)
	lp.position = Vector2(30, 380) if _portrait else Vector2(320, 145)
	lp.size = Vector2(lw, lh)
	lp.mouse_filter = Control.MOUSE_FILTER_STOP
	_loadout_modal.add_child(lp)
	var ltitle := UIKit.label("로드아웃", 28 if _portrait else 26, UIKit.GOLD, 5)
	ltitle.position = Vector2(24, 18)
	lp.add_child(ltitle)
	var lsub := UIKit.label("현재 장착 상태를 저장하거나 불러옵니다.", 13, UIKit.MUTED)
	lsub.position = Vector2(26, 58)
	lp.add_child(lsub)
	_loadout_labels.clear()
	for i in 3:
		var row_y := 100.0 + float(i) * (104.0 if _portrait else 84.0)
		var name := UIKit.label("로드아웃 %d" % (i + 1), 18, UIKit.CREAM)
		name.position = Vector2(26, row_y)
		lp.add_child(name)
		var info := UIKit.label("", 12, UIKit.MUTED)
		info.position = Vector2(26, row_y + 26)
		info.size = Vector2(lw - 300, 18)
		lp.add_child(info)
		_loadout_labels.append(info)
		var save := UIKit.button("저장", Vector2(76, 34))
		save.position = Vector2(lw - 274, row_y - 2)
		save.add_theme_font_size_override("font_size", 13)
		save.pressed.connect(_save_loadout.bind(i))
		lp.add_child(save)
		var load := UIKit.button("불러오기", Vector2(94, 34))
		load.position = Vector2(lw - 190, row_y - 2)
		load.add_theme_font_size_override("font_size", 13)
		load.pressed.connect(_apply_loadout.bind(i))
		lp.add_child(load)
		var remove := UIKit.button("×", Vector2(36, 34))
		remove.position = Vector2(lw - 88, row_y - 2)
		remove.add_theme_font_size_override("font_size", 16)
		remove.pressed.connect(_clear_loadout.bind(i))
		lp.add_child(remove)
	var close_y := (lh - 58.0)
	var close := UIKit.button("닫기", Vector2(160, 44))
	close.position = Vector2((lw - 160) * 0.5, close_y)
	close.add_theme_font_size_override("font_size", 17)
	close.pressed.connect(func(): _loadout_modal.visible = false)
	lp.add_child(close)


func _count_bulk_candidates() -> Dictionary:
	var count := 0
	var value := 0
	for item in Game.inventory:
		if item.is_empty():
			continue
		var uid := String(item.get("uid", ""))
		if uid == "" or Game.is_item_equipped(uid):
			continue
		if bool(item.get("locked", false)) or EquipmentData.is_signature(item):
			continue
		if not String(item.get("rarity", "common")) in ["common", "rare"]:
			continue
		count += 1
		value += EquipmentData.dismantle_value(item)
	return {"count": count, "value": value}


func _open_bulk_modal() -> void:
	var info := _count_bulk_candidates()
	_bulk_candidates = int(info["count"])
	_bulk_value = int(info["value"])
	_bulk_desc.text = "일반·희귀 등급만 분해합니다.\n장착 중·잠금·전용·에픽 이상은 제외됩니다.\n\n대상 %d개 · 예상 달빛 조각 +%d" % [_bulk_candidates, _bulk_value]
	_bulk_modal.visible = true
	Audio.play_click()


func _confirm_bulk() -> void:
	var result := Game.bulk_dismantle(["common", "rare"])
	_bulk_modal.visible = false
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.MUTED)
	_confirm_dismantle_uid = ""
	_refresh_all()


func _open_loadout_modal() -> void:
	_refresh_loadouts()
	_loadout_modal.visible = true
	Audio.play_click()


func _refresh_loadouts() -> void:
	for i in _loadout_labels.size():
		var label: Label = _loadout_labels[i]
		var suffix := " · 현재 친구" if not Game.loadouts[i].is_empty() and String(Game.loadouts[i].get("character", "")) == Game.selected_character else ""
		label.text = Game.loadout_summary(i) + suffix
		label.add_theme_color_override("font_color", UIKit.MUTED if Game.loadouts[i].is_empty() else UIKit.MINT)


func _save_loadout(index: int) -> void:
	var result := Game.save_loadout(index)
	Audio.play_click()
	_refresh_loadouts()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)


func _apply_loadout(index: int) -> void:
	var result := Game.apply_loadout(index)
	Audio.play_click()
	_refresh_loadouts()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_refresh_all()


func _clear_loadout(index: int) -> void:
	var result := Game.clear_loadout(index)
	Audio.play_click()
	_refresh_loadouts()
	_show_message(String(result.get("message", "")), UIKit.MUTED)


func _refresh_all() -> void:
	_legendary_effects.clear()
	var keep_scroll := 0
	if _scroll != null:
		keep_scroll = _scroll.scroll_vertical
	if _shards_label != null:
		_shards_label.text = "달빛 조각  %d" % Game.shards
	if _power_label != null:
		_power_label.text = "전투력 %d" % Game.equipment_power()
	_refresh_slots()
	_sync_filters()
	_build_inventory()
	_refresh_detail()
	if _scroll != null:
		_scroll.scroll_vertical = keep_scroll


func _refresh_slots() -> void:
	for slot in EquipmentData.SLOT_ORDER:
		var refs: Dictionary = _slot_cards.get(slot, {})
		if refs.is_empty():
			continue
		var item := Game.equipped_item(slot)
		var card: Panel = refs["root"]
		var icon: TextureRect = refs["icon"]
		var level_badge: Panel = refs["level_badge"]
		var level_label: Label = refs["level_label"]
		var slot_label: Label = refs["slot_label"]
		var rarity_band: ColorRect = refs["rarity_band"]
		var glow: TextureRect = refs["glow"]
		var selected := false
		if item.is_empty():
			icon.texture = load(_empty_slot_icon(slot))
			icon.modulate = Color(1, 1, 1, 0.22)
			level_badge.visible = false
			rarity_band.visible = false
			glow.visible = false
			slot_label.add_theme_color_override("font_color", Color(0.46, 0.53, 0.6))
			card.add_theme_stylebox_override("panel",
				UIKit.style(Color(0.035, 0.052, 0.078, 0.94), UIKit.BORDER, 2, 0))
			card.tooltip_text = "%s 슬롯 · 비어 있음" % String(EquipmentData.SLOT_LABELS.get(slot, slot))
		else:
			var accent := EquipmentData.display_color(item)
			var rarity_accent := EquipmentData.rarity_color(String(item.get("rarity", "common")))
			var legendary := EquipmentData.is_legendary(item)
			selected = String(item.get("uid", "")) == _selected_uid
			icon.texture = load(EquipmentData.item_icon(item))
			icon.modulate = Color.WHITE
			level_badge.visible = true
			level_badge.add_theme_stylebox_override("panel",
				UIKit.style(Color(0.02, 0.032, 0.052, 0.96), rarity_accent.darkened(0.25), 1, 0))
			level_label.text = "Lv.%d" % int(item.get("level", 1))
			level_label.add_theme_color_override("font_color", rarity_accent)
			rarity_band.visible = true
			rarity_band.color = rarity_accent
			glow.visible = legendary
			if legendary:
				_legendary_effects.append({"node": glow, "phase": randf() * TAU, "base": 0.32})
			slot_label.add_theme_color_override("font_color", UIKit.GOLD if selected else rarity_accent.lightened(0.2))
			card.add_theme_stylebox_override("panel", UIKit.style(
				Color(0.09, 0.13, 0.18, 0.98) if selected else Color(0.06, 0.095, 0.14, 0.96),
				UIKit.GOLD if selected else (rarity_accent.lightened(0.15) if legendary else accent.darkened(0.2)),
				3 if (selected or legendary) else 2, 0))
			card.tooltip_text = "%s\n%s · %s · Lv.%d\n%s" % [
				EquipmentData.item_name(item),
				EquipmentData.type_label(item),
				EquipmentData.rarity_name(String(item.get("rarity", "common"))),
				int(item.get("level", 1)),
				"  ·  ".join(EquipmentData.stat_lines(item)),
			]
			var affinity := EquipmentData.affinity_label(item)
			if affinity != "":
				card.tooltip_text += "\n" + affinity
	_update_paper_profile()


func _update_paper_profile() -> void:
	if _paper_glow == null:
		return
	var char_color := CharacterData.color(Game.selected_character)
	var equipped_count := 0
	for slot in EquipmentData.SLOT_ORDER:
		var item := Game.equipped_item(slot)
		if not item.is_empty():
			equipped_count += 1
	_paper_glow.modulate = Color(char_color.r, char_color.g, char_color.b, 0.18)
	if _paper_hint != null:
		if _selected_uid != "":
			var item := Game.item_by_uid(_selected_uid)
			if not item.is_empty():
				_paper_hint.text = "%s · Lv.%d" % [
					EquipmentData.item_name(item), int(item.get("level", 1)),
				]
			else:
				_paper_hint.text = "장비를 슬롯으로 끌어 장착"
		else:
			_paper_hint.text = "장비를 슬롯으로 끌어 장착 · %d/11" % equipped_count


func _on_slot_hover(slot: String, hovered: bool) -> void:
	var refs: Dictionary = _slot_cards.get(slot, {})
	if refs.is_empty():
		return
	var card: Panel = refs["root"]
	var item := Game.equipped_item(slot)
	if hovered:
		if item.is_empty():
			_paper_hint.text = "%s 슬롯 · 비어 있음" % String(EquipmentData.SLOT_LABELS.get(slot, slot))
		else:
			_paper_hint.text = "%s · Lv.%d" % [
				EquipmentData.item_name(item), int(item.get("level", 1)),
			]
	else:
		_update_paper_profile()
	if item.is_empty():
		card.add_theme_stylebox_override("panel", UIKit.style(
			Color(0.07, 0.10, 0.14, 0.96) if hovered else Color(0.035, 0.052, 0.078, 0.94),
			UIKit.GOLD.darkened(0.5) if hovered else UIKit.BORDER, 2, 0))
		return
	var accent := EquipmentData.display_color(item)
	var selected := String(item.get("uid", "")) == _selected_uid
	card.add_theme_stylebox_override("panel", UIKit.style(
		Color(0.115, 0.16, 0.21, 0.99) if hovered else (Color(0.09, 0.13, 0.18, 0.98) if selected else Color(0.06, 0.095, 0.14, 0.96)),
		UIKit.GOLD if selected else (accent if hovered else accent.darkened(0.2)),
		3 if selected else 2, 0))


func _on_slot_input(event: InputEvent, slot: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var item := Game.equipped_item(slot)
		if item.is_empty():
			_filter = EquipmentData.group_of(_item_slot_for_equipment_slot(slot))
			_sync_filters()
			_build_inventory()
			if _scroll != null:
				_scroll.scroll_vertical = 0
			_show_message("빈 슬롯입니다. 인벤토리에서 장비를 선택하세요.", UIKit.MUTED)
		else:
			_select_item(String(item.get("uid", "")))


func _item_slot_for_equipment_slot(slot: String) -> String:
	if slot in EquipmentData.WEAPON_SLOTS:
		return "weapon"
	if slot in EquipmentData.RING_SLOTS:
		return "ring"
	return slot


func _sync_filters() -> void:
	for key in _filter_buttons.keys():
		var b: Button = _filter_buttons[key]
		b.set_pressed_no_signal(String(key) == _filter)


func _on_filter_pressed(group: String) -> void:
	_filter = group
	_sync_filters()
	_build_inventory()
	if _scroll != null:
		_scroll.scroll_vertical = 0


func _build_inventory() -> void:
	if _inv_grid == null:
		return
	_inv_cells.clear()
	for child in _inv_grid.get_children():
		_inv_grid.remove_child(child)
		child.queue_free()
	var items: Array = []
	for item in Game.inventory:
		if not item is Dictionary:
			continue
		if _filter != "all" and EquipmentData.group_of(String(item.get("slot", ""))) != _filter:
			continue
		items.append(item)
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra := EquipmentData.RARITY_ORDER.find(String(a.get("rarity", "common")))
		var rb := EquipmentData.RARITY_ORDER.find(String(b.get("rarity", "common")))
		if ra != rb:
			return ra > rb
		var la := int(a.get("level", 1))
		var lb := int(b.get("level", 1))
		if la != lb:
			return la > lb
		return EquipmentData.item_power(a) > EquipmentData.item_power(b)
	)
	if _inventory_count != null:
		_inventory_count.text = "%d개" % items.size()
	for item in items:
		var cell := _make_inventory_cell(item)
		_inv_grid.add_child(cell)
		_inv_cells.append({"uid": String(item.get("uid", "")), "cell": cell})
	var filled := maxi(24, items.size())
	for i in range(items.size(), filled):
		_inv_grid.add_child(_make_empty_cell())


func _make_inventory_cell(item: Dictionary) -> Panel:
	var rarity_id := String(item.get("rarity", "common"))
	var accent := EquipmentData.display_color(item)
	var rarity_accent := EquipmentData.rarity_color(rarity_id)
	var type_accent := EquipmentData.type_color(item)
	var uid := String(item.get("uid", ""))
	var selected := uid == _selected_uid
	var equipped := Game.is_item_equipped(uid)
	var legendary := EquipmentData.is_legendary(item)
	var can_use := not EquipmentData.is_signature(item) or EquipmentData.item_character(item) == Game.selected_character
	var border := rarity_accent
	if equipped:
		border = UIKit.GOLD
	elif legendary:
		border = rarity_accent.lightened(0.2)
	var bg := Color(0.055, 0.082, 0.115, 0.96)
	if selected:
		bg = Color(0.09, 0.13, 0.18, 0.98)
	elif equipped:
		bg = Color(0.075, 0.10, 0.135, 0.98)
	var cell := UIKit.panel(bg, border, 3 if (equipped or legendary) else 2)
	cell.custom_minimum_size = Vector2(INV_CELL, INV_CELL)
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if legendary:
		var glow := TextureRect.new()
		glow.texture = load("res://assets/art/fx/glow_gold.png")
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.stretch_mode = TextureRect.STRETCH_SCALE
		glow.position = Vector2(-2, -8)
		glow.size = Vector2(68, 68)
		glow.pivot_offset = Vector2(34, 34)
		glow.modulate = Color(1.0, 0.84, 0.42, 0.32)
		var gmat := CanvasItemMaterial.new()
		gmat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = gmat
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(glow)
		_legendary_effects.append({"node": glow, "phase": randf() * TAU, "base": 0.32})

	var icon := UIKit.icon(EquipmentData.item_icon(item), 40)
	UIKit.place(icon, 12, 4, 40, 40)
	icon.modulate = Color(1, 1, 1, 0.38) if not can_use else Color.WHITE
	cell.add_child(icon)

	# Type badge (헬/장/흉/각/부/망/무/반/목) so silhouettes never blur together.
	var badge := UIKit.panel(type_accent.darkened(0.62), type_accent, 1)
	UIKit.place(badge, 2, 1, 18, 16)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(badge)
	var badge_label := UIKit.label(EquipmentData.item_short(item), 10, type_accent.lightened(0.35))
	UIKit.place(badge_label, 0, 2, 18, 12)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(badge_label)

	var level_badge := UIKit.panel(Color(0.02, 0.032, 0.052, 0.96), rarity_accent.darkened(0.25), 1)
	UIKit.place(level_badge, 33, 37, 29, 14)
	level_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(level_badge)
	var level_label := UIKit.label("Lv.%d" % int(item.get("level", 1)), 8, rarity_accent)
	UIKit.place(level_label, 0, 1, 29, 12)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_badge.add_child(level_label)

	# Rarity band with its name, readable at a glance.
	var band := ColorRect.new()
	band.color = rarity_accent
	band.position = Vector2(0, 52)
	band.size = Vector2(INV_CELL, 12)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(band)
	var band_label := UIKit.label(EquipmentData.rarity_name(rarity_id), 8,
		Color(0.06, 0.05, 0.08) if rarity_accent.get_luminance() > 0.5 else Color(0.96, 0.97, 1.0))
	UIKit.place(band_label, 0, 0, INV_CELL, 12)
	band_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	band_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	band_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(band_label)

	if equipped:
		var check := UIKit.label("✓", 13, UIKit.GOLD, 3)
		UIKit.place(check, 46, 0, 16, 16)
		check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		check.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(check)
	if bool(item.get("locked", false)):
		var lock_label := UIKit.label("잠", 9, UIKit.GOLD)
		UIKit.place(lock_label, 44, 16, 18, 14)
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(lock_label)

	var affinity := EquipmentData.affinity_label(item)
	var tooltip := "%s\n%s · %s · Lv.%d\n%s" % [
		EquipmentData.item_name(item),
		EquipmentData.type_label(item),
		EquipmentData.rarity_name(rarity_id),
		int(item.get("level", 1)),
		"  ·  ".join(EquipmentData.stat_lines(item)),
	]
	if equipped:
		tooltip = "[장착 중]\n" + tooltip
	if bool(item.get("locked", false)):
		tooltip = "[잠금]\n" + tooltip
	if affinity != "":
		tooltip += "\n" + affinity
		if not can_use:
			tooltip += " · 사용 불가"
	cell.tooltip_text = tooltip
	cell.gui_input.connect(_on_cell_input.bind(uid))
	cell.mouse_entered.connect(_on_cell_hover.bind(cell, item, true))
	cell.mouse_exited.connect(_on_cell_hover.bind(cell, item, false))
	return cell


func _make_empty_cell() -> Panel:
	var cell := UIKit.panel(Color(0.038, 0.058, 0.086, 0.7), Color(0.11, 0.16, 0.21, 0.8), 1)
	cell.custom_minimum_size = Vector2(INV_CELL, INV_CELL)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return cell


func _on_cell_hover(cell: Panel, item: Dictionary, hovered: bool) -> void:
	if not is_instance_valid(cell):
		return
	if _paper_hint != null:
		if hovered:
			_paper_hint.text = "%s · Lv.%d" % [
				EquipmentData.item_name(item), int(item.get("level", 1)),
			]
		else:
			_update_paper_profile()
	var uid := String(item.get("uid", ""))
	var selected := uid == _selected_uid
	var accent := EquipmentData.display_color(item)
	cell.add_theme_stylebox_override("panel", UIKit.style(
		Color(0.115, 0.16, 0.21, 0.99) if hovered else (Color(0.09, 0.13, 0.18, 0.98) if selected else Color(0.055, 0.082, 0.115, 0.96)),
		UIKit.GOLD if selected else (accent if hovered else accent.darkened(0.2)),
		2, 0))


func _on_cell_input(event: InputEvent, uid: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_item(uid)


func _select_item(uid: String) -> void:
	_selected_uid = uid
	_confirm_dismantle_uid = ""
	_confirm_timer = 0.0
	_refresh_all()


func _refresh_detail() -> void:
	if _action_row == null:
		return
	for child in _action_row.get_children():
		_action_row.remove_child(child)
		child.queue_free()
	var item := Game.item_by_uid(_selected_uid)
	if item.is_empty():
		_selected_uid = ""
		_detail_icon.texture = load("res://assets/art/ui/icon_equip_chest.png")
		_detail_icon.modulate = Color(1, 1, 1, 0.24)
		_detail_name.text = "장비를 선택하세요"
		_detail_name.add_theme_color_override("font_color", UIKit.MUTED)
		_detail_type.text = "캐릭터 주변 슬롯이나 오른쪽 격자에서 장비를 선택하세요."
		_detail_stats.text = ""
		_detail_weapon.text = ""
		if _lock_btn != null:
			_lock_btn.visible = false
		if _detail_glow != null:
			_detail_glow.visible = false
		_update_paper_profile()
		return

	var rarity_id := String(item.get("rarity", "common"))
	var accent := EquipmentData.display_color(item)
	var item_slot := String(item.get("slot", ""))
	var lv := int(item.get("level", 1))
	var cap := EquipmentData.max_level(item)
	var affinity := EquipmentData.affinity_label(item)
	var can_use := affinity == "" or EquipmentData.item_character(item) == Game.selected_character
	_detail_icon.texture = load(EquipmentData.item_icon(item))
	_detail_icon.modulate = Color.WHITE if can_use else Color(1, 1, 1, 0.42)
	var legendary := EquipmentData.is_legendary(item)
	_detail_glow.visible = legendary
	if legendary:
		_legendary_effects = _legendary_effects.filter(func(e: Dictionary) -> bool:
			return e.get("node") != _detail_glow)
		_legendary_effects.append({"node": _detail_glow, "phase": randf() * TAU, "base": 0.34})
	_detail_name.text = EquipmentData.item_name(item)
	_detail_name.add_theme_color_override("font_color", accent)
	var equipped_slot := Game.equipped_slot_of(_selected_uid)
	var equipped_text := "  ·  장착" if equipped_slot != "" else ""
	var affinity_text := ""
	if affinity != "":
		affinity_text = "  ·  " + affinity
		if not can_use:
			affinity_text += " · 사용 불가"
	_detail_type.text = "%s  ·  %s  ·  Lv.%d / %d%s%s" % [
		EquipmentData.type_label(item), EquipmentData.rarity_name(rarity_id), lv, cap,
		equipped_text, affinity_text,
	]
	var item_locked := Game.item_locked(_selected_uid)
	if item_locked:
		_detail_type.text += "  ·  잠금"
	if _lock_btn != null:
		_lock_btn.visible = true
		_lock_btn.text = "잠금 해제" if item_locked else "잠금"
	if Game.is_item_equipped(_selected_uid):
		_detail_stats.text = _plain_stats_bbcode(item)
	else:
		_detail_stats.text = _comparison_bbcode(item, Game.equipped_item(_compare_slot_for(item)))
	if affinity != "":
		var set_character := EquipmentData.item_character(item)
		var set_pieces := Game.signature_set_count(set_character)
		_detail_weapon.text = "%s 전용 · %s %d/3%s" % [
			CharacterData.display_name(set_character),
			EquipmentData.set_name(set_character), set_pieces,
			" · 세트 효과" if set_pieces >= 2 else "",
		]
		_detail_weapon.tooltip_text = EquipmentData.set_bonus_text(set_character, set_pieces)
	elif item_slot == "weapon":
		_detail_weapon.text = "시작 무기 Lv.%d · 강화로 시작 레벨 상승" % EquipmentData.starting_weapon_level(item)
	else:
		_detail_weapon.text = "장비 레벨이 오르면 능력치가 상승합니다."

	if not can_use:
		var locked := _action_button("다른 친구 전용", 160)
		locked.disabled = true
		_action_row.add_child(locked)
	elif item_slot in ["weapon", "ring"]:
		for target in EquipmentData.target_slots(item_slot):
			var label := String(EquipmentData.SLOT_LABELS.get(target, target))
			var is_here: bool = equipped_slot == String(target)
			var b := _action_button("✓ %s" % label if is_here else label, 100)
			b.pressed.connect(_on_target_pressed.bind(_selected_uid, target, is_here))
			_action_row.add_child(b)
	else:
		var is_here: bool = equipped_slot == item_slot
		var b := _action_button("✓ 장착" if is_here else "장착", 100)
		b.pressed.connect(_on_target_pressed.bind(_selected_uid, item_slot, is_here))
		_action_row.add_child(b)

	var enhance_text := "최대 레벨" if lv >= cap else "강화 ◈%d" % EquipmentData.enhance_cost(item)
	var enhance := _action_button(enhance_text, 126)
	enhance.disabled = lv >= cap or Game.shards < EquipmentData.enhance_cost(item)
	enhance.pressed.connect(_enhance_selected)
	_action_row.add_child(enhance)

	var dismantle_text := "정말 분해" if _confirm_dismantle_uid == _selected_uid else "분해"
	var dismantle := _action_button(dismantle_text, 86)
	dismantle.disabled = equipped_slot != "" or EquipmentData.is_signature(item) \
		or Game.item_locked(_selected_uid)
	dismantle.pressed.connect(_request_dismantle)
	_action_row.add_child(dismantle)
	_update_paper_profile()


func _action_button(text: String, width: float) -> Button:
	var b := UIKit.button(text, Vector2(width, 30))
	b.add_theme_font_size_override("font_size", 11)
	return b


func _compare_slot_for(item: Dictionary) -> String:
	var uid := String(item.get("uid", ""))
	var item_slot := String(item.get("slot", ""))
	if item_slot == "weapon":
		var occupied := Game.equipped_slot_of(uid)
		var wid := String(item.get("weapon_id", ""))
		for slot in EquipmentData.WEAPON_SLOTS:
			if String(slot) == occupied:
				continue
			var cur := Game.equipped_item(String(slot))
			if not cur.is_empty() and String(cur.get("weapon_id", "")) == wid:
				return String(slot)
		return _weakest_slot(EquipmentData.WEAPON_SLOTS, occupied)
	if item_slot == "ring":
		return _weakest_slot(EquipmentData.RING_SLOTS, Game.equipped_slot_of(uid))
	return item_slot


func _weakest_slot(slots: Array, skip: String) -> String:
	var best := ""
	var best_power := INF
	for slot in slots:
		if String(slot) == skip:
			continue
		var cur := Game.equipped_item(String(slot))
		var power := EquipmentData.item_power(cur) if not cur.is_empty() else -1.0
		if power < best_power:
			best_power = power
			best = String(slot)
	return best if best != "" else String(slots[0])


func _delta_text(key: String, delta: float) -> String:
	match key:
		"max_hp", "pickup", "power":
			return "%+d" % int(round(delta))
		"armor", "regen":
			return "%+.1f" % delta
	return "%+.1f%%" % (delta * 100.0)


func _plain_stats_bbcode(item: Dictionary) -> String:
	var lines: Array = []
	for key in EquipmentData.STAT_ORDER:
		var stats := EquipmentData.stats_for(item)
		if stats.has(key):
			lines.append(EquipmentData.stat_line(key, float(stats[key])))
	return "\n".join(lines)


func _comparison_bbcode(item: Dictionary, current: Dictionary) -> String:
	var lines: Array = []
	var power := EquipmentData.item_power(item)
	var current_power := 0.0 if current.is_empty() else EquipmentData.item_power(current)
	if current.is_empty():
		lines.append("[color=#93a3b4]전투력[/color] %d" % int(round(power)))
	else:
		var pd := power - current_power
		var pcol := "#7ee08a" if pd >= 0.0 else "#ff7a72"
		lines.append("[color=#93a3b4]전투력[/color] %d [color=%s](%s)[/color]" % [
			int(round(power)), pcol, _delta_text("power", pd),
		])
	for row in EquipmentData.stat_compare(item, current):
		var text := EquipmentData.stat_line(String(row["key"]), float(row["value"]))
		var delta := float(row["delta"])
		if absf(delta) > 0.0005:
			var better: bool = (delta < 0.0) if bool(row["lower_better"]) else (delta > 0.0)
			var col := "#7ee08a" if better else "#ff7a72"
			text += "  [color=%s](%s)[/color]" % [col, _delta_text(String(row["key"]), delta)]
		lines.append(text)
	return "\n".join(lines)


func _on_target_pressed(uid: String, target: String, currently_equipped: bool) -> void:
	var result: Dictionary
	if currently_equipped:
		if Game.unequip_slot(target):
			result = {"ok": true, "message": "%s을(를) 해제했습니다." % String(EquipmentData.SLOT_LABELS.get(target, target))}
		else:
			result = {"ok": false, "message": "해제할 장비가 없습니다."}
	else:
		result = Game.equip_item(uid, target)
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_confirm_dismantle_uid = ""
	_refresh_all()


func _enhance_selected() -> void:
	if _selected_uid == "":
		return
	var result := Game.enhance_item(_selected_uid)
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_confirm_dismantle_uid = ""
	_refresh_all()


func _toggle_lock_selected() -> void:
	if _selected_uid == "":
		return
	var result := Game.toggle_item_lock(_selected_uid)
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_confirm_dismantle_uid = ""
	_refresh_all()


func _request_dismantle() -> void:
	if _selected_uid == "":
		return
	if _confirm_dismantle_uid != _selected_uid:
		_confirm_dismantle_uid = _selected_uid
		_confirm_timer = 2.2
		_show_message("한 번 더 누르면 분해됩니다.", UIKit.CORAL)
		_refresh_detail()
		return
	var result := Game.dismantle_item(_selected_uid)
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_confirm_dismantle_uid = ""
	if bool(result.get("ok", false)):
		_selected_uid = ""
	_refresh_all()


func _show_message(text: String, color: Color = UIKit.MINT) -> void:
	if _message == null:
		return
	_message.text = text
	_message.add_theme_color_override("font_color", color)
	_message_timer = 2.6


func _process(delta: float) -> void:
	_paper_time += delta
	if _paper_character != null:
		_paper_character.position.y = 18.0 + sin(_paper_time * 1.7) * 1.5
	if _paper_glow != null:
		var glow_color := _paper_glow.modulate
		glow_color.a = 0.16 + sin(_paper_time * 1.3) * 0.025
		_paper_glow.modulate = glow_color
	if _message_timer > 0.0:
		_message_timer = maxf(0.0, _message_timer - delta)
		if _message_timer <= 0.0 and _message != null:
			_message.text = ""
	if _confirm_timer > 0.0:
		_confirm_timer = maxf(0.0, _confirm_timer - delta)
		if _confirm_timer <= 0.0 and _confirm_dismantle_uid != "":
			_confirm_dismantle_uid = ""
			_refresh_detail()
	for effect in _legendary_effects:
		var node: CanvasItem = effect.get("node")
		if not is_instance_valid(node):
			continue
		var pulse := 0.5 + 0.5 * sin(_paper_time * 2.6 + float(effect.get("phase", 0.0)))
		node.modulate.a = float(effect.get("base", 0.3)) + pulse * 0.22
		node.scale = Vector2.ONE * (1.0 + pulse * 0.06)


func _input(event: InputEvent) -> void:
	if _bulk_modal != null and _bulk_modal.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_bulk_modal.visible = false
			get_viewport().set_input_as_handled()
		return
	if _loadout_modal != null and _loadout_modal.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_loadout_modal.visible = false
			get_viewport().set_input_as_handled()
		return
	if _drag_uid != "":
		if event is InputEventMouseMotion:
			_drag_move(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_drag_release(event.position)
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_go_back()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_open_characters()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var uid := _cell_uid_at(event.position)
			if uid != "":
				# Do not take the press: the scroll container may still scroll.
				# The drag starts only once the pointer moves without scrolling.
				_press_active = true
				_press_uid = uid
				_press_pos = event.position
				_press_scroll = _scroll.scroll_vertical if _scroll != null else 0
		else:
			_press_active = false
		return
	if event is InputEventMouseMotion and _press_active and _drag_uid == "":
		var scrolled: bool = _scroll != null and _scroll.scroll_vertical != _press_scroll
		if scrolled:
			_press_active = false
			return
		if event.position.distance_to(_press_pos) > 14.0:
			_drag_begin(_press_uid, _press_pos)
			if _drag_uid != "":
				_drag_move(event.position)
				get_viewport().set_input_as_handled()
			else:
				_press_active = false


func _cell_uid_at(pos: Vector2) -> String:
	for entry in _inv_cells:
		var cell: Control = entry.get("cell")
		if is_instance_valid(cell) and cell.is_visible_in_tree() and cell.get_global_rect().has_point(pos):
			return String(entry.get("uid", ""))
	return ""


func _slot_at(pos: Vector2) -> String:
	for slot in _slot_cards.keys():
		var card: Control = _slot_cards[slot]["root"]
		if is_instance_valid(card) and card.get_global_rect().has_point(pos):
			return String(slot)
	return ""


func _drag_begin(uid: String, pos: Vector2) -> void:
	var item := Game.item_by_uid(uid)
	if item.is_empty():
		return
	if EquipmentData.is_signature(item) and EquipmentData.item_character(item) != Game.selected_character:
		_show_message("다른 친구 전용 장비입니다.", UIKit.CORAL)
		return
	_drag_uid = uid
	_drag_start = pos
	_drag_moved = 0.0
	_drag_hover_slot = ""
	_drag_ghost.texture = load(EquipmentData.item_icon(item))
	_drag_ghost.size = Vector2(64, 64)
	_drag_ghost.position = pos - Vector2(32, 32)
	_drag_ghost.visible = true


func _drag_move(pos: Vector2) -> void:
	_drag_moved = maxf(_drag_moved, pos.distance_to(_drag_start))
	_drag_ghost.position = pos - _drag_ghost.size * 0.5
	var slot := _slot_at(pos)
	if slot != _drag_hover_slot:
		if _drag_hover_slot != "":
			_on_slot_hover(_drag_hover_slot, false)
		_drag_hover_slot = slot
		if slot != "":
			_on_slot_hover(slot, true)


func _drag_release(pos: Vector2) -> void:
	var uid := _drag_uid
	var moved := _drag_moved
	_drag_uid = ""
	_drag_ghost.visible = false
	if _drag_hover_slot != "":
		_on_slot_hover(_drag_hover_slot, false)
		_drag_hover_slot = ""
	if moved < 12.0:
		_select_item(uid)
		return
	var item := Game.item_by_uid(uid)
	if item.is_empty():
		_refresh_all()
		return
	var slot := _slot_at(pos)
	var target := ""
	if _paper_frame != null and _paper_frame.get_global_rect().has_point(pos):
		target = ""
	elif slot != "":
		var item_slot := String(item.get("slot", ""))
		if item_slot == "weapon" and slot in EquipmentData.WEAPON_SLOTS:
			target = slot
		elif item_slot == "ring" and slot in EquipmentData.RING_SLOTS:
			target = slot
		elif item_slot == slot:
			target = slot
		else:
			_show_message("이 슬롯에는 장착할 수 없습니다.", UIKit.CORAL)
			_refresh_all()
			return
	else:
		_show_message("슬롯 위에 놓아주세요.", UIKit.MUTED)
		_refresh_all()
		return
	var result := Game.equip_item(uid, target)
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.CORAL)
	_refresh_all()


func _on_best_pressed() -> void:
	var result := Game.auto_equip_best()
	Audio.play_click()
	_show_message(String(result.get("message", "")), UIKit.MINT if bool(result.get("ok", false)) else UIKit.MUTED)
	_confirm_dismantle_uid = ""
	_refresh_all()


func _open_characters() -> void:
	Audio.play_click()
	Game.go_characters("equipment")


func _go_back() -> void:
	Audio.play_click()
	Game.close_equipment()


func _capture_bulk() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	_open_bulk_modal()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await _save_capture("gear_bulk")


func _capture_loadout() -> void:
	await get_tree().create_timer(0.7, true, false, true).timeout
	_open_loadout_modal()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await _save_capture("gear_loadout")


func _save_capture(shot: String) -> void:
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	if _portrait:
		shot += "_portrait"
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "equipment" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _capture_detail() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	# Prefer an unequipped item so the capture shows the equip comparison.
	var best := {}
	var best_power := -1.0
	for entry in Game.inventory:
		if not (entry is Dictionary):
			continue
		if Game.is_item_equipped(String(entry.get("uid", ""))):
			continue
		var power := EquipmentData.item_power(entry)
		if power > best_power:
			best = entry
			best_power = power
	if best.is_empty():
		best = Game.equipped_item("main")
	if not best.is_empty():
		_select_item(String(best.get("uid", "")))
	await get_tree().create_timer(0.4, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	var shot := "equipment_detail" + ("_portrait" if _portrait else "")
	img.save_png(dir + "/" + shot + ".png")
	print("CAPTURED: ", dir + "/" + shot + ".png")
	get_tree().quit()


func _send_button(pos: Vector2, pressed: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = pressed
	e.position = pos
	e.global_position = pos
	get_viewport().push_input(e, true)


func _send_motion(pos: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	get_viewport().push_input(e, true)


func _test_drag() -> void:
	await get_tree().create_timer(0.5, true, false, true).timeout
	var helmet := Game.add_item(EquipmentData.make_item("helmet", "legendary", 3), false)
	var uid := String(helmet.get("uid", ""))
	_refresh_all()
	await get_tree().process_frame
	var errors: Array = []
	var from := Vector2.ZERO
	var found := false
	for entry in _inv_cells:
		if String(entry.get("uid", "")) == uid:
			var cell: Control = entry["cell"]
			from = cell.get_global_rect().get_center()
			found = true
			break
	if not found:
		errors.append("helmet cell not found")
	else:
		var slot_card: Control = _slot_cards["helmet"]["root"]
		var to := slot_card.get_global_rect().get_center()
		_send_button(from, true)
		await get_tree().process_frame
		_send_motion((from + to) * 0.5)
		_send_motion(to)
		await get_tree().process_frame
		_send_button(to, false)
		await get_tree().process_frame
		if String(Game.equipped.get("helmet", "")) != uid:
			errors.append("drag equip failed: %s" % String(Game.equipped.get("helmet", "")))
	var power_before := Game.equipment_power()
	var result := Game.auto_equip_best()
	var power_after := Game.equipment_power()
	if power_after < power_before:
		errors.append("best gear lowered power %d -> %d" % [power_before, power_after])
	print("DRAG TEST power %d -> %d changes=%d errors=%s" % [
		power_before, power_after, int(result.get("changes", 0)), errors,
	])
	if errors.is_empty():
		print("DRAG TEST OK")
		get_tree().quit()
	else:
		push_error("DRAG TEST FAILED: %s" % str(errors))
		get_tree().quit(1)


func _test_gear_qol() -> void:
	await get_tree().create_timer(0.4, true, false, true).timeout
	var errors: Array = []
	var old_inv: Array = Game.inventory.duplicate(true)
	var old_eq: Dictionary = Game.equipped.duplicate(true)
	var old_loadouts: Array = Game.loadouts.duplicate(true)
	var old_shards := Game.shards
	var first := Game.add_item(EquipmentData.make_item("helmet", "common", 1), false)
	var second := Game.add_item(EquipmentData.make_item("helmet", "common", 1), false)
	var third := Game.add_item(EquipmentData.make_item("helmet", "common", 1), false)
	var first_uid := String(first.get("uid", ""))
	Game.toggle_item_lock(first_uid)
	if not Game.item_locked(first_uid):
		errors.append("lock did not stick")
	var blocked := Game.dismantle_item(first_uid)
	if blocked.get("ok", false):
		errors.append("locked item was dismantled")
	var bulk := Game.bulk_dismantle(["common", "rare"])
	if int(bulk.get("count", 0)) < 1:
		errors.append("bulk dismantle removed nothing")
	if not Game.item_locked(first_uid):
		errors.append("bulk dismantle removed a locked item")
	if not Game.item_by_uid(String(second.get("uid", ""))).is_empty():
		errors.append("bulk dismantle kept an unlocked item")
	Game.toggle_item_lock(first_uid)
	var removed := Game.dismantle_item(first_uid)
	if not removed.get("ok", false):
		errors.append("unlocked item could not be dismantled")
	var saved := Game.save_loadout(2)
	if not saved.get("ok", false):
		errors.append("loadout save failed")
	var saved_slots: Dictionary = Game.loadouts[2].get("slots", {})
	Game.equipped = {}
	var applied := Game.apply_loadout(2)
	if not applied.get("ok", false) or int(applied.get("count", 0)) < 1:
		errors.append("loadout apply failed")
	if Game.equipped.size() < saved_slots.size():
		errors.append("loadout slots incomplete")
	Game.inventory = old_inv
	Game.equipped = old_eq
	Game.loadouts = old_loadouts
	Game.shards = old_shards
	Game.save_settings()
	if errors.is_empty():
		print("GEAR QOL TEST PASS bulk=%d loadout=%d" % [
			int(bulk.get("count", 0)), int(applied.get("count", 0)),
		])
		print("TEST PASS")
	else:
		print("GEAR QOL TEST FAIL")
		for e in errors:
			print("  ", e)
		print("TEST FAIL")
	get_tree().quit()


func _test_equipment() -> void:
	await get_tree().create_timer(0.5, true, false, true).timeout
	Game.shards = maxi(Game.shards, 500)
	var errors: Array = []
	if Game.equipped.size() < 11:
		errors.append("starter slots equipped=%d" % Game.equipped.size())
	if Game.inventory.size() < 11:
		errors.append("starter inventory=%d" % Game.inventory.size())
	if Game.shards < 0:
		errors.append("negative shards")

	var item := Game.add_item(EquipmentData.make_item("weapon", "epic", 1, "pulse"), false)
	var equipped := Game.equip_item(String(item.get("uid", "")), "secondary")
	if not bool(equipped.get("ok", false)):
		errors.append("equip failed: %s" % String(equipped.get("message", "")))
	var other_pulse := Game.add_item(EquipmentData.make_item("weapon", "rare", 1, "pulse"), false)
	var duplicate := Game.equip_item(String(other_pulse.get("uid", "")), "main")
	if bool(duplicate.get("ok", false)):
		errors.append("duplicate weapon type was equipped")

	var shards_before := Game.shards
	var enhanced := Game.enhance_item(String(item.get("uid", "")))
	if not bool(enhanced.get("ok", false)):
		errors.append("enhance failed: %s" % String(enhanced.get("message", "")))
	if int(item.get("level", 1)) != 2:
		errors.append("enhance level=%d" % int(item.get("level", 1)))
	if Game.shards >= shards_before:
		errors.append("enhance did not spend shards")

	Game.save_settings()
	Game.load_record()
	var reloaded := Game.item_by_uid(String(item.get("uid", "")))
	if reloaded.is_empty():
		errors.append("item missing after reload")
	elif int(reloaded.get("level", 0)) != 2:
		errors.append("level not saved after reload")
	if String(Game.equipped.get("secondary", "")) != String(item.get("uid", "")):
		errors.append("equipped slot not saved after reload")

	var bonuses := Game.equipment_bonuses()
	if float(bonuses.get("damage_pct", 0.0)) <= 0.0:
		errors.append("gear damage bonus missing")
	var level5 := EquipmentData.make_item("weapon", "epic", 5, "pulse")
	if EquipmentData.starting_weapon_level(level5) != 2:
		errors.append("starting weapon level math wrong")

	var ui_helmet := Game.add_item(EquipmentData.make_item("helmet", "epic", 1), false)
	var ui_uid := String(ui_helmet.get("uid", ""))
	_select_item(ui_uid)
	_on_target_pressed(ui_uid, "helmet", false)
	if String(Game.equipped.get("helmet", "")) != ui_uid:
		errors.append("UI equip did not update helmet slot")
	_enhance_selected()
	if int(Game.item_by_uid(ui_uid).get("level", 1)) != 2:
		errors.append("UI enhance did not raise level")
	_on_target_pressed(ui_uid, "helmet", true)
	if String(Game.equipped.get("helmet", "")) == ui_uid:
		errors.append("UI unequip failed")
	_request_dismantle()
	_request_dismantle()
	if not Game.item_by_uid(ui_uid).is_empty():
		errors.append("UI dismantle did not remove item")

	if errors.is_empty():
		print("EQUIPMENT TEST OK inventory=", Game.inventory.size(),
			" equipped=", Game.equipped.size(), " shards=", Game.shards,
			" bonuses=", bonuses, " starting_lv5=", EquipmentData.starting_weapon_level(level5))
	else:
		for error in errors:
			push_error("EQUIPMENT TEST: " + String(error))
		print("EQUIPMENT TEST FAILED: ", errors)
	get_tree().quit()
