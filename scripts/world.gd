extends Node2D

## Builds the battlefield for the chosen stage: ground, alien props, border,
## ground clutter, fog, fireflies.

const A := "res://assets/art/"
const HALF := GameData.ARENA_HALF

var actors: Node2D
var decals: Node2D
var pickups: Node2D
var projectiles: Node2D
var obstacles: Node2D
var fx_root: Node2D
var damage_root: Node2D
var target: Node2D
var stage_id := "forest"

var _fog: Array[Sprite2D] = []
var _fireflies: Array[CPUParticles2D] = []
var _lights: Array = []
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func build(stage: String) -> void:
	stage_id = stage
	_rng.seed = 20261021
	z_as_relative = false
	_build_containers()
	_build_ground()
	_build_decals()
	_build_decor()
	_build_border()
	_build_props()
	_build_fog()
	_build_fireflies()


func _build_containers() -> void:
	decals = _node("Decals")
	decals.z_index = -6
	var decor := _node("Decor")
	decor.z_index = -5
	actors = _node("Actors")
	actors.y_sort_enabled = true
	pickups = _node("Pickups")
	pickups.z_index = -2
	projectiles = _node("Projectiles")
	projectiles.z_index = 5
	obstacles = _node("Obstacles")
	obstacles.z_index = -1
	fx_root = _node("VFX")
	fx_root.z_index = 8
	damage_root = _node("Damage")
	damage_root.z_index = 13
	_node("Fog").z_index = 6
	_node("Fireflies").z_index = 11


func _node(node_name: String) -> Node2D:
	var n := Node2D.new()
	n.name = node_name
	add_child(n)
	return n


func _ground_path() -> String:
	match stage_id:
		"hive", "crater":
			return A + "world/ground_hive.png"
		"ship", "void":
			return A + "world/ground_ship.png"
	return A + "world/ground.png"


func _outer_tint() -> Color:
	match stage_id:
		"hive":
			return Color(0.56, 0.42, 0.66, 1.0)
		"ship":
			return Color(0.42, 0.52, 0.62, 1.0)
		"crater":
			return Color(0.78, 0.38, 0.28, 1.0)
		"void":
			return Color(0.38, 0.30, 0.62, 1.0)
	return Color(0.52, 0.64, 0.62, 1.0)


func _build_ground() -> void:
	var tex_path := _ground_path()
	var outer := Sprite2D.new()
	outer.name = "ForestFloor"
	outer.texture = load(tex_path)
	outer.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	outer.region_enabled = true
	outer.region_rect = Rect2(0, 0, 5600, 5600)
	outer.centered = false
	outer.position = Vector2(-2800, -2800)
	outer.modulate = _outer_tint()
	outer.z_index = -22
	add_child(outer)
	LightRig.make_receiver(outer)

	var g := Sprite2D.new()
	g.name = "Ground"
	g.texture = load(tex_path)
	g.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	g.region_enabled = true
	g.region_rect = Rect2(0, 0, HALF * 2.0, HALF * 2.0)
	g.centered = false
	g.position = Vector2(-HALF, -HALF)
	g.z_index = -20
	add_child(g)
	LightRig.make_receiver(g)


