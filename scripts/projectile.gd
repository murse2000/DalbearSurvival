extends Node2D

## Simple distance-based projectile with a glowing Line2D trail.

var friendly := true
var player
var manager
var velocity := Vector2.ZERO
var base_damage := 0.0
var hits_left := 1
var radius := 11.0
var color := Color(1, 1, 1)
var life := 2.0
var age := 0.0
var dead := false
var _hit_ids := {}
var _sprite: Sprite2D
var _glow: Sprite2D
var _trail: Line2D
var _add_mat: CanvasItemMaterial


func _ready() -> void:
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_trail = Line2D.new()
	_trail.top_level = true
	_trail.z_as_relative = false
	_trail.z_index = 2
	_trail.width = 7.0
	_trail.joint_mode = Line2D.LINE_JOINT_ROUND
	_trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.85))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	_trail.gradient = grad
	_trail.material = _add_mat
	add_child(_trail)

	_glow = Sprite2D.new()
	_glow.texture = load("res://assets/art/fx/glow_green.png")
	_glow.scale = Vector2.ONE * 0.5
	_glow.modulate = Color(1, 1, 1, 0.4)
	_glow.material = _add_mat
	add_child(_glow)
	_trail.width = 5.0
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.6, 0.55))
	curve.add_point(Vector2(1.0, 0.12))
	_trail.width_curve = curve

	_sprite = Sprite2D.new()
	add_child(_sprite)
	_sprite.z_index = 1


func setup_friendly(p, m, pos: Vector2, vel: Vector2, damage: float, pierce: int) -> void:
	player = p
	manager = m
	global_position = pos
	velocity = vel
	base_damage = damage
	hits_left = pierce + 1
	friendly = true
	life = 1.8
	color = Color(1.0, 0.86, 0.5)
	_sprite.texture = load("res://assets/art/fx/moon_bolt.png")
	_sprite.scale = Vector2.ONE * 1.05
	_glow.modulate = Color(1.0, 0.85, 0.45, 0.4)
	_glow.scale = Vector2.ONE * 0.5
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.86, 0.52, 0.62))
	grad.set_color(1, Color(1.0, 0.7, 0.3, 0.0))
	_trail.gradient = grad
	_sprite.rotation = velocity.angle()


func setup_enemy(pos: Vector2, vel: Vector2, damage: float, p, variant: String = "orb") -> void:
	player = p
	global_position = pos
	velocity = vel
	base_damage = damage
	friendly = false
	life = 5.0
	var acid := variant == "acid"
	color = Color(0.55, 1.0, 0.6) if acid else Color(0.9, 0.45, 1.0)
	_sprite.texture = load("res://assets/art/fx/orb_acid.png" if acid else "res://assets/art/fx/orb.png")
	_sprite.scale = Vector2.ONE * 1.2
	_glow.modulate = Color(0.5, 1.0, 0.55, 0.4) if acid else Color(0.8, 0.4, 1.0, 0.4)
	_glow.scale = Vector2.ONE * 0.45
	var grad := Gradient.new()
	if acid:
		grad.set_color(0, Color(0.5, 1.0, 0.55, 0.55))
		grad.set_color(1, Color(0.2, 0.7, 0.4, 0.0))
	else:
		grad.set_color(0, Color(0.85, 0.5, 1.0, 0.55))
		grad.set_color(1, Color(0.55, 0.2, 0.9, 0.0))
	_trail.gradient = grad
	_trail.width = 4.5


func _process(delta: float) -> void:
	if dead:
		return
	age += delta
	if age > life:
		queue_free()
		return
	var previous_position := global_position
	global_position += velocity * delta
	_trail.add_point(global_position, 0)
	while _trail.get_point_count() > 10:
		_trail.remove_point(_trail.get_point_count() - 1)
	_sprite.rotation += delta * 9.0
	_glow.scale = Vector2.ONE * (0.68 + sin(age * 18.0) * 0.06)

	if absf(global_position.x) > GameData.ARENA_HALF + 60.0 or absf(global_position.y) > GameData.ARENA_HALF + 60.0:
		queue_free()
		return

	if manager != null and manager.hit_obstacle(global_position, radius,
			base_damage * (1.0 if friendly else 0.55)):
		_die()
		return

	if friendly:
		if manager == null:
			return
		for enemy in manager.query_circle(global_position, radius):
			if enemy.dead:
				continue
			var id: int = enemy.get_instance_id()
			if _hit_ids.has(id):
				continue
			_hit_ids[id] = true
			var roll: Dictionary = player.roll_damage(base_damage)
			enemy.take_damage(roll["damage"], roll["crit"], global_position, 110.0)
			FX.hit(enemy.global_position + Vector2(0, -8), color, roll["crit"])
			Audio.play("hit", randf_range(0.9, 1.15), -9.0)
			hits_left -= 1
			if hits_left <= 0:
				_die()
				return
	else:
		if player != null and is_instance_valid(player) and not player.dead:
			# Swept collision: low frame rates must not let a fast orb tunnel
			# through the player between two rendered positions.
			var target: Vector2 = player.global_position + Vector2(0, -12)
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(
				target, previous_position, global_position
			)
			var hit_radius: float = radius + float(player.radius) + 2.0
			if target.distance_to(closest) <= hit_radius:
				# Keep the orb alive through i-frames so it cannot vanish
				# without ever applying damage.
				if player.take_damage(base_damage):
					FX.hit(closest, color, false)
					_die()
					return


func _die() -> void:
	if dead:
		return
	dead = true
	FX.hit(global_position, color, false)
	queue_free()
