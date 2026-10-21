extends WeaponBase

## Moon Shot: auto-targeting bolts, more bolts and pierce per level.


func weapon_id() -> String:
	return "moon_shot"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var o := origin()
	var target = player.manager.nearest(o, 460.0)
	if target == null:
		timer = 0.18
		return
	var dir: Vector2 = (target.global_position - o).normalized()
	var count := int(data["count"])
	for i in count:
		var a := deg_to_rad(8.0) * (float(i) - (count - 1) * 0.5)
		var d := dir.rotated(a)
		player.manager.spawn_player_projectile(
			o + d * 14.0,
			d * float(data["speed"]),
			float(data["damage"]),
			int(data["pierce"]),
			player
		)
	FX.muzzle(o + dir * 24.0, dir.angle(), Color(1.0, 0.86, 0.52))
	Audio.play("shoot", randf_range(0.94, 1.06), -4.0)
	FX.shake(0.8, 0.07)
	timer = cooldown()
