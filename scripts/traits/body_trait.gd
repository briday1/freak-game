class_name BodyTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")
const CX := PC.CX
const BY := PC.BY

func get_schema() -> Dictionary:
	return {
		"body_width":   { "type": "float", "min":  40.0, "max": 120.0 },
		"body_height":  { "type": "float", "min":  60.0, "max": 160.0 },
		"roundness":    { "type": "float", "min":   0.0, "max":   1.0 },
		"strength":     { "type": "float", "min":   0.0, "max":   1.0 },
		"pattern":      { "type": "float", "min":   0.0, "max":   1.0 },
		"body_color":   { "type": "color",
			"min": Color(0.1, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
		"accent_color": { "type": "color",
			"min": Color(0.0, 0.0, 0.1), "max": Color(1.0, 1.0, 1.0) },
	}

## Returns body half-size as Vector2i(bw, bh) in canvas pixels.
static func body_half_size(genome: Dictionary) -> Vector2i:
	return Vector2i(
		int(remap(genome["body_width"]  as float, 40.0, 120.0, 5.0, 11.0)),
		int(remap(genome["body_height"] as float, 60.0, 160.0, 4.0,  8.0)))

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var bsz := body_half_size(genome)
	var bw: int   = bsz.x
	var bh: int   = bsz.y
	var round: float = genome["roundness"] as float
	var str: float   = genome["strength"]  as float
	var pat: float   = genome.get("pattern", 0.0) as float

	# ── 1. Base silhouette ────────────────────────────────────────────────────
	if round >= 0.65:
		# BLOBBY: fat soft ellipse
		PC.fill_ellipse(img, CX, BY, bw, bh, pal["body"])
	elif round >= 0.30:
		# CHONKY: wide blob with side bumps
		PC.fill_ellipse(img, CX, BY, bw + 2, bh - 1, pal["body"])
		PC.fill_ellipse(img, CX - bw + 1, BY, 3, maxi(2, bh / 2), pal["body"])
		PC.fill_ellipse(img, CX + bw - 1, BY, 3, maxi(2, bh / 2), pal["body"])
	else:
		# BLOCKY ARMORED: hard rectangle with shoulder plates and belly strip
		PC.fill_rect(img, CX - bw, BY - bh, bw * 2, bh * 2, pal["body"])
		PC.fill_rect(img, CX - bw - 4, BY - bh,       5, bh / 2 + 1, pal["accent"])
		PC.fill_rect(img, CX + bw - 1, BY - bh,       5, bh / 2 + 1, pal["accent"])
		PC.fill_rect(img, CX - bw / 3,  BY - bh + 2,  bw * 2 / 3, bh * 2 - 4, pal["belly"])
		PC.line(img, CX - bw - 3, BY - bh + bh / 4, CX - bw - 3, BY + bh / 4, pal["outline"])
		PC.line(img, CX + bw + 2, BY - bh + bh / 4, CX + bw + 2, BY + bh / 4, pal["outline"])

	# ── 2. Pattern overlay ────────────────────────────────────────────────────
	if pat < 0.25:
		# PLAIN — soft belly
		PC.fill_ellipse(img, CX, BY + bh / 3, maxi(2, bw * 2 / 3), maxi(2, bh / 3), pal["belly"])

	elif pat < 0.50:
		# SPOTS — scatter blobs of complementary colour
		var spot: Color = pal["spot"]
		var spacing: int = maxi(3, (bw + bh) / 4)
		var row: int = 0
		var sy: int  = BY - bh + spacing
		while sy < BY + bh - 1:
			var off: int = (spacing / 2) if (row % 2 == 0) else 0
			var sx: int  = CX - bw + spacing + off
			while sx < CX + bw - 1:
				if _inside_body(sx, sy, bw, bh, round):
					PC.fill_circle(img, sx, sy, maxi(1, spacing / 3), spot)
				sx += spacing
			sy += spacing
			row += 1

	elif pat < 0.75:
		# STRIPES — horizontal bands
		var sc: Color    = pal["spot"]
		var band: int    = maxi(2, bh / 4)
		var sy2: int     = BY - bh + band
		var on: bool     = true
		while sy2 < BY + bh:
			if on:
				for ssy: int in range(sy2, mini(sy2 + band, BY + bh)):
					for ssx: int in range(CX - bw - 4, CX + bw + 5):
						if _inside_body(ssx, ssy, bw, bh, round):
							PC.blend(img, ssx, ssy, sc)
			sy2 += band
			on = !on

	else:
		# DIAMOND SCALES — repeating lattice
		var sc2: Color = pal["spot"]
		var d: int = maxi(3, (bw + bh) / 5)
		for sy3: int in range(BY - bh, BY + bh + 1):
			for ssx2: int in range(CX - bw - 4, CX + bw + 5):
				if not _inside_body(ssx2, sy3, bw, bh, round):
					continue
				var gx: int = (ssx2 - CX + d * 4) % d
				var gy: int = (sy3  - BY + d * 4) % d
				if absi(gx - d / 2) + absi(gy - d / 2) <= d / 3:
					PC.blend(img, ssx2, sy3, sc2)

	# ── 3. Shading ────────────────────────────────────────────────────────────
	var sh: Color = pal["shadow"];    sh.a    = 0.46
	var hi: Color = pal["highlight"]; hi.a = 0.36
	PC.fill_ellipse(img, CX,           BY + bh / 2,  bw,         bh / 2,     sh)
	PC.fill_ellipse(img, CX - bw / 3,  BY - bh / 3,  bw / 2,     bh / 3,     hi)

	# ── 4. Strength detail ────────────────────────────────────────────────────
	if str >= 0.70:
		for i: int in range(3):
			var my: int = BY - bh + 2 + i * (bh / 3)
			PC.line(img, CX - bw + 2, my, CX - 2,      my + 2, pal["shadow"])
			PC.line(img, CX + 2,      my, CX + bw - 2, my + 2, pal["shadow"])

	# ── 5. Outline ────────────────────────────────────────────────────────────
	if round >= 0.30:
		PC.outline_ellipse(img, CX, BY, bw + (2 if round < 0.65 else 0), bh, pal["outline"])
	else:
		PC.outline_rect(img, CX - bw, BY - bh, bw * 2, bh * 2, pal["outline"])
	return img

static func _inside_body(px: int, py: int, bw: int, bh: int, round: float) -> bool:
	if round >= 0.30:
		var dx: float = float(px - CX) / float(bw + (2 if round < 0.65 else 0))
		var dy: float = float(py - BY) / float(bh)
		return dx * dx + dy * dy <= 1.05
	return px >= CX - bw and px <= CX + bw and py >= BY - bh and py <= BY + bh

