extends WeaponBase

## Star Laser: a piercing beam toward the nearest alien.


func weapon_id() -> String:
	return "laser"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var o := origin()
	var target = player.manager.nearest(o, 700.0)
	if target == null:
		timer = 0.2
		return
	var dir: Vector2 = (target.global_position - o).normalized()
	var start := o
	var end := o + dir * float(data["length"])
	player.manager.damage_line(start, end, float(data["width"]), float(data["damage"]), player, element())
	FX.laser_fx(start, end, Color(0.72, 1.0, 0.9), float(data["width"]))
	Audio.play("laser", randf_range(0.96, 1.05), -4.0)
	timer = cooldown()
