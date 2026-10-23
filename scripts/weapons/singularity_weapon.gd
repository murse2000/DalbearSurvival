extends WeaponBase

## Eclipse Singularity: a small eclipse grabs nearby enemies, then implodes.
## The vortex is intentionally loud: purple grade, shockwave and a collapse flash.

const VOID_COLOR := Color(0.72, 0.42, 1.0)

var pulling := false
var pull_timer := 0.0
var pull_pos := Vector2.ZERO
var well: Node2D
var well_glow: Sprite2D
var well_ring: Sprite2D
var spin := 0.0


func weapon_id() -> String:
	return "singularity"


func tick(delta: float) -> void:
	if pulling:
		pull_timer -= delta
		spin += delta * 5.0
		var enemies: Array = player.manager.query_circle(pull_pos, float(data["pull_radius"]))
		for e in enemies:
			if e.dead or e.boss:
				continue
			e.global_position = e.global_position.move_toward(
				pull_pos, float(data["pull_speed"]) * delta)
		if well != null and is_instance_valid(well):
			well.rotation = spin
			well.scale = Vector2.ONE * (1.15 + (float(data["pull_time"]) - maxf(0.0, pull_timer)) * 0.45)
			if well_glow != null and is_instance_valid(well_glow):
				well_glow.modulate.a = 0.35 + absf(sin(spin * 1.7)) * 0.25
			if well_ring != null and is_instance_valid(well_ring):
				well_ring.rotation = -spin * 0.7
		if pull_timer <= 0.0:
			_finish()
		return
	timer -= delta
	if timer <= 0.0:
		_cast()


func _cast() -> void:
	var target = player.manager.nearest(origin(), 560.0)
	if target == null:
		timer = 0.25
		return
	pull_pos = target.global_position
	pulling = true
	pull_timer = float(data["pull_time"])
	spin = 0.0
	_spawn_well()
	FX.rune(pull_pos, VOID_COLOR, 170.0, 0.9, 0.6)
	FX.ring(pull_pos, VOID_COLOR, 135.0, 0.8, "halo")
	FX.particles(pull_pos, "star", VOID_COLOR, 28, 0.9, 25, 110, 0.32, 180,
		Vector2.ZERO, true, 220)
	FX.grade(Color(0.55, 0.25, 0.9), 0.14, 1.1)
	FX.screen_shock(0.22, 0.008, 0.12, VOID_COLOR)
	FX.shake(3.0, 0.25)
	Audio.play("pulse", 0.55, -4.0)


func _spawn_well() -> void:
	well = Node2D.new()
	well.position = pull_pos
	well.z_index = 6
	FX.fx_root.add_child(well)
	well_glow = Sprite2D.new()
	well_glow.texture = load("res://assets/art/fx/glow_green.png")
	well_glow.modulate = Color(0.55, 0.25, 0.9, 0.5)
	well_glow.scale = Vector2.ONE * 1.35
	var gm := CanvasItemMaterial.new()
	gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	well_glow.material = gm
	well.add_child(well_glow)
	well_ring = Sprite2D.new()
	well_ring.texture = load("res://assets/particles/small/kenney_circle_05.png")
	well_ring.modulate = Color(0.78, 0.5, 1.0, 0.7)
	well_ring.scale = Vector2.ONE * 0.9
	well.add_child(well_ring)
	var core := Sprite2D.new()
	core.texture = load("res://assets/particles/small/kenney_circle_03.png")
	core.modulate = Color(0.035, 0.012, 0.07, 0.96)
	core.scale = Vector2.ONE * 0.62
	well.add_child(core)


func _finish() -> void:
	pulling = false
	var radius := float(data["radius"])
	var damage := float(data["damage"])
	player.manager.damage_circle(pull_pos, radius, damage, 320.0, player, element())
	FX.explosion(pull_pos, VOID_COLOR, 1.35)
	FX.ring(pull_pos, Color.WHITE, radius * 1.25, 0.55, "halo")
	FX.flash(Color(0.72, 0.42, 1.0), 0.17, 0.34)
	FX.screen_shock(0.62, 0.04, 0.55, VOID_COLOR)
	FX.grade(Color(0.65, 0.3, 0.95), 0.2, 1.4)
	FX.shake(9.0, 0.5)
	FX.particles(pull_pos, "star", VOID_COLOR, 36, 0.75, 60, 300, 0.38, 180,
		Vector2(0, -30), true, 400)
	Audio.play("pulse", 0.48, -1.0)
	if well != null and is_instance_valid(well):
		well.queue_free()
	well = null
	well_glow = null
	well_ring = null
	timer = cooldown()


func _exit_tree() -> void:
	if well != null and is_instance_valid(well):
		well.queue_free()
