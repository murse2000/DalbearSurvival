extends WeaponBase

## Orbiting moon satellites. Every satellite has its own contact cooldown.

var sprites: Array[Node2D] = []
var halo: Sprite2D
var angle := 0.0
var hit_times := {}


func weapon_id() -> String:
	return "satellite"


func _on_setup() -> void:
	_build()


func _on_level_changed() -> void:
	_build()


func _build() -> void:
	for s in sprites:
		if is_instance_valid(s):
			s.queue_free()
	sprites.clear()
	if halo == null:
		halo = Sprite2D.new()
		halo.texture = load("res://assets/particles/small/kenney_circle_05.png")
		halo.modulate = Color(0.55, 1.0, 0.8, 0.06)
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		halo.material = mat
		add_child(halo)
	var count := int(data.get("count", 1))
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
		glow.modulate = Color(0.6, 1.0, 0.8, 0.55)
		var gm := CanvasItemMaterial.new()
		gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = gm
		root.add_child(glow)
		sprites.append(root)
	var r := float(data.get("radius", 48.0))
	halo.scale = Vector2.ONE * (r * 2.0 / 62.0)
	halo.rotation = 0.0


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
		player.manager.damage_obstacles_circle(world, 22.0, float(data["damage"]))
		for enemy in player.manager.query_circle(world, 22.0):
			if enemy.dead:
				continue
			var id: int = enemy.get_instance_id()
			if hit_times.has(id) and now - float(hit_times[id]) < hit_cd:
				continue
			hit_times[id] = now
			var roll: Dictionary = player.roll_damage(float(data["damage"]))
			enemy.take_damage(roll["damage"], roll["crit"], center, 95.0, element())
			FX.slash(enemy.global_position + Vector2(0, -8), a + PI * 0.5,
				Color(0.6, 1.0, 0.82), 0.26)
			Audio.play("hit", randf_range(0.95, 1.15), -8.0)
	if hit_times.size() > 160:
		hit_times.clear()
	halo.rotation -= delta * 1.2
