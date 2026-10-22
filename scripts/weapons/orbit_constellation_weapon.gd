extends WeaponBase

## Evolved Satellite: six satellites plus a periodic chain lightning.
## Requires Satellite 6 + Coolant 3.

var sprites: Array[Node2D] = []
var halo: Sprite2D
var angle := 0.0
var hit_times := {}
var chain_cd := 1.5


func weapon_id() -> String:
	return "orbit_constellation"


func _on_setup() -> void:
	_build()


func _build() -> void:
	for s in sprites:
		if is_instance_valid(s):
			s.queue_free()
	sprites.clear()
	if halo == null:
		halo = Sprite2D.new()
		halo.texture = load("res://assets/particles/small/kenney_circle_05.png")
		halo.modulate = Color(0.55, 1.0, 0.85, 0.12)
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		halo.material = mat
		add_child(halo)
	var count := int(data.get("count", 6))
	var sat_tex := load("res://assets/art/fx/satellite.png")
	var glow_tex := load("res://assets/art/fx/glow_green.png")
	for i in count:
		var root := Node2D.new()
		add_child(root)
		var s := Sprite2D.new()
		s.texture = sat_tex
		s.scale = Vector2.ONE * 1.05
		root.add_child(s)
		var glow := Sprite2D.new()
		glow.texture = glow_tex
		glow.scale = Vector2.ONE * 0.55
		glow.modulate = Color(0.7, 1.0, 0.85, 0.6)
		var gm := CanvasItemMaterial.new()
		gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = gm
		root.add_child(glow)
		sprites.append(root)
	var r := float(data.get("radius", 80.0))
	halo.scale = Vector2.ONE * (r * 2.0 / 62.0)


func tick(delta: float) -> void:
	if sprites.is_empty():
		return
	angle += float(data["spin"]) * delta
	var radius := float(data["radius"])
	var count := sprites.size()
	var now := Time.get_ticks_msec() / 1000.0
	var hit_cd := float(data["hit_cd"])
	for i in count:
		var a := angle + TAU * float(i) / float(count)
		var offset := Vector2(cos(a), sin(a)) * radius
		var node := sprites[i]
		node.position = offset
		node.rotation = a + PI * 0.5
		var center: Vector2 = player.global_position + Vector2(0, -14)
		var world: Vector2 = center + offset
		player.manager.damage_obstacles_circle(world, 23.0, float(data["damage"]))
		for enemy in player.manager.query_circle(world, 23.0):
			if enemy.dead:
				continue
			var id: int = enemy.get_instance_id()
			if hit_times.has(id) and now - float(hit_times[id]) < hit_cd:
				continue
			hit_times[id] = now
			var roll: Dictionary = player.roll_damage(float(data["damage"]))
			enemy.take_damage(roll["damage"], roll["crit"], center, 95.0)
			FX.slash(enemy.global_position + Vector2(0, -8), a + PI * 0.5,
				Color(0.65, 1.0, 0.85), 0.24)
			Audio.play("hit", randf_range(0.95, 1.15), -9.0)
	if hit_times.size() > 200:
		hit_times.clear()
	halo.rotation -= delta * 1.4
	chain_cd -= delta
	if chain_cd <= 0.0:
		_chain()
		chain_cd = float(data["chain_cd"])


func _chain() -> void:
	var origin_pos: Vector2 = player.global_position + Vector2(0, -14)
	var first = player.manager.nearest(origin_pos, 280.0)
	if first == null:
		return
	var chain_points: Array = [origin_pos, first.global_position]
	var visited := {first.get_instance_id(): true}
	var current = first
	var victims: Array = [first]
	for i in int(data["chain_count"]) - 1:
		var next = null
		var best := 1e20
		for e in player.manager.query_circle(current.global_position, float(data["chain_range"])):
			if e.dead or visited.has(e.get_instance_id()):
				continue
			var d: float = current.global_position.distance_squared_to(e.global_position)
			if d < best:
				best = d
				next = e
		if next == null:
			break
		visited[next.get_instance_id()] = true
		chain_points.append(next.global_position)
		victims.append(next)
		current = next
	for e in victims:
		var roll: Dictionary = player.roll_damage(float(data["chain_damage"]))
		e.take_damage(roll["damage"], roll["crit"], origin_pos, 110.0)
		player.manager.damage_obstacles_circle(e.global_position, 22.0,
			float(data["chain_damage"]) * 0.5)
	FX.chain_lightning(chain_points, Color(0.61, 1.0, 0.82))
	Audio.play("laser", 1.1, -10.0)
