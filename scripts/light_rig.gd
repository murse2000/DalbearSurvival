class_name LightRig
extends RefCounted

## Lighting bridge: Lit on Forward+ desktop builds, native 2D lights on the
## GL Compatibility mobile/headless builds. The game code stays the same.

const RECEIVER := "res://addons/lit/shaders/receiver/lit_receiver_fast.gdshader"
const LIGHT_TEXTURE_SIZE := 256.0

static var _lit_state := -1
static var _native_texture: Texture2D


static func lit_enabled() -> bool:
	if _lit_state < 0:
		_lit_state = 1 if not OS.has_feature("mobile") \
			and RenderingServer.get_rendering_device() != null else 0
	return _lit_state == 1


static func create_ambient(parent: Node, color: Color) -> Node:
	var ambient: Node
	if lit_enabled():
		ambient = LitCanvasModulate.new()
		ambient.color = color
	else:
		ambient = CanvasModulate.new()
		ambient.color = color
	parent.add_child(ambient)
	return ambient


static func make_receiver(item: CanvasItem, emissive: float = 0.0, mask: int = 3) -> void:
	if item == null or not is_instance_valid(item):
		return
	# Native GL lights read CanvasItem.light_mask directly. Lit receivers read
	# their receiver_mask uniform. The default mask 3 lets normal actors and the
	# world receive both ambient/rim lights (1) and the bear's back light (2).
	item.light_mask = mask
	if not lit_enabled() or item.material != null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = load(RECEIVER)
	mat.set_shader_parameter("receiver_mask", mask)
	mat.set_shader_parameter("emissive_strength", emissive)
	item.material = mat


static func add_point_light(parent: Node2D, color: Color, light_range: float,
		energy: float, shadows: bool = false, offset: Vector2 = Vector2.ZERO,
		mask: int = 1) -> Node2D:
	if parent == null or not is_instance_valid(parent):
		return null
	var light: Node2D
	if lit_enabled():
		var lit := LitPointLight2D.new()
		lit.color = color
		lit.range = light_range
		lit.energy = energy
		lit.falloff = 1.0
		lit.shadow_enabled = shadows
		lit.shadow_hardness = 0.55
		lit.source_radius = 22.0
		light = lit
	else:
		var native := PointLight2D.new()
		native.texture = _light_texture()
		native.texture_scale = light_range * 2.0 / LIGHT_TEXTURE_SIZE
		native.color = color
		# Mask 4 is the player-only fill; keep it at full strength so the
		# GL fallback does not turn the bear into a black silhouette.
		native.energy = energy * (1.0 if mask == 4 else 0.72)
		native.shadow_enabled = false
		light = native
	light.light_mask = mask
	light.position = offset
	parent.add_child(light)
	return light


static func add_occluder(parent: Node2D, texture_size: Vector2,
		offset: Vector2 = Vector2.ZERO) -> void:
	if not lit_enabled() or parent == null or texture_size.x < 2.0 or texture_size.y < 2.0:
		return
	var half := texture_size * 0.5
	var poly := OccluderPolygon2D.new()
	poly.closed = true
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	var occ := LightOccluder2D.new()
	occ.occluder = poly
	occ.occluder_light_mask = 1
	occ.position = offset
	parent.add_child(occ)


static func _light_texture() -> Texture2D:
	if _native_texture != null:
		return _native_texture
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.45, 0.78, 1.0])
	grad.colors = PackedColorArray([
		Color(1, 1, 1, 1), Color(0.78, 0.78, 0.78, 1),
		Color(0.20, 0.20, 0.20, 1), Color(0, 0, 0, 1),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = int(LIGHT_TEXTURE_SIZE)
	tex.height = int(LIGHT_TEXTURE_SIZE)
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	_native_texture = tex
	return tex
