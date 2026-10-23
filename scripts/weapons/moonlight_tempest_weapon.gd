extends WeaponBase

## Evolved Moonlit Blades: seven blades orbit faster and every slash wave
## restores a little health. Requires Moonlit Blades 6 + Bear Heart 3.

const BLADE_COLOR := Color(1.0, 0.86, 0.48)
const HEAL_COLOR := Color(0.6, 1.0, 0.78)

var blades: Array[Node2D] = []
var angle := 0.0
var wave_cd := 1.0
var hit_times := {}


func weapon_id() -> String:
	return "moonlight_tempest"


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
		glow.modulate = Color(1.0, 0.76, 0.3, 0.36)
		glow.scale = Vector2.ONE * 0.44
		var gm := CanvasItemMaterial.new()
		gm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = gm
		root.add_child(glow)
		var blade := Sprite2D.new()
		blade.texture = slash_tex
		blade.modulate = BLADE_COLOR
		blade.scale = Vector2.ONE * 0.82
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
		player.manager.damage_obstacles_circle(world, 27.0, float(data["damage"]))
		for enemy in player.manager.query_circle(world, 27.0):
			if enemy.dead:
				continue
			var id: int = enemy.get_instance_id()
			if hit_times.has(id) and now - float(hit_times[id]) < hit_cd:
				continue
			hit_times[id] = now
			var roll: Dictionary = player.roll_damage(float(data["damage"]))
			enemy.take_damage(roll["damage"], roll["crit"], center, 105.0)
			FX.slash(world, a + PI * 0.5, BLADE_COLOR, 0.26)
			Audio.play("hit", randf_range(1.0, 1.16), -10.0)
	if hit_times.size() > 300:
		hit_times.clear()
	wave_cd -= delta
	if wave_cd <= 0.0:
		_slash_wave()
		wave_cd = float(data["wave_cd"])


func _slash_wave() -> void:
	var center: Vector2 = player.global_position + Vector2(0, -14)
	var radius := float(data["radius"]) + 58.0
	var has_target: bool = not player.manager.query_circle(center, radius).is_empty()
	player.manager.damage_circle(center, radius, float(data["wave_damage"]), 160.0, player)
	for i in 12:
		FX.slash(center, TAU * float(i) / 12.0 + angle * 0.2, BLADE_COLOR, 0.4)
	FX.ring(center, BLADE_COLOR, radius, 0.42, "halo")
	FX.screen_shock(0.22, 0.008, 0.18, BLADE_COLOR)
	FX.flash(Color(1.0, 0.82, 0.4), 0.04, 0.15)
	FX.shake(3.0, 0.18)
	if has_target:
		var heal_amount := float(data.get("wave_heal", 0.0))
		if heal_amount > 0.0:
			player.heal(heal_amount, false)
			FX.ring(center, HEAL_COLOR, 52.0, 0.4, "halo")
			FX.particles(center, "star", HEAL_COLOR, 8, 0.45, 20, 80, 0.24, 180,
				Vector2(0, -50), true, 160)
	Audio.play("laser", randf_range(1.15, 1.3), -10.0)
