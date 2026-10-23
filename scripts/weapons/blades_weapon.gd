extends WeaponBase

## Moonlit Blades: fast crescent blades orbit the bear and periodically release
## a radial moonlight slash. Gold streaks and small hit-slashes sell the speed.

const BLADE_COLOR := Color(1.0, 0.84, 0.46)

var blades: Array[Node2D] = []
var angle := 0.0
var wave_cd := 1.5
var hit_times := {}


func weapon_id() -> String:
	return "blades"


func _on_setup() -> void:
	_build()
	wave_cd = float(data["wave_cd"]) * 0.55


func _on_level_changed() -> void:
	_build()


func _build() -> void:
	for b in blades:
		if is_instance_valid(b):
			b.queue_free()
	blades.clear()
	var slash_tex := load("res://assets/particles/small/kenney_slash_02.png")
	var glow_tex := load("res://assets/art/fx/glow_green.png")
	for i in int(data["count"]):
		var root := Node2D.new()
		add_child(root)
		var glow := Sprite2D.new()
		glow.texture = glow_tex
		glow.modulate = Color(1.0, 0.72, 0.28, 0.32)
		glow.scale = Vector2.ONE * 0.4
		var gm := CanvasItemMaterial.new()
		gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = gm
		root.add_child(glow)
		var blade := Sprite2D.new()
		blade.texture = slash_tex
		blade.modulate = BLADE_COLOR
		blade.scale = Vector2.ONE * 0.78
		var bm := CanvasItemMaterial.new()
		bm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		blade.material = bm
		root.add_child(blade)
		blades.append(root)


func tick(delta: float) -> void:
	if blades.is_empty():
		return
	angle += float(data["spin"]) * delta
	var radius := float(data["radius"])
	var center: Vector2 = player.global_position + Vector2(0, -14)
	var now := Time.get_ticks_msec() / 1000.0
	var hit_cd := float(data["hit_cd"])
	for i in blades.size():
		var a := angle + TAU * float(i) / float(blades.size())
		var offset := Vector2(cos(a), sin(a)) * radius
		var node := blades[i]
		node.position = offset
		node.rotation = a + PI * 0.5
		var world := center + offset
		player.manager.damage_obstacles_circle(world, 25.0, float(data["damage"]))
		for enemy in player.manager.query_circle(world, 25.0):
			if enemy.dead:
				continue
			var id: int = enemy.get_instance_id()
			if hit_times.has(id) and now - float(hit_times[id]) < hit_cd:
				continue
			hit_times[id] = now
			var roll: Dictionary = player.roll_damage(float(data["damage"]))
			enemy.take_damage(roll["damage"], roll["crit"], center, 105.0, element())
			FX.slash(world, a + PI * 0.5, BLADE_COLOR, 0.26)
			Audio.play("hit", randf_range(1.0, 1.16), -10.0)
	if hit_times.size() > 260:
		hit_times.clear()
	wave_cd -= delta
	if wave_cd <= 0.0:
		_slash_wave()
		wave_cd = float(data["wave_cd"])


func _slash_wave() -> void:
	var center: Vector2 = player.global_position + Vector2(0, -14)
	var radius := float(data["radius"]) + 54.0
	player.manager.damage_circle(center, radius, float(data["wave_damage"]), 150.0, player, element())
	for i in 10:
		FX.slash(center, TAU * float(i) / 10.0 + angle * 0.2, BLADE_COLOR, 0.38)
	FX.ring(center, BLADE_COLOR, radius, 0.42, "halo")
	FX.screen_shock(0.22, 0.008, 0.18, BLADE_COLOR)
	FX.flash(Color(1.0, 0.82, 0.4), 0.04, 0.15)
	FX.shake(2.8, 0.18)
	Audio.play("laser", randf_range(1.15, 1.3), -10.0)
