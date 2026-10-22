extends Node2D

## XP gem / heart pickup with toss, bob, magnet attraction and sparkle.

var kind := "xp"
var value := 1
var player
var velocity := Vector2.ZERO
var age := 0.0
var settle := 0.0
var attracted := false
var dead := false
var _sprite: Sprite2D
var _glow: Sprite2D
var _seed := 0.0
var _trail_timer := 0.0
var _add_mat: CanvasItemMaterial


func _ready() -> void:
	z_as_relative = true
	_seed = randf() * 10.0
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow = Sprite2D.new()
	_glow.material = _add_mat
	_glow.scale = Vector2.ONE * 0.5
	add_child(_glow)
	_sprite = Sprite2D.new()
	add_child(_sprite)


func setup(p, pos: Vector2, k: String, v: int, toss: Vector2) -> void:
	player = p
	kind = k
	value = v
	global_position = pos
	velocity = toss
	settle = 0.28
	if kind == "heart":
		_sprite.texture = load("res://assets/art/fx/heart.png")
		_glow.texture = load("res://assets/art/fx/glow_gold.png")
		_glow.modulate = Color(1.0, 0.4, 0.4, 0.45)
	else:
		var variant := 0
		if v >= 8:
			variant = 2
		elif v >= 3:
			variant = 1
		_sprite.texture = load("res://assets/art/fx/gem_%d.png" % variant)
		_glow.texture = load("res://assets/art/fx/glow_green.png")
		_glow.modulate = [
			Color(0.5, 0.8, 1.0, 0.4),
			Color(0.5, 1.0, 0.7, 0.4),
			Color(0.8, 0.55, 1.0, 0.55),
		][variant]
		if variant == 2:
			_sprite.scale = Vector2.ONE * 1.15
	_glow.scale = Vector2.ONE * (0.55 if kind == "heart" else 0.5)
	LightRig.make_receiver(_sprite, 0.65)


func _process(delta: float) -> void:
	if dead or player == null or not is_instance_valid(player):
		return
	age += delta
	if settle > 0.0:
		settle -= delta
		global_position += velocity * delta
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-delta * 9.0))
	else:
		if game_distance() < player.pickup_radius or attracted:
			attracted = true
			var target: Vector2 = player.global_position + Vector2(0, -12)
			var dir := (target - global_position).normalized()
			var speed_now: float = minf(1050.0, 260.0 + age * 420.0)
			velocity = velocity.lerp(dir * speed_now, 1.0 - exp(-delta * 11.0))
			global_position += velocity * delta
		else:
			velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-delta * 6.0))
			global_position += velocity * delta

	if game_distance() < 16.0:
		_collect()
		return

	# animation
	_sprite.position.y = sin(age * 4.2 + _seed) * 2.2 - 2.0
	_sprite.rotation = sin(age * 2.6 + _seed) * 0.22
	_glow.position.y = _sprite.position.y
	_glow.scale = Vector2.ONE * (0.5 + sin(age * 3.4 + _seed) * 0.06)
	_glow.modulate.a = 0.42 + sin(age * 3.0 + _seed) * 0.12

	if kind != "heart" and value >= 8 and attracted:
		_trail_timer -= delta
		if _trail_timer <= 0.0:
			_trail_timer = 0.12
			FX.particles(global_position + Vector2(0, -4), "star",
				Color(0.75, 0.6, 1.0), 1, 0.28, 10, 40, 0.2, 180, Vector2.ZERO, true, 120)

	if age > 90.0:
		queue_free()


func game_distance() -> float:
	if player == null or not is_instance_valid(player):
		return 99999.0
	return global_position.distance_to(player.global_position + Vector2(0, -10))


func _collect() -> void:
	if dead:
		return
	dead = true
	player.collect(value, kind)
	queue_free()
