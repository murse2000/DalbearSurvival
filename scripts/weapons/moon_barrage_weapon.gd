extends WeaponBase

## Evolved Moon Shot: calls three lunar meteor strikes on the nearest cluster.
## Requires Moon Shot 6 + Energy Core 3.

var _pending := 0


func weapon_id() -> String:
	return "moon_barrage"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var o := origin()
	var center = player.manager.nearest(o, 620.0)
	if center == null:
		timer = 0.25
		return
	var targets: Array = [center.global_position]
	for e in player.manager.query_circle(center.global_position, 190.0):
		if targets.size() >= int(data["strikes"]):
			break
		if e != center:
			targets.append(e.global_position)
	while targets.size() < int(data["strikes"]):
		targets.append(center.global_position + Vector2(randf_range(-70, 70), randf_range(-50, 50)))
	for p in targets:
		FX.rune(p, Color(1.0, 0.86, 0.45), 64.0, 0.38, 0.55)
		FX.ring(p, Color(1.0, 0.86, 0.45), 54.0, 0.34)
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 0.38
		add_child(t)
		t.timeout.connect(_strike.bind(p))
		t.start()
	Audio.play("laser", 0.8, -7.0)
	timer = cooldown()


func _strike(p: Vector2) -> void:
	if not is_inside_tree() or player == null:
		return
	FX.laser_fx(p + Vector2(0, -430), p, Color(1.0, 0.92, 0.62), 38.0)
	FX.explosion(p, Color(1.0, 0.84, 0.42), 0.85)
	player.manager.damage_circle(p, float(data["radius"]), float(data["damage"]), 120.0, player)
	Audio.play("pulse", 0.8, -4.0)