func _build_decals() -> void:
	var center_tex := A + "world/crop_circle_0.png"
	var center_tint := Color(1, 1, 1, 0.55)
	match stage_id:
		"hive":
			center_tex = A + "world/crop_circle_1.png"
			center_tint = Color(0.85, 0.55, 1.0, 0.42)
		"ship":
			center_tex = A + "world/crop_circle_1.png"
			center_tint = Color(0.45, 0.9, 0.9, 0.22)
		"crater":
			center_tex = A + "world/crop_circle_1.png"
			center_tint = Color(1.0, 0.48, 0.28, 0.38)
		"void":
			center_tex = A + "world/crop_circle_1.png"
			center_tint = Color(0.62, 0.4, 1.0, 0.32)
	var spawn_circle := Sprite2D.new()
	spawn_circle.texture = load(center_tex)
	spawn_circle.scale = Vector2(2.2, 2.2)
	spawn_circle.modulate = center_tint
	decals.add_child(spawn_circle)
	LightRig.make_receiver(spawn_circle)

	var count := 7 if stage_id == "forest" else 9
	for i in count:
		var s := Sprite2D.new()
		s.texture = load(A + "world/crop_circle_%d.png" % (i % 2))
		s.position = Vector2(_rng.randf_range(-1450, 1450), _rng.randf_range(-1450, 1450))
		s.rotation = _rng.randf_range(0.0, TAU)
		s.scale = Vector2.ONE * _rng.randf_range(0.8, 2.4)
		match stage_id:
			"hive":
				s.modulate = Color(0.8, 0.5, 1.0, _rng.randf_range(0.18, 0.34))
			"ship":
				s.modulate = Color(0.5, 0.95, 0.95, _rng.randf_range(0.10, 0.22))
			"crater":
				s.modulate = Color(1.0, 0.42, 0.24, _rng.randf_range(0.16, 0.30))
			"void":
				s.modulate = Color(0.62, 0.42, 1.0, _rng.randf_range(0.14, 0.28))
			_:
				s.modulate = Color(1, 1, 1, _rng.randf_range(0.28, 0.5))
		decals.add_child(s)
		LightRig.make_receiver(s)
	for i in 10:
		var s := Sprite2D.new()
		s.texture = load(A + "world/scorch_%d.png" % (i % 2))
		s.position = Vector2(_rng.randf_range(-1550, 1550), _rng.randf_range(-1550, 1550))
		s.rotation = _rng.randf_range(0.0, TAU)
		s.scale = Vector2.ONE * _rng.randf_range(0.7, 1.8)
		s.modulate = Color(0.7, 0.6, 0.9, 0.55) if stage_id == "hive" else Color(1, 1, 1, 0.5)
		decals.add_child(s)
		LightRig.make_receiver(s)


func _build_decor() -> void:
	var decor := get_node("Decor")
	match stage_id:
		"hive":
			_multimesh(decor, A + "world/hive_spore.png", 260, 0.9, 1.6, Color(0.9, 1.0, 0.9, 0.9))
			_multimesh(decor, A + "world/hive_tendril.png", 190, 0.8, 1.5, Color(0.9, 0.8, 1.0, 0.95))
			_multimesh(decor, A + "world/hive_bone.png", 150, 0.8, 1.4, Color(1.0, 0.95, 0.85, 0.8))
			_multimesh(decor, A + "world/hive_mound.png", 26, 0.5, 0.9, Color(1, 1, 1, 0.9))
			_multimesh(decor, A + "world/hive_egg.png", 18, 0.45, 0.8, Color(1, 1, 1, 0.9))
		"ship":
			_multimesh(decor, A + "world/ship_light.png", 190, 0.9, 1.4, Color(0.8, 1.0, 1.0, 0.85))
			_multimesh(decor, A + "world/ship_bolt.png", 280, 0.8, 1.3, Color(0.85, 0.9, 1.0, 0.8))
			_multimesh(decor, A + "world/ship_cable.png", 150, 0.8, 1.4, Color(0.7, 1.0, 1.0, 0.8))
			_multimesh(decor, A + "world/ship_grate.png", 120, 0.8, 1.4, Color(0.8, 0.9, 1.0, 0.8))
		"crater":
			_multimesh(decor, A + "world/hive_spore.png", 240, 0.9, 1.6, Color(1.0, 0.55, 0.3, 0.8))
			_multimesh(decor, A + "world/hive_bone.png", 160, 0.8, 1.4, Color(1.0, 0.72, 0.5, 0.7))
			_multimesh(decor, A + "world/rock_0.png", 180, 0.6, 1.2, Color(0.8, 0.42, 0.28, 0.8))
			_multimesh(decor, A + "world/scorch_0.png", 55, 0.8, 1.5, Color(1.0, 0.4, 0.2, 0.5))
		"void":
			_multimesh(decor, A + "world/ship_light.png", 170, 0.9, 1.4, Color(0.7, 0.55, 1.0, 0.85))
			_multimesh(decor, A + "world/ship_bolt.png", 250, 0.8, 1.3, Color(0.55, 0.4, 0.9, 0.8))
			_multimesh(decor, A + "world/alien_crystal.png", 90, 0.5, 1.0, Color(0.55, 0.35, 1.0, 0.8))
			_multimesh(decor, A + "world/ship_grate.png", 100, 0.8, 1.4, Color(0.6, 0.5, 0.9, 0.7))
		_:
			_multimesh(decor, A + "world/grass_tuft_0.png", 720, 0.8, 1.4, Color(0.9, 1.0, 0.92, 0.85))
			_multimesh(decor, A + "world/grass_tuft_1.png", 560, 0.8, 1.3, Color(0.92, 1.0, 0.9, 0.8))
			_multimesh(decor, A + "world/grass_tuft_2.png", 400, 0.7, 1.2, Color(0.85, 0.95, 0.95, 0.8))
			_multimesh(decor, A + "world/flower_0.png", 260, 0.9, 1.2, Color(1, 1, 1, 0.95))
			_multimesh(decor, A + "world/flower_1.png", 210, 0.9, 1.2, Color(1, 1, 1, 0.9))
			_multimesh(decor, A + "world/flower_2.png", 140, 0.9, 1.2, Color(0.9, 1.0, 0.95, 0.9))
			_multimesh(decor, A + "world/pebble.png", 300, 0.8, 1.3, Color(0.9, 0.95, 1.0, 0.8))
			_multimesh(decor, A + "world/alien_mushroom.png", 110, 0.9, 1.4, Color(1, 1, 1, 0.95))
			_multimesh(decor, A + "world/bush_0.png", 110, 0.8, 1.2, Color(0.9, 1.0, 0.95, 0.95))
			_multimesh(decor, A + "world/bush_1.png", 85, 0.8, 1.2, Color(0.9, 1.0, 0.95, 0.95))


