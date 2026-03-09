# Procedural genome-driven sprite painter.
# Every pixel position and size comes from genome values.
# No fixed stamps — blended genomes produce blended silhouettes.
# Uses a 4-level Pokemon-style palette: outline, shadow, body, belly + accent.

class_name SpritePainter

const PC := preload("res://scripts/pixel_canvas.gd")

# ---- Public entry point -----------------------------------------------------

## Paint a full-body portrait from genome values. Returns 48x48 RGBA Image.
static func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal := _pokemon_palette(genome)
	var CX: int = PC.CX  # 24

	# Read genome with fallbacks
	var head_size: float  = genome.get("head_size",    45.0) as float
	var body_w: float     = genome.get("body_width",   80.0) as float
	var body_h: float     = genome.get("body_height", 100.0) as float
	var leg_len: float    = genome.get("leg_length",   50.0) as float
	var arm_len: float    = genome.get("arm_length",    0.0) as float
	var bill_sz: float    = genome.get("bill_size",     0.0) as float
	var bill_tip: float   = genome.get("bill_tip_offset", 0.0) as float
	var goofiness: float  = genome.get("goofiness",    0.5) as float
	var tail_len: float   = genome.get("tail_length",  40.0) as float
	var wing_span: float  = genome.get("wing_span",    1.0) as float
	var horn_sz: float    = genome.get("horn_size",    15.0) as float

	var has_tail:      bool = genome.get("has_tail",      false) as bool
	var has_wings:     bool = genome.get("has_wings",     false) as bool
	var has_horns:     bool = genome.get("has_horns",     false) as bool
	var has_claws:     bool = genome.get("has_claws",     false) as bool
	var extra_legs:    bool = genome.get("extra_legs",    false) as bool
	var wing_feathers: bool = genome.get("wing_feathers", false) as bool
	var has_arms:      bool = genome.has("arm_length") and arm_len > 5.0

	# Pixel dimensions derived from genome
	var head_rx: int = int(remap(head_size, 20.0, 70.0,  5.0, 11.0))
	var head_ry: int = int(remap(head_size, 20.0, 70.0,  5.0, 12.0))
	var body_rx: int = int(remap(body_w,   40.0, 120.0,  5.0, 13.0))
	var body_ry: int = int(remap(body_h,   60.0, 160.0,  4.0,  9.0))
	var ll:      int = int(remap(leg_len,  20.0,  80.0,  3.0,  8.0))
	var al:      int = int(remap(arm_len,  20.0,  70.0,  3.0,  9.0))
	var bl:      int = int(remap(bill_sz,   0.0,  30.0,  0.0,  8.0))
	var hl:      int = int(remap(horn_sz,   8.0,  40.0,  2.0,  8.0))
	var tl:      int = int(remap(tail_len, 20.0,  80.0,  4.0, 12.0))
	var ws:      int = int(remap(wing_span, 0.7,   2.0,  5.0, 17.0))

	# Vertical layout: stack head -> neck -> body -> legs
	var head_cy: int = head_ry + 2
	var body_cy: int = head_cy + head_ry + 2 + body_ry
	var leg_top: int = body_cy + body_ry
	var leg_bot: int = mini(leg_top + ll, PC.CANVAS_SIZE - 2)

	# Draw back-to-front (painter's algorithm)

	# TAIL (behind body, extends left)
	if has_tail:
		var tx: int = CX - body_rx - 1
		var ty: int = body_cy + body_ry / 2
		PC.line(img, tx, ty, tx - tl, ty + tl / 3, pal["shadow"], 1)
		PC.line(img, tx, ty, tx - tl, ty + tl / 3, pal["body"])
		PC.blend(img, tx - tl, ty + tl / 3, pal["accent"])

	# WINGS (behind body)
	if has_wings:
		for side: int in [-1, 1]:
			var wx: int    = CX + side * (body_rx - 1)
			var wy: int    = body_cy - body_ry + 2
			var tip_x: int = CX + side * (body_rx + ws)
			var tip_y: int = body_cy - body_ry - ws / 2
			if wing_feathers:
				PC.fill_polygon(img, [
					Vector2(wx,          wy),
					Vector2(tip_x,       tip_y),
					Vector2(tip_x + side * 3, tip_y + ws / 2),
					Vector2(wx,          wy + ws / 3),
				], pal["accent"])
				PC.line(img, wx, wy, tip_x, tip_y, pal["outline"])
			else:
				PC.fill_polygon(img, [
					Vector2(wx,          wy),
					Vector2(tip_x,       tip_y),
					Vector2(tip_x + side * 2, tip_y + ws * 2 / 3),
					Vector2(wx,          wy + ws / 2),
				], pal["shadow"])
				PC.line(img, wx, wy,    tip_x,                tip_y,              pal["outline"])
				PC.line(img, tip_x, tip_y, tip_x + side * 2, tip_y + ws * 2 / 3, pal["outline"])

	# BODY — filled ellipse with belly highlight and right-side shadow
	PC.fill_ellipse(img, CX, body_cy, body_rx, body_ry, pal["body"])
	for py: int in range(body_cy - body_ry + 1, body_cy + body_ry):
		var dy2: float = float((py - body_cy) * (py - body_cy)) / float(body_ry * body_ry)
		var half: int  = int(sqrt(maxf(0.0, 1.0 - dy2)) * float(body_rx))
		var fade: int  = CX + half / 2
		for px: int in range(fade, CX + half + 1):
			PC.blend(img, px, py, pal["shadow"])
	PC.fill_ellipse(img, CX - body_rx / 4, body_cy + body_ry / 4,
					maxi(1, body_rx * 2 / 3), maxi(1, body_ry * 2 / 3), pal["belly"])
	PC.fill_ellipse(img, CX, body_cy, body_rx - 2, body_ry - 1, pal["body"])
	PC.fill_ellipse(img, CX - body_rx / 4, body_cy + body_ry / 4,
					maxi(1, body_rx / 2), maxi(1, body_ry / 3), pal["belly"])
	PC.outline_ellipse(img, CX, body_cy, body_rx, body_ry, pal["outline"])

	# LEGS
	var leg_spread: int = maxi(2, body_rx * 2 / 3)
	var offsets: Array = ([-leg_spread, leg_spread, -leg_spread - 4, leg_spread + 4]
						  if extra_legs else [-leg_spread, leg_spread])
	for ox: int in offsets:
		var lx: int = CX + ox
		var lh: int = leg_bot - leg_top
		if lh < 1:
			continue
		PC.fill_rect(img, lx - 1, leg_top, 3, lh, pal["shadow"])
		PC.blend(img, lx, leg_top, pal["body"])
		PC.fill_ellipse(img, lx, leg_bot, 2, 1, pal["accent"])
		PC.outline_rect(img, lx - 1, leg_top, 3, lh, pal["outline"])

	# ARMS
	if has_arms:
		var arm_y: int = body_cy - body_ry / 2
		for side: int in [-1, 1]:
			var ax: int = CX + side * body_rx
			var ex: int = ax + side * al
			var ey: int = arm_y + al
			PC.line(img, ax, arm_y, ex, ey, pal["shadow"], 1)
			PC.line(img, ax, arm_y, ex, ey, pal["body"])
			if has_claws:
				PC.line(img, ex, ey, ex + side * 3, ey - 1, pal["accent"])
				PC.line(img, ex, ey, ex + side,     ey + 3, pal["accent"])
			PC.fill_circle(img, ax, arm_y, 1, pal["outline"])

	# NECK
	var neck_top: int = head_cy + head_ry - 1
	var neck_bot: int = body_cy - body_ry + 1
	if neck_bot > neck_top:
		PC.fill_rect(img, CX - 2, neck_top, 5, neck_bot - neck_top, pal["body"])
		PC.blend(img, CX - 2, neck_top, pal["outline"])
		PC.blend(img, CX + 2, neck_top, pal["outline"])
		PC.blend(img, CX - 2, neck_bot - 1, pal["outline"])
		PC.blend(img, CX + 2, neck_bot - 1, pal["outline"])

	# HEAD
	PC.fill_ellipse(img, CX, head_cy, head_rx, head_ry, pal["body"])
	for py: int in range(head_cy - head_ry + 1, head_cy + head_ry):
		var dy2: float = float((py - head_cy) * (py - head_cy)) / float(head_ry * head_ry)
		var half: int  = int(sqrt(maxf(0.0, 1.0 - dy2)) * float(head_rx))
		var fade: int  = CX + half / 3
		for px: int in range(fade, CX + half + 1):
			PC.blend(img, px, py, pal["shadow"])
	PC.fill_ellipse(img, CX - head_rx / 3, head_cy - head_ry / 3,
					maxi(1, head_rx / 3), maxi(1, head_ry / 4), pal["belly"])
	PC.outline_ellipse(img, CX, head_cy, head_rx, head_ry, pal["outline"])

	# HORNS
	if has_horns:
		for side: int in [-1, 1]:
			var hx: int = CX + side * (head_rx / 2)
			var hy: int = head_cy - head_ry
			PC.line(img, hx, hy, hx + side * (hl / 2), hy - hl, pal["accent"], 1)
			PC.blend(img, hx + side * (hl / 2), hy - hl, pal["belly"])

	# EYES
	var eye_off: int = maxi(2, head_rx * 2 / 3)
	var eye_y: int   = head_cy - head_ry / 4
	var eye_r: int   = maxi(1, head_rx / 4)
	for side: int in [-1, 1]:
		var ex: int = CX + side * eye_off
		if goofiness > 0.65:
			PC.fill_circle(img, ex, eye_y, eye_r + 1, Color.WHITE)
			PC.fill_circle(img, ex, eye_y, eye_r, pal["spot"])
			PC.blend(img, ex, eye_y, Color.BLACK)
			PC.outline_circle(img, ex, eye_y, eye_r + 1, pal["outline"])
		else:
			PC.fill_ellipse(img, ex, eye_y, eye_r + 1, eye_r, pal["spot"])
			PC.blend(img, ex, eye_y, Color.BLACK)
			PC.outline_ellipse(img, ex, eye_y, eye_r + 1, eye_r, pal["outline"])

	# MOUTH or BILL
	var mouth_y: int = head_cy + head_ry / 2
	if bl > 0:
		var bx: int     = CX + head_rx - 1
		var tip_ox: int = int(bill_tip * 3.0)
		PC.fill_polygon(img, [
			Vector2(bx,      mouth_y - 2),
			Vector2(bx + bl, mouth_y - 1 + tip_ox),
			Vector2(bx + bl, mouth_y + 1 + tip_ox),
			Vector2(bx,      mouth_y + 2),
		], pal["accent"])
		PC.line(img, bx, mouth_y - 2, bx + bl, mouth_y - 1 + tip_ox, pal["outline"])
		PC.line(img, bx, mouth_y + 2, bx + bl, mouth_y + 1 + tip_ox, pal["outline"])
	elif goofiness > 0.65:
		var mw: int = maxi(2, head_rx - 1)
		PC.line(img, CX - mw, mouth_y,     CX,       mouth_y + 2, pal["outline"])
		PC.line(img, CX,      mouth_y + 2, CX + mw,  mouth_y,     pal["outline"])
	elif goofiness < 0.30:
		var mw: int = maxi(2, head_rx - 2)
		PC.line(img, CX - mw, mouth_y + 2, CX,       mouth_y,     pal["outline"])
		PC.line(img, CX,      mouth_y,     CX + mw,  mouth_y + 2, pal["outline"])
	else:
		var mw: int = maxi(2, head_rx - 2)
		PC.line(img, CX - mw, mouth_y + 1, CX + mw, mouth_y + 1, pal["outline"])

	return img

