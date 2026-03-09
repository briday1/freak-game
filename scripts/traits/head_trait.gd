class_name HeadTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"head_size": { "type": "float", "min": 20.0, "max": 70.0 },
	}

## Head is always anchored at the portrait head centre — dominates upper canvas.
static func head_center(genome: Dictionary) -> Vector2i:
	return Vector2i(PC.CX, PC.HEAD_CY)

## Head radius — large so the face fills the sprite (Pokemon style).
static func head_radius(genome: Dictionary) -> int:
	return int(remap(genome["head_size"] as float, 20.0, 70.0, 10.0, 14.0))

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var hs: float  = genome["head_size"] as float
	var r: int     = head_radius(genome)
	var hc         := head_center(genome)

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
	return img