func _multimesh(parent: Node2D, tex_path: String, count: int, smin: float, smax: float, color: Color) -> void:
	var tex: Texture2D = load(tex_path)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.instance_count = count
	var quad := QuadMesh.new()
	quad.size = Vector2(tex.get_width(), tex.get_height())
	mm.mesh = quad
	for i in count:
		var pos := Vector2(_rng.randf_range(-HALF + 40, HALF - 40), _rng.randf_range(-HALF + 40, HALF - 40))
		var s := _rng.randf_range(smin, smax)
		var rot := _rng.randf_range(-0.2, 0.2)
		if tex_path.contains("flower") or tex_path.contains("pebble") or tex_path.contains("bone"):
			rot = _rng.randf_range(0.0, TAU)
		elif tex_path.contains("grass_tuft"):
			rot = _rng.randf_range(-0.6, 0.6)
		var t := Transform2D(rot, pos)
		t = t.scaled(Vector2(s, s))
		mm.set_instance_transform_2d(i, t)
		var c := color
		c.a *= _rng.randf_range(0.7, 1.0)
		mm.set_instance_color(i, c)
	var mmi := MultiMeshInstance2D.new()
	mmi.multimesh = mm
	mmi.texture = tex
	parent.add_child(mmi)
	LightRig.make_receiver(mmi)


func _add_sprite(parent: Node2D, tex_path: String, pos: Vector2, scale_f: float = 1.0,
		rot: float = 0.0, tint: Color = Color.WHITE) -> Sprite2D:
	var tex: Texture2D = load(tex_path)
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.offset = Vector2(0, -tex.get_height() * 0.5)
	s.scale = Vector2.ONE * scale_f
	s.rotation = rot
	s.modulate = tint
	parent.add_child(s)
	LightRig.make_receiver(s)
	return s


func _build_border() -> void:
	match stage_id:
		"hive", "crater":
			_build_hive_border()
		"ship", "void":
			_build_ship_border()
		_:
			_build_forest()


func _build_forest() -> void:
	var trees := ["tree_pine_0", "tree_pine_1", "tree_pine_2", "tree_broad", "dead_tree"]
	for side in 4:
		for i in 64:
			var along := _rng.randf_range(-2150.0, 2150.0)
			var depth := _rng.randf_range(1735.0, 2110.0)
			var pos := Vector2.ZERO
			match side:
				0: pos = Vector2(along, -depth)
				1: pos = Vector2(along, depth)
				2: pos = Vector2(-depth, along)
				3: pos = Vector2(depth, along)
			var tree_name: String = trees[_rng.randi_range(0, trees.size() - 1)]
			var scale_f := _rng.randf_range(1.0, 1.65)
			if tree_name == "dead_tree":
				scale_f *= 0.9
			var tint := Color(0.78, 0.9, 0.85, 1.0).lerp(Color(1, 1, 1), _rng.randf_range(0.0, 0.45))
			_add_sprite(actors, A + "world/" + tree_name + ".png", pos, scale_f, _rng.randf_range(-0.08, 0.08), tint)
	for i in 18:
		var a := _rng.randf_range(0.0, TAU)
		var pos := Vector2(cos(a), sin(a)) * _rng.randf_range(1640.0, 1720.0)
		_add_sprite(actors, A + "world/tree_broad.png", pos, _rng.randf_range(0.7, 1.0))


