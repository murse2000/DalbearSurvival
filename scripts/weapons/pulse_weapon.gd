extends WeaponBase

## Moon Pulse: expanding shockwave that damages and knocks back everything
## around the bear.


func weapon_id() -> String:
	return "pulse"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var radius := float(data["radius"])
	if not player.manager.has_enemy_within(player.global_position, radius + 60.0):
		timer = 0.25
		return
	player.manager.damage_circle(
		player.global_position + Vector2(0, -6),
		radius,
		float(data["damage"]),
		float(data["knock"]),
		player
	)
	FX.pulse_fx(player.global_position + Vector2(0, -6), radius, Color(0.58, 0.94, 1.0))
	Audio.play("pulse", 1.0, -3.0)
	timer = cooldown()
