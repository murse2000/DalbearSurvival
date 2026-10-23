extends WeaponBase

## Evolved Eclipse Singularity: the eclipse well now travels toward the pack,
## dragging enemies with it before collapsing. Requires Singularity 6 + Jet Boots 3.

const COLOR := Color(0.74, 0.44, 1.0)

var active := false
var well_pos := Vector2.ZERO
var life := 0.0
var tick_cd := 0.0
var spin := 0.0
var well: Node2D
var well_glow: Sprite2D
var well_ring: Sprite2D


func weapon_id() -> String:
	return "singularity_dash"


func tick(delta: float) -> void:
	if active:
		life -= delta
		spin += delta * 6.0
		var target = player.manager.nearest(well_pos, 700.0)
		if target != null:
			well_pos = well_pos.move_toward(target.global_position,
				float(data["travel_speed"]) * delta)
		for e in player.manager.query_circle(well_pos, float(data["pull_radius"])):
			if e.dead or e.boss:
				continue
			e.global_position = e.global_position.move_toward(well_pos,
				float(data["pull_speed"]) * delta)
		tick_cd -= delta
		if tick_cd <= 0.0:
			tick_cd = float(data["tick_interval"])
			player.manager.damage_circle(well_pos, float(data["pull_radius"]) * 0.65,
				float(data["tick_damage"]), 30.0, player, element())
		if well != null and is_instance_valid(well):
			well.position = well_pos
			well.rotation = spin
			well.scale = Vector2.ONE * (1.0 + (float(data["pull_time"]) - maxf(0.0, life)) * 0.5)
			if well_glow != null and is_instance_valid(well_glow):
				well_glow.modulate.a = 0.35 + absf(sin(spin * 1.7)) * 0.25
			if well_ring != null and is_instance_valid(well_ring):
				well_ring.rotation = -spin * 0.8
		if life <= 0.0:
			_finish()
		return
	timer -= delta
	if timer <= 0.0:
		_cast()


func _cast() -> void:
	var target = player.manager.nearest(origin(), 620.0)
	if target == null:
		timer = 0.22
		return
	well_pos = origin()
	active = true
	life = float(data["pull_time"])
	tick_cd = 0.0
	spin = 0.0
	_spawn_well()
	FX.rune(well_pos, COLOR, 120.0, 0.7, 0.6)
	FX.ring(well_pos, COLOR, 100.0, 0.6, "halo")
	FX.screen_shock(0.2, 0.008, 0.12, COLOR)
	FX.shake(3.0, 0.25)
	Audio.play("pulse", 0.55, -4.0)


func _spawn_well() -> void:
	well = Node2D.new()
	well.position = well_pos
	well.z_index = 6
	FX.fx_root.add_child(well)
	well_glow = Sprite2D.new()
	well_glow.texture = load("res://assets/art/fx/glow_green.png")
	well_glow.modulate = Color(0.6, 0.28, 0.95, 0.5)
	well_glow.scale = Vector2.ONE * 1.35
	var gm := CanvasItemMaterial.new()
	gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	well_glow.material = gm
	well.add_child(well_glow)
	well_ring = Sprite2D.new()
	well_ring.texture = load("res://assets/particles/small/kenney_circle_05.png")
	well_ring.modulate = Color(0.82, 0.55, 1.0, 0.7)
	well_ring.scale = Vector2.ONE * 0.9
	well.add_child(well_ring)
	var core := Sprite2D.new()
	core.texture = load("res://assets/particles/small/kenney_circle_03.png")
	core.modulate = Color(0.035, 0.012, 0.07, 0.96)
	core.scale = Vector2.ONE * 0.62
	well.add_child(core)


func _finish() -> void:
	active = false
	player.manager.damage_circle(well_pos, float(data["radius"]), float(data["damage"]),
		320.0, player, element())
	FX.explosion(well_pos, COLOR, 1.35)
	FX.ring(well_pos, Color.WHITE, float(data["radius"]) * 1.2, 0.55, "halo")
	FX.flash(Color(0.74, 0.44, 1.0), 0.17, 0.34)
	FX.screen_shock(0.55, 0.035, 0.5, COLOR)
	FX.shake(8.0, 0.45)
	Audio.play("pulse", 0.5, -1.0)
	if well != null and is_instance_valid(well):
		well.queue_free()
	well = null
	well_glow = null
	well_ring = null
	timer = cooldown()


func _exit_tree() -> void:
	if well != null and is_instance_valid(well):
		well.queue_free()
