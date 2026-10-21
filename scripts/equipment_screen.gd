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
var _detail_name: Label
var _detail_type: Label
var _detail_stats: Label
var _detail_weapon: Label
var _action_row: HBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	Engine.time_scale = 1.0
	_args = OS.get_cmdline_user_args()
	Audio.set_music_volume(-18.0, 1.0)
	Audio.set_music_pitch(1.0)
	_build()
	UIFit.wrap_menu(self)
	_refresh_all()
	if "--capture-equipment" in _args:
		_capture()
	if "--capture-equipment-detail" in _args:
		_capture_detail()
	if "--test-equipment" in _args:
		_test_equipment.call_deferred()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/ui/title_bg.png")
	bg.position = Vector2(-26, -14)
	bg.size = Vector2(1332, 748)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
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
	over.position = Vector2(56, 26)
	add_child(over)
	var title := UIKit.label("장비 & 인벤토리", 46, UIKit.GOLD, 7)
	title.position = Vector2(52, 42)
	add_child(title)
	var sub := UIKit.label("장비를 장착하고 달빛 조각으로 강화하세요. 다음 밤이 더 길어집니다.", 16, UIKit.CREAM)
	sub.position = Vector2(56, 98)
	add_child(sub)

	var back := UIKit.button("← 돌아가기", Vector2(164, 42))
	back.position = Vector2(1074, 30)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_go_back)
	add_child(back)

	var shard_panel := UIKit.panel(Color(0.06, 0.09, 0.13, 0.96), UIKit.GOLD.darkened(0.45), 1)
	UIKit.place(shard_panel, 916, 84, 308, 40)
	add_child(shard_panel)
	var shard_icon := UIKit.icon("res://assets/art/ui/icon_moon.png", 20)
	UIKit.place(shard_icon, 12, 10, 20, 20)
	shard_panel.add_child(shard_icon)
	_shards_label = UIKit.label("", 16, UIKit.GOLD)
	UIKit.place(_shards_label, 38, 8, 258, 24)
	_shards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	shard_panel.add_child(_shards_label)

	var header_line := ColorRect.new()
	header_line.color = Color(0.85, 0.68, 0.35, 0.28)
	header_line.position = Vector2(36, 126)
	header_line.size = Vector2(1208, 1)
	header_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header_line)

	_build_equipment_panel()
	_build_inventory_panel()

	_message = UIKit.label("", 14, UIKit.MINT)
	_message.position = Vector2(36, 696)
	_message.size = Vector2(1208, 20)
	_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_message)


func _build_equipment_panel() -> void:
	var panel := UIKit.panel(Color(0.045, 0.07, 0.105, 0.95), UIKit.BORDER, 2)
	panel.position = PAPER_PANEL_POS
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
	_paper_hint = UIKit.label("장비를 클릭해 관리", 10, UIKit.MUTED)
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
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(card)

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
	panel.position = INV_PANEL_POS
	panel.size = INV_PANEL_SIZE
	add_child(panel)

	var title := UIKit.label("인벤토리", 20, UIKit.GOLD, 4)
	title.position = Vector2(16, 8)
	panel.add_child(title)
	_inventory_count = UIKit.label("", 11, UIKit.MUTED)
	_inventory_count.position = Vector2(340, 11)
	_inventory_count.size = Vector2(164, 20)
	_inventory_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_inventory_count)

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
	_scroll.position = Vector2(20, 74)
	_scroll.size = Vector2(448, 274)
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

	_detail_icon = UIKit.icon("res://assets/art/ui/icon_equip_chest.png", 40)
	UIKit.place(_detail_icon, 8, 8, 40, 40)
	_detail_panel.add_child(_detail_icon)

	_detail_name = UIKit.label("", 17, UIKit.CREAM, 3)
	UIKit.place(_detail_name, 56, 3, 420, 24)
	_detail_panel.add_child(_detail_name)
	_detail_type = UIKit.label("", 10, UIKit.MUTED)
	UIKit.place(_detail_type, 56, 26, 420, 16)
	_detail_panel.add_child(_detail_type)
	_detail_stats = UIKit.label("", 11, UIKit.CREAM)
	UIKit.place(_detail_stats, 56, 43, 420, 34)
	_detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_stats.add_theme_constant_override("line_spacing", 1)
	_detail_panel.add_child(_detail_stats)
	_detail_weapon = UIKit.label("", 10, UIKit.GOLD)
	UIKit.place(_detail_weapon, 56, 79, 420, 15)
	_detail_panel.add_child(_detail_weapon)

	_action_row = HBoxContainer.new()
	_action_row.position = Vector2(8, 116)
	_action_row.size = Vector2(472, 32)
	_action_row.add_theme_constant_override("separation", 6)
	_detail_panel.add_child(_action_row)