func _build_hive_border() -> void:
	var texs := ["hive_pillar", "hive_pillar", "hive_spike", "hive_spike", "hive_coral"]
	for side in 4:
		for i in 80:
			var along := _rng.randf_range(-2200.0, 2200.0)
			var depth := _rng.randf_range(1725.0, 2140.0)
			var pos := Vector2.ZERO
			match side:
				0: pos = Vector2(along, -depth)
				1: pos = Vector2(along, depth)
				2: pos = Vector2(-depth, along)
				3: pos = Vector2(depth, along)
			var name: String = texs[_rng.randi_range(0, texs.size() - 1)]
			var s := _rng.randf_range(1.0, 1.8)
			var tint := Color(0.75, 0.55, 0.9, 1.0).lerp(Color(1, 1, 1), _rng.randf_range(0.0, 0.35))
			_add_sprite(actors, A + "world/" + name + ".png", pos, s, _rng.randf_range(-0.1, 0.1), tint)
	for i in 22:
		var a := _rng.randf_range(0.0, TAU)
		var pos := Vector2(cos(a), sin(a)) * _rng.randf_range(1620.0, 1720.0)
		_add_sprite(actors, A + "world/hive_spike.png", pos, _rng.randf_range(0.7, 1.1),
			_rng.randf_range(-0.15, 0.15), Color(0.8, 0.65, 0.95))


func _build_ship_border() -> void:
	var texs := ["ship_wall", "ship_wall", "ship_pylon", "ship_wall"]
	for side in 4:
		for i in 78:
			var along := _rng.randf_range(-2200.0, 2200.0)
			var depth := _rng.randf_range(1725.0, 2020.0)
			var pos := Vector2.ZERO
			match side:
				0: pos = Vector2(along, -depth)
				1: pos = Vector2(along, depth)
				2: pos = Vector2(-depth, along)
				3: pos = Vector2(depth, along)
			var name: String = texs[_rng.randi_range(0, texs.size() - 1)]
			var s := _rng.randf_range(0.9, 1.4)
			var tint := Color(0.65, 0.82, 0.9, 1.0).lerp(Color(1, 1, 1), _rng.randf_range(0.0, 0.3))
			_add_sprite(actors, A + "world/" + name + ".png", pos, s, 0.0, tint)
	for i in 16:
		var a := _rng.randf_range(0.0, TAU)
		var pos := Vector2(cos(a), sin(a)) * _rng.randf_range(1630.0, 1715.0)
		_add_sprite(actors, A + "world/ship_pylon.png", pos, _rng.randf_range(0.6, 0.9), 0.0,
			Color(0.75, 0.9, 0.95))


