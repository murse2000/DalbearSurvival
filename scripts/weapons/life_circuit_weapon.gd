extends WeaponBase

## Evolved Nebula Chain: green life-current arcs that heal the bear for every
## link they strike. Requires Nebula Chain 6 + Nano Regen 3.

const COLOR := Color(0.55, 1.0, 0.72)
const BOLT := Color(0.78, 1.0, 0.92)


func weapon_id() -> String:
	return "life_circuit"


func tick(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	var origin_pos := origin()
	var candidates: Array = player.manager.query_circle(origin_pos, 620.0)
	if candidates.is_empty():
		timer = 0.22
		return
	var used := {}
	var arcs := 0
	var healed := 0.0
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
			victims[i].take_damage(roll["damage"], roll["crit"], origin_pos, 85.0)
			player.manager.damage_obstacles_circle(victims[i].global_position, 22.0,
				float(data["damage"]) * falloff * 0.6)
			healed += float(data["heal"])
		FX.chain_lightning(points, COLOR)
		arcs += 1
	if arcs == 0:
		timer = 0.22
		return
	var heal_amount := minf(healed, float(data["max_heal"]))
	if heal_amount > 0.0:
		player.heal(heal_amount, false)
		var p: Vector2 = player.global_position + Vector2(0, -10)
		FX.ring(p, COLOR, 44.0, 0.35, "halo")
		FX.particles(p, "star", BOLT, 6, 0.4, 20, 70, 0.22, 180,
			Vector2(0, -50), true, 180)
	FX.flash(Color(0.4, 1.0, 0.6), 0.05, 0.16)
	FX.screen_shock(0.26, 0.012, 0.18, COLOR)
	FX.shake(3.6, 0.2)
	Audio.play("laser", randf_range(1.05, 1.18), -5.0)
	timer = cooldown()