func _refresh_all() -> void:
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
		var selected := false
		if item.is_empty():
			icon.texture = load(_empty_slot_icon(slot))
			icon.modulate = Color(1, 1, 1, 0.22)
			level_badge.visible = false
			slot_label.add_theme_color_override("font_color", Color(0.46, 0.53, 0.6))
			card.add_theme_stylebox_override("panel",
				UIKit.style(Color(0.035, 0.052, 0.078, 0.94), UIKit.BORDER, 2, 0))
			card.tooltip_text = "%s 슬롯 · 비어 있음" % String(EquipmentData.SLOT_LABELS.get(slot, slot))
		else:
			var accent := EquipmentData.display_color(item)
			var rarity_accent := EquipmentData.rarity_color(String(item.get("rarity", "common")))
			selected = String(item.get("uid", "")) == _selected_uid
			icon.texture = load(EquipmentData.item_icon(item))
			icon.modulate = Color.WHITE
			level_badge.visible = true
			level_badge.add_theme_stylebox_override("panel",
				UIKit.style(Color(0.02, 0.032, 0.052, 0.96), rarity_accent.darkened(0.25), 1, 0))
			level_label.text = "Lv.%d" % int(item.get("level", 1))
			level_label.add_theme_color_override("font_color", rarity_accent)
			slot_label.add_theme_color_override("font_color", UIKit.GOLD if selected else UIKit.MUTED)
			card.add_theme_stylebox_override("panel", UIKit.style(
				Color(0.09, 0.13, 0.18, 0.98) if selected else Color(0.06, 0.095, 0.14, 0.96),
				UIKit.GOLD if selected else accent.darkened(0.2), 3 if selected else 2, 0))
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
				_paper_hint.text = "장비를 클릭해 관리"
		else:
			_paper_hint.text = "장비를 클릭해 관리 · %d/11" % equipped_count


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
		_inv_grid.add_child(_make_inventory_cell(item))
	var filled := maxi(24, items.size())
	for i in range(items.size(), filled):
		_inv_grid.add_child(_make_empty_cell())


func _make_inventory_cell(item: Dictionary) -> Panel:
	var rarity_id := String(item.get("rarity", "common"))
	var accent := EquipmentData.display_color(item)
	var rarity_accent := EquipmentData.rarity_color(rarity_id)
	var uid := String(item.get("uid", ""))
	var selected := uid == _selected_uid
	var can_use := not EquipmentData.is_signature(item) or EquipmentData.item_character(item) == Game.selected_character
	var cell := UIKit.panel(
		Color(0.09, 0.13, 0.18, 0.98) if selected else Color(0.055, 0.082, 0.115, 0.96),
		UIKit.GOLD if selected else accent.darkened(0.2), 2)
	cell.custom_minimum_size = Vector2(INV_CELL, INV_CELL)
	cell.mouse_filter = Control.MOUSE_FILTER_STOP
	cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var icon := UIKit.icon(EquipmentData.item_icon(item), 42)
	UIKit.place(icon, 11, 7, 42, 42)
	icon.modulate = Color(1, 1, 1, 0.38) if not can_use else Color.WHITE
	cell.add_child(icon)

	var level_badge := UIKit.panel(Color(0.02, 0.032, 0.052, 0.96), rarity_accent.darkened(0.25), 1)
	UIKit.place(level_badge, 32, 47, 30, 15)
	level_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(level_badge)
	var level_label := UIKit.label("Lv.%d" % int(item.get("level", 1)), 8, rarity_accent)
	UIKit.place(level_label, 0, 1, 30, 12)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_badge.add_child(level_label)

	if Game.is_item_equipped(uid):
		var dot := ColorRect.new()
		dot.color = UIKit.GOLD
		dot.position = Vector2(54, 4)
		dot.size = Vector2(6, 6)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(dot)

	var affinity := EquipmentData.affinity_label(item)
	var tooltip := "%s\n%s · %s · Lv.%d\n%s" % [
		EquipmentData.item_name(item),
		EquipmentData.type_label(item),
		EquipmentData.rarity_name(rarity_id),
		int(item.get("level", 1)),
		"  ·  ".join(EquipmentData.stat_lines(item)),
	]
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
	_detail_stats.text = "  ·  ".join(EquipmentData.stat_lines(item))
	if item_slot == "weapon":
		_detail_weapon.text = "시작 무기 Lv.%d · 강화로 시작 레벨 상승" % EquipmentData.starting_weapon_level(item)
	elif affinity != "":
		_detail_weapon.text = "%s만 사용할 수 있는 전용 장비입니다." % CharacterData.display_name(EquipmentData.item_character(item))
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
	dismantle.disabled = equipped_slot != "" or EquipmentData.is_signature(item)
	dismantle.pressed.connect(_request_dismantle)
	_action_row.add_child(dismantle)
	_update_paper_profile()


func _action_button(text: String, width: float) -> Button:
	var b := UIKit.button(text, Vector2(width, 30))
	b.add_theme_font_size_override("font_size", 11)
	return b


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


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_go_back()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_open_characters()
			get_viewport().set_input_as_handled()


func _open_characters() -> void:
	Audio.play_click()
	Game.go_characters("equipment")


func _go_back() -> void:
	Audio.play_click()
	Game.close_equipment()


func _capture() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/equipment.png")
	print("CAPTURED: ", dir + "/equipment.png")
	get_tree().quit()


func _capture_detail() -> void:
	await get_tree().create_timer(0.8, true, false, true).timeout
	var item := Game.equipped_item("main")
	if not item.is_empty():
		_select_item(String(item.get("uid", "")))
	await get_tree().create_timer(0.4, true, false, true).timeout
	await get_tree().process_frame
	var dir := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(dir)
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/equipment_detail.png")
	print("CAPTURED: ", dir + "/equipment_detail.png")
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
