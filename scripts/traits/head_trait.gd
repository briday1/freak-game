class_name HeadTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"head_size": { "type": "float", "min": 20.0, "max": 70.0 },
	}

## Returns head center as (cx, cy) in pixel-canvas space.
static func head_center(genome: Dictionary) -> Vector2i:
	var bsz := BodyTrait.body_half_size(genome)
	var body_top: int = 40 - bsz.y
	var r: int = int(remap(genome["head_size"] as float, 20.0, 70.0, 4.0, 11.0))
	return Vector2i(32, body_top - 2 - r)

## Effective head radius in pixels (used by eyes/mouth/horns).
static func head_radius(genome: Dictionary) -> int:
	return int(remap(genome["head_size"] as float, 20.0, 70.0, 4.0, 11.0))

func paint(img: Image, genome: Dictionary) -> void:
	var pal: Dictionary = PC.palette(genome)
	var hs: float  = genome["head_size"] as float
	var r: int     = head_radius(genome)
	var hc         := head_center(genome)

	# Neck — tapered connection from head to body
	var bsz := BodyTrait.body_half_size(genome)
	var body_top: int = PC.BY - bsz.y
	var neck_w: int   = maxi(2, r / 3)
	var neck_top: int = hc.y + r - 1
	var neck_h: int   = maxi(1, body_top - neck_top + 2)
	PC.fill_rect(img, hc.x - neck_w, neck_top, neck_w * 2, neck_h, pal["body"])

	if hs >= 52.0:
		# BOXY: wide rectangular skull — intimidating
		var hw: int = r + 3
		var hh: int = r
		PC.fill_rect(img, hc.x - hw, hc.y - hh, hw * 2, hh * 2,     pal["body"])
		PC.fill_rect(img, hc.x - hw, hc.y - hh, hw * 2, hh / 3 + 1, pal["shadow"])   # dark brow strip
		PC.outline_rect(img, hc.x - hw, hc.y - hh, hw * 2, hh * 2,  pal["outline"])
		# Brow ridge bumps
		for side: int in [-1, 1]:
			PC.fill_rect(img, hc.x + side * (hw / 2 - 1) - 1, hc.y - hh - 2, 3, 3, pal["accent"])
		# Highlight top
		var sh: Color = pal["highlight"]; sh.a = 0.4
		PC.fill_ellipse(img, hc.x - hw / 3, hc.y - hh / 2, hw / 3, hh / 4, sh)

	elif hs <= 30.0:
		# TINY: small bean — cute and round with big cheeks
		PC.fill_ellipse(img, hc.x, hc.y, r + 1, r, pal["body"])
		PC.outline_ellipse(img, hc.x, hc.y, r + 1, r, pal["outline"])
		# Rosy cheek blobs
		var blush: Color = pal["accent"]; blush.a = 0.55
		PC.fill_circle(img, hc.x - r + 1, hc.y + 1, 1, blush)
		PC.fill_circle(img, hc.x + r - 1, hc.y + 1, 1, blush)
		# Shine
		var sh2: Color = pal["highlight"]; sh2.a = 0.5
		PC.fill_circle(img, hc.x - r / 2, hc.y - r / 2, 1, sh2)

	else:
		# NORMAL: egg-shaped head — slightly taller than wide
		PC.fill_ellipse(img, hc.x, hc.y, r, r + 1, pal["body"])
		PC.outline_ellipse(img, hc.x, hc.y, r, r + 1, pal["outline"])
		# Shading like the body
		var sh3: Color = pal["shadow"];    sh3.a = 0.35
		var hi3: Color = pal["highlight"]; hi3.a = 0.30
		PC.fill_ellipse(img, hc.x, hc.y + r / 2, r - 1, r / 2,     sh3)
		PC.fill_ellipse(img, hc.x - r / 3, hc.y - r / 3, r / 2, r / 3, hi3)
