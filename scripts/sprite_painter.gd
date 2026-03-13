# Bug sprite painter — every genome value drives real pixel dimensions.
# One type: ball-shaped body, smaller head, insect legs, antennae, optional wings.

class_name SpritePainter

const PC := preload("res://scripts/pixel_canvas.gd")

# ---- Public entry point -----------------------------------------------------

## Paint a full-body bug portrait from genome. Returns 48x48 RGBA Image.
static func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal := _pokemon_palette(genome)
	var CX: int = PC.CX  # 24

	# Read genome with fallbacks
	var body_sz: float   = genome.get("body_size",      75.0)
	var head_sz: float   = genome.get("head_size",      45.0)
	var leg_len: float   = genome.get("leg_length",     50.0)
	var ant_len: float   = genome.get("antenna_length", 50.0)
	var ant_spr: float   = genome.get("antenna_spread",  0.5)
	var eye_sz: float    = genome.get("eye_size",        50.0)
	var goofiness: float = genome.get("goofiness",       0.5)
	var has_wings: bool  = genome.get("has_wings",      false)
	var wing_span: float = genome.get("wing_span",       1.0)
	var wing_type: float = genome.get("wing_type",       0.5)
	var extra_legs: bool = genome.get("extra_legs",     false)

	# Pixel dimensions derived from genome
	var body_r: int = int(remap(body_sz,   50.0, 100.0,  8.0, 13.0))
	var head_r: int = int(remap(head_sz,   30.0,  70.0,  4.0,  8.0))
	var ll: int     = int(remap(leg_len,   20.0,  80.0,  4.0, 10.0))
	var al: int     = int(remap(ant_len,   20.0,  80.0,  3.0,  8.0))
	var eye_r: int  = int(remap(eye_sz,    20.0,  80.0,  1.0,  4.0))
	var ws: int     = int(remap(wing_span,  0.7,   2.0,  5.0, 15.0))

	# Vertical layout: head near top, body below
	var head_cy: int = head_r + 3
	var body_cy: int = head_cy + head_r + body_r - 3

	# --- WINGS (behind everything) ---
	if has_wings:
		var wy: int = body_cy - body_r / 2
		for side: int in [-1, 1]:
			var wx: int = CX + side * (body_r - 1)
			if wing_type >= 0.5:
				# Broad rounded wings (butterfly style)
				var wcx: int = CX + side * (body_r + ws / 2)
				var wcy: int = wy - ws / 3
				PC.fill_ellipse(img, wcx, wcy, ws / 2, ws * 2 / 3, pal["accent"])
				PC.outline_ellipse(img, wcx, wcy, ws / 2, ws * 2 / 3, pal["outline"])
			else:
				# Narrow elongated wings (dragonfly style)
				var tx: int = CX + side * (body_r + ws)
				var ty: int = wy - ws / 2
				PC.fill_polygon(img, [
					Vector2(wx,            wy),
					Vector2(tx,            ty),
					Vector2(tx + side * 2, ty + ws * 2 / 3),
					Vector2(wx,            wy + 3),
				], pal["shadow"])
				PC.line(img, wx, wy, tx, ty, pal["outline"])
				PC.line(img, tx, ty, tx + side * 2, ty + ws * 2 / 3, pal["outline"])

	# --- BODY ---
	PC.fill_circle(img, CX, body_cy, body_r, pal["body"])
	# Right-side shadow pass
	for py: int in range(body_cy - body_r + 1, body_cy + body_r):
		var dy2: float = float((py - body_cy) * (py - body_cy)) / float(body_r * body_r)
		var half: int  = int(sqrt(maxf(0.0, 1.0 - dy2)) * float(body_r))
		var fade: int  = CX + half / 2
		for px: int in range(fade, CX + half + 1):
			PC.blend(img, px, py, pal["shadow"])
	# Subtle specular gleam (upper-left, single pixel)
	PC.blend(img, CX - body_r / 2, body_cy - body_r / 2, pal["belly"])
	PC.outline_circle(img, CX, body_cy, body_r, pal["outline"])

	# --- LEGS ---
	var num_pairs: int = 4 if extra_legs else 3
	for i: int in range(num_pairs):
		var t: float   = (float(i) + 0.5) / float(num_pairs)
		var ay: int    = body_cy - body_r + int(t * float(body_r) * 2.0)
		for side: int in [-1, 1]:
			var ax: int      = CX + side * body_r
			# Upper segment goes out and slightly up
			var knee_x: int  = ax + side * (ll / 2 + 1)
			var knee_y: int  = ay - ll / 4
			# Lower segment hooks down to foot
			var foot_x: int  = knee_x + side * (ll / 4)
			var foot_y: int  = mini(PC.CANVAS_SIZE - 2, knee_y + ll * 2 / 3)
			PC.line(img, ax, ay, knee_x, knee_y, pal["outline"])
			PC.line(img, knee_x, knee_y, foot_x, foot_y, pal["outline"])
			PC.blend(img, foot_x, foot_y, pal["accent"])

	# --- HEAD ---
	PC.fill_circle(img, CX, head_cy, head_r, pal["body"])
	# Right-side shadow pass
	for py: int in range(head_cy - head_r + 1, head_cy + head_r):
		var dy2: float = float((py - head_cy) * (py - head_cy)) / float(head_r * head_r)
		var half: int  = int(sqrt(maxf(0.0, 1.0 - dy2)) * float(head_r))
		var fade: int  = CX + half / 3
		for px: int in range(fade, CX + half + 1):
			PC.blend(img, px, py, pal["shadow"])
	PC.outline_circle(img, CX, head_cy, head_r, pal["outline"])

	# --- ANTENNAE ---
	var ant_base: int = maxi(1, int(remap(ant_spr, 0.2, 1.0, 1.0, float(head_r - 1))))
	for side: int in [-1, 1]:
		var bx: int    = CX + side * ant_base
		var by: int    = head_cy - head_r
		var tip_x: int = bx + side * (al / 2 + 2)
		var tip_y: int = maxi(1, by - al)
		PC.line(img, bx, by, tip_x, tip_y, pal["outline"])
		PC.fill_circle(img, tip_x, tip_y, 1, pal["accent"])

	# --- EYES (large compound eyes) ---
	var eye_off: int = maxi(2, head_r * 2 / 3)
	var eye_y: int   = head_cy
	for side: int in [-1, 1]:
		var ex: int = CX + side * eye_off
		PC.fill_circle(img, ex, eye_y, eye_r, Color.WHITE)
		if eye_r > 1:
			PC.fill_circle(img, ex, eye_y, eye_r - 1, pal["spot"])
		PC.blend(img, ex, eye_y, Color.BLACK)
		PC.outline_circle(img, ex, eye_y, eye_r, pal["outline"])

	# --- MOUTH ---
	var mouth_y: int = head_cy + head_r * 2 / 3
	var mw: int      = maxi(1, head_r - 2)
	if goofiness > 0.65:
		PC.line(img, CX - mw, mouth_y,     CX,       mouth_y + 1, pal["outline"])
		PC.line(img, CX,      mouth_y + 1, CX + mw,  mouth_y,     pal["outline"])
	elif goofiness < 0.30:
		PC.line(img, CX - mw, mouth_y + 1, CX,       mouth_y,     pal["outline"])
		PC.line(img, CX,      mouth_y,     CX + mw,  mouth_y + 1, pal["outline"])
	else:
		PC.line(img, CX - mw, mouth_y, CX + mw, mouth_y, pal["outline"])

	return img

