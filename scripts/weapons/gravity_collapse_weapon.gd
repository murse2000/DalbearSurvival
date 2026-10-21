extends WeaponBase

## Evolved Pulse: a gravity well pulls enemies in, then collapses.
## Requires Pulse 6 + Alloy Skin 3.

var pulling := false
var pull_timer := 0.0
var pull_pos := Vector2.ZERO
var well: Sprite2D
var well_rotation := 0.0


func weapon_id() -> String:
	return "gravity_collapse"


func tick(delta: float) -> void:
	if pulling:
		pull_timer -= delta
		var enemies: Array = player.manager.query_circle(pull_pos, float(data["pull_radius"]))
		for e in enemies:
			if e.dead or e.boss:
				continue
			e.global_position = e.global_position.move_toward(pull_pos, float(data["pull_speed"]) * delta)
		if well != null and is_instance_valid(well):
			well_rotation += delta * 4.0
			well.rotation = well_rotation
			well.scale = Vector2.ONE * (1.6 + (0.8 - maxf(0.0, pull_timer)) * 2.2)
			well.modulate.a = 0.35 + (0.8 - maxf(0.0, pull_timer)) * 0.5
		if pull_timer <= 0.0:
			_finish()
		return
	timer -= delta
	if timer <= 0.0:
		_cast()


func _cast() -> void:
	var target = player.manager.nearest(player.global_position + Vector2(0, -10), 520.0)
	if target == null:
		timer = 0.25
		return
	pull_pos = target.global_position
	pulling = true
	pull_timer = float(data["pull_time"])
	well_rotation = 0.0
	FX.rune(pull_pos, Color(0.78, 0.48, 1.0), 165.0, 0.9, 0.6)
	FX.ring(pull_pos, Color(0.78, 0.48, 1.0), 150.0, 0.9, "halo")
	FX.particles(pull_pos, "star", Color(0.72, 0.45, 1.0), 24, 0.8, 30, 120, 0.32, 180,
		Vector2.ZERO, true, 200)
	well = Sprite2D.new()
	well.texture = load("res://assets/art/fx/glow_green.png")
	well.position = pull_pos
	well.scale = Vector2.ONE * 1.6
	well.modulate = Color(0.65, 0.35, 1.0, 0.4)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	well.material = mat
	FX.fx_root.add_child(well)
	Audio.play("pulse", 0.65, -5.0)
	FX.shake(2.5, 0.3)


func _finish() -> void:
	pulling = false
	player.manager.damage_circle(pull_pos, float(data["radius"]), float(data["damage"]),
		float(data["knock"]), player)
	FX.explosion(pull_pos, Color(0.72, 0.45, 1.0), 1.25)
	FX.flash(Color(0.7, 0.4, 1.0), 0.18, 0.4)
	FX.shake(8.0, 0.5)
	Audio.play("pulse", 0.9, -1.0)
	if well != null and is_instance_valid(well):
		well.queue_free()
	well = null
	timer = cooldown()


func _exit_tree() -> void:
	if well != null and is_instance_valid(well):
		well.queue_free()
