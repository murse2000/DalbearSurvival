extends WeaponBase

## Meteor Fall: calls down burning moon meteors on the nearest pack.
## Each impact has its own warning rune, falling beam and scorched after-burst.

const METEOR_COLOR := Color(1.0, 0.58, 0.25)


func weapon_id() -> String:
	return "meteor"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var o := origin()
	var center = player.manager.nearest(o, 660.0)
	if center == null:
		timer = 0.22
		return
	var targets: Array = [center.global_position]
	for e in player.manager.query_circle(center.global_position, 175.0):
		if targets.size() >= int(data["strikes"]):
			break
		if e == center or e.dead:
			continue
		targets.append(e.global_position)
	while targets.size() < int(data["strikes"]):
		targets.append(center.global_position + Vector2(
			randf_range(-72, 72), randf_range(-58, 58)))
	for i in targets.size():
		_schedule(targets[i], i * 0.08)
	Audio.play("pulse", randf_range(0.62, 0.78), -7.0)
	FX.screen_shock(0.18, 0.006, 0.10, METEOR_COLOR)
	timer = cooldown()


func _schedule(p: Vector2, delay: float) -> void:
	FX.rune(p, METEOR_COLOR, 74.0, 0.38, 0.62)
	FX.ring(p, METEOR_COLOR, 52.0, 0.3, "halo")
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = 0.34 + delay
	add_child(t)
	t.timeout.connect(_strike.bind(p))
	t.start()


func _strike(p: Vector2) -> void:
	if not is_inside_tree() or player == null or not is_instance_valid(player):
		return
	var radius := float(data["radius"])
	var damage := float(data["damage"])
	var gold := Color(1.0, 0.84, 0.45)
	FX.laser_fx(p + Vector2(0, -520), p, gold, 24.0)
	FX.explosion(p, METEOR_COLOR, 0.9)
	FX.ring(p, METEOR_COLOR, radius, 0.45)
	FX.ring(p, gold, radius * 0.72, 0.35, "halo")
	FX.particles(p, "spark", METEOR_COLOR, 16, 0.55, 40, 250, 0.34, 180,
		Vector2(0, -40), true, 320)
	FX.particles(p, "smoke", Color(0.9, 0.35, 0.16), 8, 0.7, 20, 80, 0.5, 180,
		Vector2(0, -18), true, 160)
	FX.flash(Color(1.0, 0.55, 0.22), 0.045, 0.15)
	FX.shake(4.5, 0.22)
	FX.screen_shock(0.24, 0.012, 0.12, METEOR_COLOR)
	player.manager.damage_circle(p, radius, damage, 190.0, player)
	Audio.play("pulse", randf_range(0.72, 0.9), -4.0)
	var burn := float(data.get("burn_damage", 0.0))
	if burn > 0.0:
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 0.34
		add_child(t)
		t.timeout.connect(_burn.bind(p, radius, burn))
		t.start()


func _burn(p: Vector2, radius: float, burn: float) -> void:
	if not is_inside_tree() or player == null or not is_instance_valid(player):
		return
	player.manager.damage_circle(p, radius * 0.9, burn, 35.0, player)
	FX.ring(p, Color(1.0, 0.35, 0.12), radius * 0.72, 0.35)
	FX.particles(p, "smoke2", Color(1.0, 0.42, 0.16), 10, 0.6, 20, 80, 0.4, 180,
		Vector2(0, -26), true, 140)
