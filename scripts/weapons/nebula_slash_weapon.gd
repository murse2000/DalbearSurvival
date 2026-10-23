extends WeaponBase

## Evolved Laser: three nebula beams at slightly different angles.
## Requires Laser 6 + Lucky Star 3.

const COLORS := [
	Color(0.55, 1.0, 0.9),
	Color(0.72, 0.65, 1.0),
	Color(1.0, 0.82, 0.48),
]


func weapon_id() -> String:
	return "nebula_slash"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var o := origin()
	var target = player.manager.nearest(o, 760.0)
	if target == null:
		timer = 0.2
		return
	var dir: Vector2 = (target.global_position - o).normalized()
	var beams := int(data["beams"])
	var base := dir.angle()
	for i in beams:
		var a := base + deg_to_rad(-8.0 + i * 8.0)
		var d := Vector2.from_angle(a)
		var end := o + d * float(data["length"])
		player.manager.damage_line(o, end, float(data["width"]), float(data["damage"]), player, element())
		FX.laser_fx(o, end, COLORS[i % COLORS.size()], float(data["width"]))
	FX.impact(0.05, 0.025, 0.01)
	FX.shake(4.0, 0.22)
	Audio.play("laser", 0.9, -2.0)
	timer = cooldown()
