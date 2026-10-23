extends WeaponBase

## Evolved Meteor Fall: a shower of violet meteors that drags enemies toward
## each impact before detonating and leaving a short burn.
## Requires Meteor Fall 6 + Magnet Coil 3.

const COLOR := Color(0.86, 0.58, 1.0)
const GOLD := Color(1.0, 0.86, 0.5)


func weapon_id() -> String:
	return "galaxy_meteor"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var center = player.manager.nearest(origin(), 700.0)
	if center == null:
		timer = 0.22
		return
	var targets: Array = [center.global_position]
	for e in player.manager.query_circle(center.global_position, 210.0):
		if targets.size() >= int(data["strikes"]):
			break
		if e == center or e.dead:
			continue
		targets.append(e.global_position)
	while targets.size() < int(data["strikes"]):
		targets.append(center.global_position + Vector2(
			randf_range(-90, 90), randf_range(-70, 70)))
	for i in targets.size():
		_schedule(targets[i], float(i) * 0.07)
	Audio.play("pulse", 0.6, -6.0)
	FX.screen_shock(0.22, 0.008, 0.12, COLOR)
	timer = cooldown()


func _schedule(p: Vector2, delay: float) -> void:
	FX.rune(p, COLOR, 86.0, 0.4, 0.6)
	FX.ring(p, COLOR, 58.0, 0.35, "halo")
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = 0.36 + delay
	add_child(t)
	t.timeout.connect(_strike.bind(p))
	t.start()


func _strike(p: Vector2) -> void:
	if not is_inside_tree() or player == null or not is_instance_valid(player):
		return
	# Magnet theme: the impact drags the pack inward before it lands.
	for e in player.manager.query_circle(p, float(data["pull_radius"])):
		if e.dead or e.boss:
			continue
		e.global_position = e.global_position.move_toward(p, 90.0)
	var radius := float(data["radius"])
	var damage := float(data["damage"])
	FX.laser_fx(p + Vector2(0, -520), p, GOLD, 26.0)
	FX.explosion(p, COLOR, 1.0)
	FX.ring(p, COLOR, radius, 0.45)
	FX.ring(p, GOLD, radius * 0.7, 0.35, "halo")
	FX.particles(p, "star", COLOR, 18, 0.55, 60, 260, 0.34, 180,
		Vector2(0, 60), true, 320)
	FX.particles(p, "smoke", Color(0.7, 0.35, 1.0), 6, 0.7, 20, 80, 0.5, 180,
		Vector2(0, -20), true, 140)
	FX.flash(Color(0.72, 0.45, 1.0), 0.05, 0.16)
	FX.shake(5.0, 0.25)
	player.manager.damage_circle(p, radius, damage, 210.0, player)
	Audio.play("pulse", randf_range(0.7, 0.9), -4.0)
	var burn := float(data.get("burn_damage", 0.0))
	if burn > 0.0:
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 0.38
		add_child(t)
		t.timeout.connect(_burn.bind(p, radius, burn))
		t.start()


func _burn(p: Vector2, radius: float, burn: float) -> void:
	if not is_inside_tree() or player == null or not is_instance_valid(player):
		return
	player.manager.damage_circle(p, radius * 0.9, burn, 40.0, player)
	FX.ring(p, Color(0.9, 0.42, 1.0), radius * 0.7, 0.35)
	FX.particles(p, "smoke2", Color(0.85, 0.45, 1.0), 10, 0.6, 20, 80, 0.4, 180,
		Vector2(0, -26), true, 140)
