extends Camera2D

## Follows the player with a little look-ahead, screen shake and impact punch.

@export var base_zoom := 2.0
@export var follow_speed := 7.0

var target: Node2D
var punch_offset := 0.0
var current_zoom := 2.0
var _shake := Vector2.ZERO


func _ready() -> void:
	current_zoom = base_zoom
	zoom = Vector2.ONE * base_zoom
	position_smoothing_enabled = false
	limit_smoothed = true


func set_target(node: Node2D) -> void:
	target = node
	if target != null:
		global_position = target.global_position


func punch(amount: float) -> void:
	punch_offset = maxf(punch_offset, amount)


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var lead := Vector2.ZERO
	if "look_dir" in target:
		lead = target.look_dir * 22.0
	var bias := Vector2.ZERO
	var want_zoom := base_zoom
	var boss = Game.boss
	if boss != null and is_instance_valid(boss) and not boss.dead:
		var to_boss: Vector2 = boss.global_position - target.global_position
		var d := to_boss.length()
		var w := clampf(1.0 - d / 820.0, 0.0, 1.0)
		bias = to_boss * (0.70 * w)
		want_zoom = base_zoom - 0.18 * w
	var desired: Vector2 = target.global_position + Vector2(0, -8) + lead + bias
	global_position = global_position.lerp(desired, 1.0 - exp(-delta * follow_speed))
	current_zoom = lerpf(current_zoom, want_zoom, 1.0 - exp(-delta * 3.0))
	punch_offset = lerpf(punch_offset, 0.0, 1.0 - exp(-delta * 12.0))
	zoom = Vector2.ONE * (current_zoom - punch_offset)
	offset = FX.get_shake_offset()