# ---- 4-colour Pokemon palette -----------------------------------------------

## Gen-1-style: 4 brightness steps on one hue + distinct accent hue.
static func _pokemon_palette(genome: Dictionary) -> Dictionary:
	var base: Color  = genome.get("body_color",   Color(0.3, 0.6, 0.2))
	var acc: Color   = genome.get("accent_color", Color(0.8, 0.5, 0.1))

	var h: float     = base.h
	var s: float     = maxf(0.65, base.s)
	var v_mid: float = clampf(base.v, 0.50, 0.78)

	var ah: float    = acc.h
	var as2: float   = maxf(0.55, acc.s)
	var av: float    = clampf(acc.v, 0.45, 0.85)

	return {
		"body":    Color.from_hsv(h,  s,                    v_mid),
		"belly":   Color.from_hsv(h,  s * 0.15,             0.97),
		"shadow":  Color.from_hsv(h,  minf(1.0, s + 0.12),  maxf(0.10, v_mid - 0.28)),
		"outline": Color.from_hsv(h,  minf(1.0, s + 0.18),  maxf(0.05, v_mid - 0.52)),
		"accent":  Color.from_hsv(ah, as2,                  av),
		"spot":    Color.from_hsv(ah, as2 * 0.75,           minf(1.0, av + 0.18)),
	}