# ---- 4-colour Pokemon palette -----------------------------------------------

## Gen-1-style: 4 brightness steps on one hue + distinct accent hue.
static func _pokemon_palette(genome: Dictionary) -> Dictionary:
	var base: Color  = genome["body_color"]
	var acc: Color   = genome["accent_color"]

	var h: float     = base.h
	var s: float     = maxf(0.65, base.s)
	var v_mid: float = clampf(base.v, 0.50, 0.78)

	var ah:  float = acc.h
	var as2: float = maxf(0.55, acc.s)
	var av:  float = clampf(acc.v, 0.45, 0.85)

	return {
		"body":      Color.from_hsv(h,  s,                    v_mid),
		"belly":     Color.from_hsv(h,  s * 0.15,             0.97),
		"shadow":    Color.from_hsv(h,  minf(1.0, s + 0.12),  maxf(0.10, v_mid - 0.28)),
		"highlight": Color.from_hsv(h,  s * 0.08,             1.00),
		"outline":   Color.from_hsv(h,  minf(1.0, s + 0.18),  maxf(0.05, v_mid - 0.52)),
		"accent":    Color.from_hsv(ah, as2,                  av),
		"spot":      Color.from_hsv(ah, as2 * 0.75,           minf(1.0, av + 0.18)),
	}