func _build_props() -> void:
	var props := []
	match stage_id:
		"hive":
			props = [
				["hive_egg", 18, 1.2], ["hive_coral", 16, 1.3], ["hive_pod", 12, 1.2],
				["hive_mound", 12, 1.3], ["hive_spike", 12, 1.1], ["alien_crystal", 6, 1.0],
				["crashed_saucer", 1, 1.25], ["hive_pillar", 4, 0.9],
			]
		"ship":
			props = [
				["ship_console", 12, 1.1], ["ship_pod", 12, 1.1], ["ship_pipes", 10, 1.2],
				["ship_vent", 10, 1.1], ["ship_pylon", 8, 1.0], ["crate", 6, 1.0],
				["barricade", 4, 1.0], ["ship_wall", 3, 0.9],
			]
		"crater":
			props = [
				["hive_egg", 14, 1.1], ["hive_coral", 18, 1.2], ["hive_pod", 12, 1.1],
				["rock_0", 16, 1.3], ["rock_1", 16, 1.2], ["alien_crystal", 10, 1.0],
				["crashed_saucer", 2, 1.25], ["scorch_0", 8, 1.0],
			]
		"void":
			props = [
				["ship_console", 12, 1.1], ["ship_pod", 10, 1.1], ["ship_pylon", 10, 1.1],
				["alien_crystal", 14, 1.1], ["ship_wall", 5, 0.9], ["crashed_saucer", 2, 1.2],
				["barricade", 4, 1.0], ["ship_vent", 10, 1.0],
			]
		_:
			props = [
				["crashed_saucer", 2, 1.35], ["crate", 7, 1.0], ["alien_crystal", 12, 1.0],
				["barricade", 6, 1.0], ["warning_sign", 5, 1.0], ["fallen_log", 7, 1.0],
				["rock_0", 9, 1.2], ["rock_1", 9, 1.1], ["bush_0", 6, 1.4], ["bush_1", 6, 1.4],
			]
	var placed: Array[Vector2] = []
	for entry in props:
		var prop_name: String = entry[0]
		var count: int = entry[1]
		var sc: float = entry[2]
		for i in count:
			var pos := Vector2.ZERO
			for tries in 14:
				var a := _rng.randf_range(0.0, TAU)
				var d := _rng.randf_range(230.0, 1600.0)
				pos = Vector2(cos(a), sin(a)) * d
				var ok := pos.distance_to(Vector2.ZERO) > 170.0
				for other in placed:
					if pos.distance_to(other) < 85.0:
						ok = false
						break
				if ok:
					break
			placed.append(pos)
			var tint := Color(1, 1, 1, 1)
			if stage_id == "ship":
				tint = Color(0.8, 0.92, 1.0, 1.0)
			elif stage_id == "hive":
				tint = Color(0.9, 0.78, 1.0, 1.0)
			elif stage_id == "crater":
				tint = Color(1.0, 0.66, 0.46, 1.0)
			elif stage_id == "void":
				tint = Color(0.7, 0.58, 1.0, 1.0)
			var s := _add_sprite(actors, A + "world/" + prop_name + ".png", pos,
				sc * _rng.randf_range(0.85, 1.15), 0.0, tint)
			var tex_size := Vector2(s.texture.get_width(), s.texture.get_height())
			if prop_name in ["crashed_saucer", "crate", "barricade", "fallen_log",
					"rock_0", "rock_1", "hive_pillar", "hive_coral", "ship_wall",
					"ship_pod", "ship_console"]:
				LightRig.add_occluder(s, tex_size, Vector2(0, -tex_size.y * 0.5))
			_add_prop_light(s, prop_name, i, tex_size)
			if prop_name == "crashed_saucer":
				var glow := Sprite2D.new()
				glow.texture = load(A + "fx/glow_green.png")
				glow.position = Vector2(0, -12)
				glow.scale = Vector2.ONE * 0.75
				glow.modulate = Color(0.5, 1.0, 0.7, 0.14)
				var mat := CanvasItemMaterial.new()
				mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
				glow.material = mat
				s.add_child(glow)
			elif stage_id == "hive" and prop_name == "hive_egg":
				var glow := Sprite2D.new()
				glow.texture = load(A + "fx/glow_green.png")
				glow.position = Vector2(0, -18)
				glow.scale = Vector2.ONE * 0.5
				glow.modulate = Color(0.5, 1.0, 0.6, 0.22)
				var mat := CanvasItemMaterial.new()
				mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
				glow.material = mat
				s.add_child(glow)
			elif stage_id == "ship" and (prop_name == "ship_pod" or prop_name == "ship_pylon"):
				var glow := Sprite2D.new()
				glow.texture = load(A + "fx/glow_green.png")
				glow.position = Vector2(0, -18)
				glow.scale = Vector2.ONE * 0.55
				glow.modulate = Color(0.4, 1.0, 0.95, 0.18)
				var mat := CanvasItemMaterial.new()
				mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
				glow.material = mat
				s.add_child(glow)


