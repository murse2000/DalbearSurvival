extends WeaponBase

## Nebula Chain: lightning leaps through packs, with multiple branches at
## higher levels. Every link gets a jagged arc and a small impact flare.

const CHAIN_COLOR := Color(0.55, 0.94, 1.0)


func weapon_id() -> String:
	return "chain"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var origin_pos := origin()
	var candidates: Array = player.manager.query_circle(origin_pos, 600.0)
	if candidates.is_empty():
		timer = 0.22
		return
	var used := {}
	var arcs := 0
	for c in int(data["chains"]):
		var first = null
		var best := 1e20
		for e in candidates:
			if e.dead or used.has(e.get_instance_id()):
				continue
			var d: float = origin_pos.distance_squared_to(e.global_position)
			if d < best:
				best = d
				first = e
		if first == null:
			break
		used[first.get_instance_id()] = true
		var points: Array = [origin_pos, first.global_position]
		var victims: Array = [first]
		var current = first
		for j in int(data["jumps"]) - 1:
			var next = null
			var nearest := 1e20
			for e in player.manager.query_circle(current.global_position, float(data["range"])):
				if e.dead or used.has(e.get_instance_id()):
					continue
				var d: float = current.global_position.distance_squared_to(e.global_position)
				if d < nearest:
					nearest = d
					next = e
			if next == null:
				break
			used[next.get_instance_id()] = true
			points.append(next.global_position)
			victims.append(next)
			current = next
		for i in victims.size():
			var falloff := maxf(0.58, 1.0 - float(i) * 0.075)
			var roll: Dictionary = player.roll_damage(float(data["damage"]) * falloff)
			victims[i].take_damage(roll["damage"], roll["crit"], origin_pos, 85.0, element())
			player.manager.damage_obstacles_circle(victims[i].global_position, 22.0,
				float(data["damage"]) * falloff * 0.6)
		FX.chain_lightning(points, CHAIN_COLOR)
		arcs += 1
	if arcs == 0:
		timer = 0.22
		return
	FX.flash(Color(0.45, 0.8, 1.0), 0.06, 0.18)
	FX.screen_shock(0.28, 0.014, 0.20, CHAIN_COLOR)
	FX.shake(3.8, 0.2)
	if int(data["chains"]) >= 3:
		FX.speed_lines(0.22, CHAIN_COLOR)
	Audio.play("laser", randf_range(1.05, 1.18), -5.0)
	timer = cooldown()