func _add_prop_light(s: Sprite2D, prop_name: String, index: int, tex_size: Vector2) -> void:
	if _lights.size() >= 18:
		return
	var color := Color.WHITE
	var light_range := 150.0
	var energy := 0.7
	match prop_name:
		"crashed_saucer":
			color = Color(0.45, 1.0, 0.7)
			light_range = 260.0
			energy = 1.15
		"alien_crystal":
			if index % 3 != 0:
				return
			color = Color(0.35, 0.9, 1.0)
			light_range = 180.0
			energy = 0.72
		"hive_egg":
			if index % 4 != 0:
				return
			color = Color(0.55, 1.0, 0.55)
			light_range = 160.0
			energy = 0.82
		"hive_pod":
			if index % 3 != 0:
				return
			color = Color(0.68, 0.42, 1.0)
			light_range = 175.0
			energy = 0.76
		"hive_coral":
			if index % 5 != 0:
				return
			color = Color(0.82, 0.45, 1.0)
			light_range = 135.0
			energy = 0.58
		"ship_pod":
			if index % 3 != 0:
				return
			color = Color(0.3, 0.92, 0.95)
			light_range = 190.0
			energy = 0.8
		"ship_console":
			if index % 4 != 0:
				return
			color = Color(0.35, 0.88, 1.0)
			light_range = 150.0
			energy = 0.62
		"ship_pylon":
			if index % 3 != 0:
				return
			color = Color(0.35, 0.95, 0.9)
			light_range = 170.0
			energy = 0.7
		_:
			return
	var light := LightRig.add_point_light(s, color, light_range, energy, false,
		Vector2(0, -tex_size.y * 0.5))
	if light == null:
		return
	_lights.append({
		"node": light, "base": energy, "range": light_range,
		"phase": _rng.randf() * TAU, "speed": _rng.randf_range(1.2, 2.8),
	})


func _build_fog() -> void:
	var fog := get_node("Fog")
	var tex: Texture2D = load(A + "fx/fog.png")
	var tint := Color(0.7, 0.9, 0.9, 0.10)
	if stage_id == "hive":
		tint = Color(0.8, 0.45, 0.9, 0.13)
	elif stage_id == "ship":
		tint = Color(0.4, 0.9, 0.95, 0.10)
	elif stage_id == "crater":
		tint = Color(1.0, 0.42, 0.2, 0.12)
	elif stage_id == "void":
		tint = Color(0.55, 0.35, 1.0, 0.13)
	for i in 4:
		var s := Sprite2D.new()
		s.texture = tex
		s.scale = Vector2(4.5, 3.0) * _rng.randf_range(0.8, 1.2)
		s.modulate = Color(tint.r, tint.g, tint.b, tint.a + i * 0.015)
		s.z_index = 0
		s.position = Vector2(_rng.randf_range(-400, 400), _rng.randf_range(-300, 300))
		fog.add_child(s)
		_fog.append(s)


func _build_fireflies() -> void:
	var root := get_node("Fireflies")
	var colors := [Color(1.0, 0.86, 0.48, 0.85), Color(0.55, 1.0, 0.8, 0.7)]
	match stage_id:
		"hive":
			colors = [Color(0.65, 1.0, 0.55, 0.75), Color(0.95, 0.5, 1.0, 0.6)]
		"ship":
			colors = [Color(0.45, 1.0, 0.95, 0.8), Color(1.0, 0.55, 0.9, 0.55)]
		"crater":
			colors = [Color(1.0, 0.55, 0.24, 0.85), Color(1.0, 0.28, 0.16, 0.6)]
		"void":
			colors = [Color(0.6, 0.42, 1.0, 0.8), Color(0.9, 0.4, 1.0, 0.55)]
	for c in colors:
		_fireflies.append(_make_fireflies(root, c))


func _make_fireflies(parent: Node2D, color: Color) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = load(A + "fx/firefly.png")
	p.amount = 55
	p.lifetime = 6.0
	p.preprocess = 4.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 360.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 12.0
	p.gravity = Vector2(0, -1.0)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.4
	p.color = color
	p.local_coords = false
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = mat
	p.emitting = true
	parent.add_child(p)
	return p


func _process(delta: float) -> void:
	_time += delta
	for entry in _lights:
		var light = entry["node"]
		if light == null or not is_instance_valid(light):
			continue
		var base: float = float(entry["base"])
		var phase: float = float(entry["phase"])
		var speed: float = float(entry["speed"])
		light.energy = base * (0.82 + 0.18 * absf(sin(_time * speed + phase)))
	if target != null and is_instance_valid(target):
		for i in _fog.size():
			var f := _fog[i]
			f.position = target.global_position + Vector2(
				sin(_time * 0.07 + i * 2.0) * 200.0,
				cos(_time * 0.05 + i * 1.3) * 140.0
			) + Vector2(-200, -150) * i
		for p in _fireflies:
			p.global_position = target.global_position
